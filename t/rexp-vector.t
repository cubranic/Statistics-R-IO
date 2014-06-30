#!perl -T
use 5.010;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 3;

use Statistics::R::REXP::Vector;

# not instantiable
ok( ! Statistics::R::REXP::Vector->can('new') );

ok( Statistics::R::REXP::Vector->is_vector, 'is vector' );
ok( ! Statistics::R::REXP::Vector->is_null, 'is not null' );
