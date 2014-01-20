package Statistics::R::REXP;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Moo::Role;

sub equal_class {
    my ($self, $obj) = (shift, shift);

    return (ref($self) eq ref($obj));
}


sub is_null {
    return 0;
}

1; # End of Statistics::R::REXP
