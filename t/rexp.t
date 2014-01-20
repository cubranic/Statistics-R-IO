#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 1;

# not instantiable
ok( ! Statistics::R::REXP->can('new') );
