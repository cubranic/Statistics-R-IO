package Statistics::R::IO::REXPFactory;

use 5.012;

use strict;
use warnings FATAL => 'all';

use Exporter 'import';

our @EXPORT = qw( );
our @EXPORT_OK = qw( unserialize readRDS );

our %EXPORT_TAGS = ( all => [ @EXPORT_OK ], );

use Statistics::R::IO::Parser qw( :all );
use Statistics::R::REXP::Character;
use Statistics::R::REXP::Double;
use Statistics::R::REXP::Integer;
use Statistics::R::REXP::List;
use Statistics::R::REXP::Logical;
use Statistics::R::REXP::Raw;
use Statistics::R::REXP::Symbol;
use Statistics::R::REXP::Null;

use Carp;

sub header {
    seq(choose(xdr(),
               bin()),
        uint32(2),         # serialization format v2
        \&any_uint32,      # creator's R version
        uint32(0x020300)   # min R version to read (2.3.0 as of 3.0.2)
    )
}


sub xdr {
    bind(string("X\n"),         # XDR header
         sub {
             endianness('>');
             mreturn shift;
         })
}


sub bin {
    bind(string("B\n"),         # "binary" header
         sub {
             endianness('<');
             mreturn shift;
         })
}


sub object_content {
    bind(&unpack_object_info,
         \&object_data)
}


sub unpack_object_info {
    bind(\&any_uint32,
         sub {
             my $object_info = shift or return;
             mreturn { is_object => $object_info & 1<<8,
                       has_attributes => $object_info & 1<<9,
                       has_tag => $object_info & 1<<10,
                       object_type => $object_info & 0xFF,
                       levels => $object_info >> 12,
                       flags => $object_info,
                     };
         })
}


sub object_data {
    my $object_info = shift;
    
    if ($object_info->{object_type} == 10) {
        # logical vector
        lglsxp($object_info)
    } elsif ($object_info->{object_type} == 13) {
        # integer vector
        intsxp($object_info)
    } elsif ($object_info->{object_type} == 14) {
        # numeric vector
        realsxp($object_info)
    } elsif ($object_info->{object_type} == 16) {
        # character vector
        strsxp($object_info)
    } elsif ($object_info->{object_type} == 24) {
        # raw vector
        rawsxp($object_info)
    } elsif ($object_info->{object_type} == 19) {
        # list (generic vector)
        vecsxp($object_info)
    } elsif ($object_info->{object_type} == 9) {
        # internal character string
        charsxp($object_info)
    } elsif ($object_info->{object_type} == 2) {
        # pairlist
        listsxp($object_info)
    } elsif ($object_info->{object_type} == 1) {
        # symbol
        symsxp($object_info)
    } elsif ($object_info->{object_type} == 0xfe) {
        # encoded Nil
        mreturn(Statistics::R::REXP::Null->new)
    } else {
        die "unimplemented SEXPTYPE: " . $object_info->{object_type};
    }
}


sub listsxp {
    my $object_info = shift;
    my $sub_items = 1;          # CAR, CDR will be read separately
    if ($object_info->{has_attributes}) {
        die "attributes on pairlists are not implemented yet";
    }
    if ($object_info->{has_tag}) {
        $sub_items++;
    }
    
    bind(seq(bind(count($sub_items, object_content),
                  sub {
                      my @args = @{shift or return};
                      my %value = (value => $args[-1]);
                      $value{tag} = $args[-2] if $object_info->{has_tag};
                      $value{attributes} = $args[0] if $object_info->{has_attributes};
                      mreturn { %value };
                  }),
             object_content),   # CDR
         sub {
             my ($car, $cdr) = @{shift or return};
             my @elements = ($car);
             push( @elements, @{$cdr}) if ref $cdr eq ref []; # tail of list
             mreturn [ @elements ]
         })
}


