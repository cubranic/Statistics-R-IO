package Statistics::R::REXP::Symbol;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Moo;
use namespace::clean;

with 'Statistics::R::REXP';

has name => (
    is => 'ro',
);

use overload 'cmp' => \&cmp;

sub cmp {
    my ($self, $obj) = (shift, shift);
    return (equal_class($self, $obj) and
            ($self->name cmp $obj->name));
}

1; # End of Statistics::R::REXP::Symbol
