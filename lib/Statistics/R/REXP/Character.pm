package Statistics::R::REXP::Character;

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
        [ flatten(@{$x}) ] if ref $x eq ref [];
    },
);


sub _type { 'character'; }

1; # End of Statistics::R::REXP::Character