## Attributes are recorded as a pairlist, with attribute name in the
## element's tag, and attribute value in the element itself. Pairlists
## that serialize attributes should not have their own attribute.
sub tagged_pairlist_to_attribute_hash {
    my $list = shift;
    my %attributes;

    foreach my $element (@$list) {
        croak "Serialized attribute has itself an attribute?!"
            if exists $element->{attribute};
        my $tag = $element->{tag} or next;
        my $value = $element->{value};
        
        if ($tag->name eq 'row.names' &&
            $value->type eq 'integer' &&
            $value->elements->[0] == -(1<<31)) {
            ## compact encoding when rownames are integers 1..n
            ## the length n is in the second element
            my $n = $value->elements->[1];
            $attributes{'row.names'} = [1..$n];
        } else {
            $attributes{$tag->name} = $value->to_pl;
        }
    }
    %attributes;
}


## Vector lengths are encoded as signed integers. This was fine when
## the maximum allowed length was 2^31-1; long vectors were introduced
## in R 3.0 and their length is encoded in three bytes: -1, followed
## by high and low word of a 64-bit length.
sub maybe_long_length {
    bind(\&any_int32,
         sub {
             my $len = shift;
             if ($len >= 0) {
                 mreturn $len;
             } elsif ($len == -1) {
                 die 'TODO: Long vectors are not supported';
             } else {
                 die 'Negative length detected: ' . $len;
             }
         })
}


## Vectors are serialized first with a SEXP for the vector elements,
## followed by attributes stored as a tagged pairlist.
sub vector_and_attributes {
    my ($object_info, $element_parser, $rexp_class) = @_;

    my @parsers = ( with_count(maybe_long_length, $element_parser) );
    if ($object_info->{has_attributes}) {
        push @parsers, object_content
    }

    bind(seq(@parsers),
         sub {
             return unless $_[0];
             my %args = (elements => (shift($_[0]) || []));
             if ($object_info->{has_attributes}) {
                 $args{attributes} = { tagged_pairlist_to_attribute_hash(shift $_[0]) };
             }
             mreturn($rexp_class->new(%args))
         })
}


sub lglsxp {
    my $object_info = shift;
    vector_and_attributes($object_info, \&any_uint32,
                          'Statistics::R::REXP::Logical')
}


sub intsxp {
    my $object_info = shift;
    vector_and_attributes($object_info, \&any_int32,
                          'Statistics::R::REXP::Integer')
}


sub realsxp {
    my $object_info = shift;
    vector_and_attributes($object_info, \&any_real64,
                          'Statistics::R::REXP::Double')
}


sub strsxp {
    my $object_info = shift;
    vector_and_attributes($object_info, object_content,
                          'Statistics::R::REXP::Character')
}


sub rawsxp {
    my $object_info = shift;
    die "No attributes are allowed on raw vectors"
        if $object_info->{has_attributes};

    bind(with_count(maybe_long_length, \&any_uint8),
         sub {
             mreturn(Statistics::R::REXP::Raw->new(shift or return));
         })
}


sub vecsxp {
    my $object_info = shift;
    vector_and_attributes($object_info, object_content,
                          'Statistics::R::REXP::List')
}


sub charsxp {
    my $object_info = shift;
    ## TODO: handle character set encodings (UTF8, LATIN1, native)
    bind(\&any_int32,
         sub {
             my $len = shift;
             if ($len >= 0) {
                 bind(count( $len, \&any_char),
                      sub {
                          my @chars = @{shift or return};
                          mreturn join('', @chars);
                      })
             } elsif ($len == -1) {
                 die 'TODO: NA charsxps';
             } else {
                 die 'Negative length detected: ' . $len;
             }
         })
}


sub symsxp {
    my $object_info = shift;
    bind(object_content,        # should be followed by a charsxp
         sub {
             mreturn(Statistics::R::REXP::Symbol->new(shift or return));
         })
}


sub unserialize {
    my $data = shift;
    die "Unserialize requires a scalar data" if ref $data && ref $data ne ref [];

    my $result =
        bind(header,
             \&object_content,
        )->(Statistics::R::IO::ParserState->new(data => $data));
    
    if ($result) {
        my $state = $result->[1];
        carp("remaining data: " . (scalar(@{$state->data}) - $state->position))
            unless $state->eof;
    }
    
    $result;
}


sub readRDS {
    open (my $f, shift) or croak $!;
    my $data;
    sysread($f, $data, 1<<30);
    my ($value, $state) = @{unserialize($data)};
    croak 'Could not parse RDS file' unless $state;
    croak 'Unread data remaining in the RDS file' unless $state->eof;
    $value
}


1;
