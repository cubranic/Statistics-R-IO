#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 5;

use Statistics::R::REXP::Null;

my $null = new_ok('Statistics::R::REXP::Null', [], 'new null');

is($null, $null, 'self equality');

my $null_2 = Statistics::R::REXP::Null->new;
is($null, $null_2, 'null equality');
isnt($null, 'null', 'null inequality');

ok($null->is_null, 'is null');
