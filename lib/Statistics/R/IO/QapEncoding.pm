package Statistics::R::IO::QapEncoding;
# ABSTRACT: Functions for parsing Rserve packets

use 5.012;

use strict;
use warnings FATAL => 'all';

use Exporter 'import';

our @EXPORT = qw( );
our @EXPORT_OK = qw( decode );

our %EXPORT_TAGS = ( all => [ @EXPORT_OK ], );

use Statistics::R::IO::Parser qw( :all );
use Statistics::R::IO::ParserState;
use Statistics::R::REXP::Character;
use Statistics::R::REXP::Double;
use Statistics::R::REXP::Integer;
use Statistics::R::REXP::List;
use Statistics::R::REXP::Logical;
use Statistics::R::REXP::Raw;
use Statistics::R::REXP::Language;
use Statistics::R::REXP::Symbol;
use Statistics::R::REXP::Null;
use Statistics::R::REXP::GlobalEnvironment;
use Statistics::R::REXP::Unknown;

use Carp;


sub unpack_sexp_info {
    bind(\&any_uint32,
         sub {
             my $object_info = shift // return;
             my $is_long = $object_info & 1<<6;

             if ($is_long) {
                 ## TODO: if `is_long`, then the next 4 bytes contain
                 ## the upper half of the length
                 error "Sorry, long packets aren't supported yet" 
             } else {
                 mreturn { has_attributes => $object_info & 1<<7,
                           is_long => $is_long,
                           object_type => $object_info & 0x3F,
                           length => $object_info >> 8,
                 }
             }
         })
}


sub sexp_data {
    my $object_info = shift;

    bind(maybe_attributes($object_info),
         sub {
             my ($object_info, $attributes) = @{shift()};
             
    if ($object_info->{object_type} == 0x00) {
        # encoded Nil
        mreturn(Statistics::R::REXP::Null->new)
    } elsif ($object_info->{object_type} == 32) {
        # integer vector
        intsxp($object_info, $attributes)
    } elsif ($object_info->{object_type} == 36) {
        # logical vector
        lglsxp($object_info)
    } elsif ($object_info->{object_type} == 33) {
        # numeric vector
        dblsxp($object_info, $attributes)
    } elsif ($object_info->{object_type} == 34) {
        # character vector
        strsxp($object_info, $attributes)
    } elsif ($object_info->{object_type} == 37) {
        # raw vector
        rawsxp($object_info)
    } elsif ($object_info->{object_type} == 16) {
        # list (generic vector)
        vecsxp($object_info, $attributes)
    } elsif ($object_info->{object_type} == 20) {
        # pairlist
        die "not implemented: $object_info->{object_type}";
        listsxp($object_info)
    } elsif ($object_info->{object_type} == 21) {
        # pairlist with tags
        $object_info->{has_tags} = 1;
        tagged_pairlist($object_info)
    } elsif ($object_info->{object_type} == 22) {
        # language without tags
        $object_info->{has_tags} = 0;
        langsxp($object_info, $attributes)
    } elsif ($object_info->{object_type} == 23) {
        # language with tags
        $object_info->{has_tags} = 1;
        langsxp($object_info, $attributes)
    } elsif ($object_info->{object_type} == 19) {
        # symbol
        symsxp($object_info)
    } elsif ($object_info->{object_type} == 48) {
        # unknown
        nosxp($object_info, $attributes)
    } else {
        error "unimplemented XT_TYPE: " . $object_info->{object_type}
    }
         })
}


sub maybe_attributes {
    my $object_info = shift;

    sub {
        my $state = shift or return;
        my $attributes;

        if ($object_info->{has_attributes}) {
            my $attributes_start = $state->position;
            my $result = dt_sexp_data()->($state) or return;

            $attributes = { tagged_pairlist_to_attribute_hash(shift @$result) };
            $state = shift @$result;

            ## adjust SEXP length for that already consumed by attributes
            $object_info->{length} -= $state->position - $attributes_start;
        }
        
        [ [$object_info, $attributes], $state]
    }
}


