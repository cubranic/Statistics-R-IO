#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 12;

use Statistics::R::REXP::Symbol;

my $sym = new_ok('Statistics::R::REXP::Symbol', [ name => 'sym' ], 'new symbol' );

is($sym, $sym, 'self equality');

my $sym_2 = Statistics::R::REXP::Symbol->new(name => $sym);
is($sym, $sym_2, 'symbol equality with copy');
is(Statistics::R::REXP::Symbol->new($sym_2), $sym, 'copy constructor');
is(Statistics::R::REXP::Symbol->new('sym'), $sym, 'string constructor');

my $sym_foo = Statistics::R::REXP::Symbol->new(name => 'foo');
isnt($sym, $sym_foo, 'symbol inequality');

is($sym->name, 'sym', 'symbol name');

ok(! $sym->is_null, 'is not null');


## attributes
is_deeply($sym->attributes, undef, 'default attributes');

my $sym_attr = Statistics::R::REXP::Symbol->new(name => $sym->name,
                                                attributes => { foo => 'bar', x => 42 });
is_deeply($sym_attr->attributes, { foo => 'bar', x => 42 }, 'constructed attributes');
is($sym_attr, $sym_attr, 'equality considers attributes');
isnt($sym_attr, $sym, 'inequality considers attributes');
