package Statistics::R::REXP::Raw;

use 5.012;

use Scalar::Util qw(looks_like_number);

use Moo;
use namespace::clean;

with 'Statistics::R::REXP::Vector';

has '+elements' => (
    coerce => sub {
        my $x = shift;
        sub flatten { map { ref $_ ? flatten(@{$_}) : $_ } @_; }
        [ map { looks_like_number $_ && ($_ >= 0) && ($_ <= 255) ?
                    int($_) : die "Elements of raw vectors must be 0-255" }
              flatten(@{$x}) ] if ref $x eq ref []
    },
);

has '+attributes' => (
    isa => sub { die 'Raw vectors cannot have attributes' if defined shift; },
);


sub _type { 'raw'; }

1; # End of Statistics::R::REXP::Raw