sub tagged_pairlist_to_rexp_hash {
    my $list = shift;
    return unless ref $list eq ref [];

    my %rexps;
    foreach my $element (@$list) {
        croak "Tagged element has an attribute?!"
            if exists $element->{attribute};
        my $name = $element->{tag}->name;
        $rexps{$name} = $element->{value};
    }
    %rexps
}


sub tagged_pairlist_to_attribute_hash {
    my %rexp_hash = tagged_pairlist_to_rexp_hash @_;
    
    my $row_names = $rexp_hash{'row.names'};
    if ($row_names && $row_names->type eq 'integer' &&
        $row_names->elements->[0] == -(1<<31)) {
        ## compact encoding when rownames are integers 1..n
        ## the length n is in the second element
        my $n = $row_names->elements->[1];
        $rexp_hash{'row.names'} = Statistics::R::REXP::Integer->new([1..$n]);
    }

    %rexp_hash
}


sub symsxp {
    my $object_info = shift;
    
    if ($object_info->{length}) {
        bind(count($object_info->{length}, \&any_char),
             sub {
                 my @chars = @{shift or return};
                 pop @chars while @chars && !ord($chars[-1]);
                 mreturn(Statistics::R::REXP::Symbol->new(join('', @chars)))
             })
    } else {
        error 'TODO: null-length symsxp';
    }
}


sub nosxp {
    my ($object_info, $attributes) = (shift, shift);

    bind(\&any_uint32,
         sub {
             my $sexp_id = shift or return;

             my %args = (sexptype => $sexp_id);
             if ($attributes) {
                 $args{attributes} = $attributes
             }
             
             mreturn(Statistics::R::REXP::Unknown->new(%args))
         })
}


sub intsxp {
    my ($object_info, $attributes) = (shift, shift);
    
    if ($object_info->{length} % 4 == 0) {
        bind(count($object_info->{length}/4, \&any_int32),
             sub {
                 my @ints = @{shift or return};
                 my %args = (elements => [@ints]);
                 if ($attributes) {
                     $args{attributes} = $attributes
                 }
                 mreturn(Statistics::R::REXP::Integer->new(%args));
             })
    } else {
        error "TODO: intsxp length doesn't align by 4: " .
            $object_info->{length}
    }
}


sub dblsxp {
    my ($object_info, $attributes) = (shift, shift);
    
    if ($object_info->{length} % 8 == 0) {
        bind(count($object_info->{length}/8, \&any_real64),
             sub {
                 my @dbls = @{shift or return};
                 my %args = (elements => [@dbls]);
                 if ($attributes) {
                     $args{attributes} = $attributes
                 }
                 mreturn(Statistics::R::REXP::Double->new(%args));
             })
    } else {
        error "TODO: dblsxp length doesn't align by 8: " .
            $object_info->{length}
    }
}


sub logsxp {
    my $object_info = shift;
    
    if ($object_info->{length}) {
        bind(with_count(\&any_uint32, \&any_uint8),
             sub {
                 my @elements = @{shift or return};
                 mreturn Statistics::R::REXP::Logical->new(
                     [
                        map { $_ == 2 ? undef : $_ } @elements
                     ]);
             })
    } else {
        mreturn(Statistics::R::REXP::Logical->new);
    }
}


sub rawsxp {
    my $object_info = shift;

    my $dt_length = $object_info->{length},;
    if ($dt_length) {
        bind(\&any_uint32,
             sub {
                 my $true_length = shift // return;
                 my $padding_length = $dt_length - $true_length - 4;

                 bind(seq(count($true_length,
                                \&any_uint8),
                          count($padding_length,
                               \&any_uint8)),
                      sub {
                          my ($elements, $padding) = @{shift or return};
                          mreturn(Statistics::R::REXP::Raw->new($elements));
                      })
             })
    } else {
        mreturn(Statistics::R::REXP::Raw->new);
    }
}


