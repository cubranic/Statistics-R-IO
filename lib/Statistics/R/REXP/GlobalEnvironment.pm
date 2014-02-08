package Statistics::R::REXP::GlobalEnvironment;

use 5.012;

use Moo;
use namespace::clean;

extends 'Statistics::R::REXP::Environment';

has '+attributes' => (
    isa => sub { die 'Global environment has implicit attributes' if defined shift },
);

has '+enclosure' => (
    isa => sub {
        die 'Global environment has an implicit enclosure'
            if defined $_[0]
    },
);


around name => sub {
    'R_GlobalEnvironment'
};

1; # End of Statistics::R::REXP::GlobalEnvironment
