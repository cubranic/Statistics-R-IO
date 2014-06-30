package Statistics::R::IO::QapEncoding;
# ABSTRACT: Functions for parsing Rserve packets
$Statistics::R::IO::QapEncoding::VERSION = '0.091';
use 5.010;

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
        lglsxp($object_info, $attributes)
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
        ! defined $row_names->elements->[0]) {
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
        bind(count($object_info->{length}/4,
                   any_int32_na),
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
        bind(count($object_info->{length}/8,
                   any_real64_na),
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


sub lglsxp {
    my ($object_info, $attributes) = (shift, shift);
    
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
                          my %args = (elements => [
                                          map { $_ == 2 ? undef : $_ } @{$elements}
                                      ]);
                          if ($attributes) {
                              $args{attributes} = $attributes
                          }
                          mreturn(Statistics::R::REXP::Logical->new(%args));
                      })
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
                    my $element = join('', @characters);
                    if ($element eq "\xFF") {
                        ## NaStringRepresentation
                        push @elements, undef;
                    } else {
                        ## unescape real \xFF characters
                        $element =~ s/\xFF\xFF/\xFF/g;
                        push @elements, $element;
                    }
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

=pod

=encoding UTF-8

=head1 NAME

Statistics::R::IO::QapEncoding - Functions for parsing Rserve packets

=head1 VERSION

version 0.091

=head1 SYNOPSIS

    use Statistics::R::IO::QapEncoding qw( decode );

    # Assume $data comes from an Rserve response body
    my ($rexp, $state) = @{ decode($data) }
        or die "couldn't parse";
    
    # If we're reading a QAP response, there should be no data left
    # unparsed
    die 'Unread data remaining' unless $state->eof;

    # the result of the unserialization is a REXP
    say $rexp;

    # REXPs can be converted to the closest native Perl data type
    print $rexp->to_pl;

=head1 DESCRIPTION

This module implements the actual reading of serialized R objects encoded with Rserve's QAP protocol
and their conversion to a L<Statistics::R::REXP>. You are not
expected to use it directly, as it's normally wrapped by
L<Statistics::R::IO/evalRserve> and L<Statistics::R::IO::Rserve/eval>.

=head1 SUBROUTINES

=over

=item decode $data

Constructs a L<Statistics::R::REXP> object from its serialization in
C<$data>. Returns a pair of the object and the
L<Statistics::R::IO::ParserState> at the end of serialization.

=item decode_sexp, decode_int

Parsers for Rserve's C<DT_SEXP> and C<DT_INT> data types,
respectively.

=item dt_sexp_data

Parses the body of an RServe C<DT_SEXP> object by parsing its header
(C<XT_> type and length) and content (done by sequencing
L</unpack_sexp_info> and L</sexp_data>.

=item unpack_sexp_info

Parser for the header (consisting of the C<XT_*> type, flags, and
object length) of a serialized SEXP. Returns a hash with keys
"object_type", "has_attributes", and "length", each corresponding to
the field in R serialization described in L<QAP1 protocol
description|http://www.rforge.net/Rserve/dev.html>.

=item sexp_data $obj_info

Parser for a QAP-serialized R object, using the object type stored in
C<$obj_info> hash's "object_type" key to use the correct parser for
the particular type.

=item intsxp, langsxp, lglsxp, listsxp, rawsxp, dblsxp,
strsxp, symsxp, vecsxp

Parsers for the corresponding R SEXP-types.

=item nosxp

Parser for the Rserve's C<XT_UNKNOWN> type, encoding an R SEXP-type
that does not have a corresponding representation in QAP.

=item maybe_attributes $object_info

Convenience parser for SEXP attributes, which are serialized as a
tagged pairlist C<XT_LIST_TAG> followed by a SEXP for the object
value. Attributes are stored only if C<$object_info> indicates their
presence. Returns a pair of C<$object_info> and a hash reference to
the attributes, as returned by L</tagged_pairlist_to_attribute_hash>.

=item tagged_pairlist

Parses a pairlist (optionally tagged) and returns an array where each
element is a hash containing keys C<value> (the REXP of the pairlist
element) and, optionally, C<tag>.

=item tagged_pairlist_to_rexp_hash

Converts a pairlist to a REXP hash whose keys are the pairlist's
element tags and values the pairlist elements themselves.

=item tagged_pairlist_to_attribute_hash

Converts object attributes, which are serialized as a pairlist with
attribute name in the element's tag, to a hash that can be used as
the C<attributes> argument to L<Statistics::R::REXP> constructors.

Some attributes are serialized using a compact encoding (for
instance, when a table's row names are just integers 1:nrows), and
this function will decode them to a complete REXP.

=back

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.

=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.

=head1 AUTHOR

Davor Cubranic <cubranic@stat.ubc.ca>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by University of British Columbia.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
