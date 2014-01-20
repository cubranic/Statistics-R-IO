#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 6;

use Statistics::R::REXP::Symbol;

my $sym = new_ok('Statistics::R::REXP::Symbol', [ name => 'sym' ], 'new symbol' );

is($sym, $sym, 'self equality');

my $sym_2 = Statistics::R::REXP::Symbol->new(name => 'sym');
is($sym, $sym_2, 'symbol equality');

my $sym_foo = Statistics::R::REXP::Symbol->new(name => 'foo');
isnt($sym, $sym_foo, 'symbol inequality');

is($sym->name, 'sym', 'symbol name');

ok(! $sym->is_null, 'is not null');
