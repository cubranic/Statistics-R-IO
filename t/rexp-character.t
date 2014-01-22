#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 14;

use Statistics::R::REXP::Character;

my $empty_vec = new_ok('Statistics::R::REXP::Character', [  ], 'new character vector' );

is($empty_vec, $empty_vec, 'self equality');

my $empty_vec_2 = Statistics::R::REXP::Character->new();
is($empty_vec, $empty_vec_2, 'empty character vector equality');

my $vec = Statistics::R::REXP::Character->new(elements => [3.3, '4.7', 11]);
my $vec2 = Statistics::R::REXP::Character->new(elements => [3.3, 4.7, 11]);
is($vec, $vec2, 'character vector equality');

my $another_vec = Statistics::R::REXP::Character->new(elements => [3, 5, 11]);
isnt($vec, $another_vec, 'character vector inequality');

is($empty_vec->to_s, 'character()', 'empty character vector text representation');
is($vec->to_s, 'character(3.3, 4.7, 11)', 'character vector text representation');

is_deeply($empty_vec->elements, [], 'empty character vector contents');
is_deeply($vec->elements, [3.3, 4.7, 11], 'character vector contents');
is($vec->elements->[1], 4.7, 'single element access');

is_deeply(Statistics::R::REXP::Character->new(elements => [3.3, 4.0, '3x', 11])->elements,
          [3.3, 4, '3x', 11], 'constructor with non-numeric values');

is_deeply(Statistics::R::REXP::Character->new(elements => [3.3, 4.0, [7, ['a', 'foo']], 11])->elements,
          [3.3, 4, 7, 'a', 'foo', 11], 'constructor from nested arrays');

ok(! $empty_vec->is_null, 'is not null');
ok( $empty_vec->is_vector, 'is vector');
