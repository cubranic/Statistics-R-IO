package Statistics::R::REXP::Null;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Moo;
use namespace::clean;

with 'Statistics::R::REXP';

sub is_null {
    return 1;
}

use overload 'eq' => \&eq,
    'ne' => sub {! equal_class(@_);};

sub eq {
    return equal_class(@_);
}

1; # End of Statistics::R::REXP::Null
