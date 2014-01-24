package Statistics::R::REXP::Double;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Scalar::Util qw(looks_like_number);

use Moo;
use namespace::clean;

with 'Statistics::R::REXP::Vector';

has '+elements' => (
    coerce => sub {
        my $x = shift;
        sub flatten { map { ref $_ ? flatten(@{$_}) : $_ } @_; }
        [ map { looks_like_number $_ ? $_ : undef } flatten(@{$x}) ]
    },
);


sub _type { 'double'; }

1; # End of Statistics::R::REXP::Double