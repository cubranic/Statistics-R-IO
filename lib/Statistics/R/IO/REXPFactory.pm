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
    seq(string("X\n"),     # XDR header
        uint32(2),         # serialization format v2
        \&any_uint32,      # creator's R version
        uint32(0x020300)   # min R version to read (2.3.0 as of 3.0.2)
    )
}


sub object_content {
    bind(\&unpack_object_info,
         \&object_data)
}


sub unpack_object_info {
    my $state = shift or return;
    my $object_info_state = any_uint32($state) or return;
    my $object_info = $object_info_state->[0];
    [ { is_object => $object_info & 1<<8,
        has_attributes => $object_info & 1<<9,
        has_tag => $object_info & 1<<10,
        object_type => $object_info & 0xFF,
        levels => $object_info >> 12,
      },
      $object_info_state->[1] ]
}


sub object_data {
    my $object_info = shift;
    ## TODO: handle attributes
    sub {
        my $state = shift or return;
        if ($object_info->{object_type} == 10) {
            # logical vector
            lglsxp($object_info)->($state)
        } elsif ($object_info->{object_type} == 13) {
            # integer vector
            intsxp($object_info)->($state)
        } elsif ($object_info->{object_type} == 14) {
            # numeric vector
            realsxp($object_info)->($state)
        } elsif ($object_info->{object_type} == 16) {
            # character vector
            strsxp($object_info)->($state)
        } elsif ($object_info->{object_type} == 9) {
            # internal character string
            charsxp($object_info)->($state)
        } elsif ($object_info->{object_type} == 2) {
            # pairlist
            listsxp($object_info)->($state)
        } elsif ($object_info->{object_type} == 1) {
            # sumbol
            symsxp($object_info)->($state)
        } elsif ($object_info->{object_type} == 0xfe) {
            # encoded Nil
            [ undef, ($state) ]
        } else {
            die "unimplemented SEXPTYPE: " . $object_info->{object_type};
        }
    }
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
                      sub {
                          my %value = (value => $args[-1]);
                          $value{tag} = $args[-2] if $object_info->{has_tag};
                          $value{attributes} = $args[0] if $object_info->{has_attributes};
                          [ { %value } , shift ]
                      }
                  }),
             object_content),
         sub {
             my @elements = @{shift or return};
             
             sub {
                 my @value;
                 while (@elements) {
                     my ($car, $cdr) = @elements;
                     push @value, $car;
                     last unless defined $cdr;
                     @elements = @{$cdr};
                 }
                 [ [@value], shift ]
             }
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


sub charsxp {
    my $object_info = shift;
    ## TODO: handle character set encodings (UTF8, LATIN1, native)
    bind(with_count(\&any_char),
         sub {
             my @chars = @{shift or return};
             sub {
                 [ join('', @chars),
                   shift ]
             }
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
