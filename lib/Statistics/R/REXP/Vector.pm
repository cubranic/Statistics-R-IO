package Statistics::R::REXP::Vector;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Moo::Role;

with 'Statistics::R::REXP';

sub is_vector {
    return 1;
}

1; # End of Statistics::R::REXP::Vector
