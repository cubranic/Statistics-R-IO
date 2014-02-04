package Statistics::R::REXP::Null;

use 5.012;

use Moo;
use namespace::clean;

with 'Statistics::R::REXP';

has '+attributes' => (
    isa => sub { die 'Null cannot have attributes' if defined shift; },
);

sub is_null {
    return 1;
}

use overload 'eq' => \&eq,
    'ne' => sub {! equal_class(@_);},
    '""' => sub { 'NULL' };

sub eq {
    return equal_class(@_);
}


sub to_pl {
    undef
}

1; # End of Statistics::R::REXP::Null
