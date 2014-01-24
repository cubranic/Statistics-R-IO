package Statistics::R::REXP::Logical;

use 5.012;

use Moo;
use namespace::clean;

with 'Statistics::R::REXP::Vector';

has '+elements' => (
    coerce => sub {
        my $x = shift;
        sub flatten { map { ref $_ ? flatten(@{$_}) : $_ } @_; }
        [ map { defined $_ ? ($_ ? 1 : 0) : undef } flatten(@{$x}) ] if ref $x eq ref []
    },
);


sub _type { 'logical'; }

1; # End of Statistics::R::REXP::Logical
