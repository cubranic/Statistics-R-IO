package Statistics::R::IO::REXPFactory;

use 5.012;

use strict;
use warnings FATAL => 'all';

use Exporter 'import';

our @EXPORT = qw( );
our @EXPORT_OK = qw( unserialize );

our %EXPORT_TAGS = ( all => [ @EXPORT_OK ], );

use Statistics::R::IO::Parser qw( :all );


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
                     };
         })
}


sub object_data {
    my $object_info = shift;
    ## TODO: handle attributes
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
        mreturn
    } else {
        die "unimplemented SEXPTYPE: " . $object_info->{object_type};
    }
}


sub flatten_pairlist {
    my @value;

    my @elements = @_;
    while (@elements) {
        my ($car, $cdr) = @elements;
        push @value, $car;
        last unless defined $cdr;
        @elements = @{$cdr};
    }
    @value
}


sub listsxp {
    my $object_info = shift;
    my $sub_items = 1;          # one for CAR and one for CDR
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
             object_content),
         sub {
             mreturn [ flatten_pairlist @{shift or return} ]
         })
}


sub lglsxp {
    my $object_info = shift;
    with_count(\&any_uint32)
}


sub intsxp {
    my $object_info = shift;
    with_count(\&any_int32)
}


sub realsxp {
    my $object_info = shift;
    with_count(\&any_real64)
}


sub strsxp {
    my $object_info = shift;
    with_count(object_content)  # each element should be a charsxp
}


sub vecsxp {
    my $object_info = shift;
    with_count(object_content)  # each element can be anything
}


sub charsxp {
    my $object_info = shift;
    ## TODO: handle character set encodings (UTF8, LATIN1, native)
    bind(with_count(\&any_char),
         sub {
             my @chars = @{shift or return};
             mreturn join('', @chars);
         })
}


sub symsxp {
    my $object_info = shift;
    object_content              # should be followed by a charsxp
}

sub unserialize {
    my $data = shift;
    die "Unserialize requires a scalar data" if ref $data && ref $data ne ref [];

    bind(header,
         \&object_content,
        )->(Statistics::R::IO::ParserState->new(data => $data));
}

1;