sub strsxp {
    my ($object_info, $attributes) = (shift, shift);

    my $length = $object_info->{length};
    if ($length) {
        sub {
            my $state = shift;
            my $end_at = $state->position + $length;

            my @elements;       # elements of the vector
            my @characters;     # characters in the current element
            while ($state->position < $end_at) {
                my $ch = $state->at;
                if (ord($ch)) {
                    push @characters, $ch;
                } else {
                    ## TODO: check for NaStringRepresentation
                   push @elements, join('', @characters);
                    @characters = ();
                }
                $state = $state->next;
            }
            
            my %args = (elements => [@elements]);
            if ($attributes) {
                $args{attributes} = $attributes
            }
            [ Statistics::R::REXP::Character->new(%args), $state ];
        }
    } else {
        mreturn(Statistics::R::REXP::Character->new);
    }
}


sub vecsxp {
    my ($object_info, $attributes) = (shift, shift);

    my $length = $object_info->{length};
    sub {
        my $state = shift;
        my $end_at = $state->position + $length;
        
        my @elements;
        while ($state->position < $end_at) {
            my $result = dt_sexp_data()->($state) or return;
            
            push @elements, shift @$result;
            $state = shift @$result;
        }
        my %args = (elements => [@elements]);
        if ($attributes) {
            $args{attributes} = $attributes
        }
        [ Statistics::R::REXP::List->new(%args), $state ];
    }
}


sub tagged_pairlist {
    my $object_info = shift;

    my $length = $object_info->{length};
    if ($length) {
        sub {
            my $state = shift;
            my $end_at = $state->position + $length;
            
            my @elements;
            while ($state->position < $end_at) {
                my $result = dt_sexp_data()->($state) or return;
                
                my $value = shift @$result;
                $state = shift @$result;

                my $element = { value => $value };
                if ($object_info->{has_tags}) {
                    $result = dt_sexp_data()->($state) or return;
                    my $tag = shift @$result;

                    $element->{tag} = $tag unless $tag->is_null;
                    $state = shift @$result;
                }
                
                push @elements, $element;
            }
            [ [ @elements ], $state ];
        }
    } else {
        mreturn []
    }
}


## Language expressions are pairlists, but with a certain structure:
## - the first element is the reference (name or another language
##   expression) to the function call
## - the rest of the list are the arguments of the call, with optional
##   tags to name them
sub langsxp {
    my ($object_info, $attributes) = (shift, shift);
    ## After the pairlist has been parsed by `listsxp`, we want to
    ## separate the tags from the elements before invoking the Language
    ## constructor, with the tags becoming the names attribute
    bind(tagged_pairlist($object_info),
         sub {
             my $list = shift or return;

             my @elements;
             my @names;
             foreach my $element (@$list) {
                 my $tag = $element->{tag};
                 my $value = $element->{value};
                 push @elements, $value;
                 push @names, $tag ? $tag->name : '';
             }

             my %args = (elements => [ @elements ]);
             ## if no element is tagged, then don't construct the
             ## 'names' attribute
             if (grep {exists $_->{tag}} @$list) {
                 $attributes //=  {}; # initialize the hash
                 $attributes->{names} = Statistics::R::REXP::Character->new([ @names ]);
             }
             $args{attributes} = $attributes if $attributes;

             mreturn(Statistics::R::REXP::Language->new(%args))
         })
}


sub dt_sexp_data {
    bind(unpack_sexp_info,
         \&sexp_data)
}


sub decode_sexp {
    bind(seq(uint8(10), \&any_uint24,
             dt_sexp_data),
         sub {
             mreturn shift->[2]
         })
}


sub decode_int {
    die 'TODO: implement'
}


sub decode {
    my $data = shift;
    return error "Decode requires a scalar data or array reference" if ref $data && ref $data ne ref [];

    endianness('<');
    
    my $result =
        decode_sexp->(Statistics::R::IO::ParserState->new(data => $data));
    
    if ($result) {
        my $state = $result->[1];
        carp("remaining data: " . (scalar(@{$state->data}) - $state->position))
            unless $state->eof;
    }
    
    $result;
}


1;

__END__
