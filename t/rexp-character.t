#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 18;

use Statistics::R::REXP::Character;

my $empty_vec = new_ok('Statistics::R::REXP::Character', [  ], 'new character vector' );

is($empty_vec, $empty_vec, 'self equality');

my $empty_vec_2 = Statistics::R::REXP::Character->new();
is($empty_vec, $empty_vec_2, 'empty character vector equality');

my $vec = Statistics::R::REXP::Character->new(elements => [3.3, '4.7', 'bar']);
my $vec2 = Statistics::R::REXP::Character->new(elements => [3.3, 4.7, 'bar']);
is($vec, $vec2, 'character vector equality');

my $another_vec = Statistics::R::REXP::Character->new(elements => [3.3, '4.7', 'bar', undef]);
isnt($vec, $another_vec, 'character vector inequality');

my $na_heavy_vec = Statistics::R::REXP::Character->new(elements => ['foo', '', undef, 23]);
my $na_heavy_vec2 = Statistics::R::REXP::Character->new(elements => ['foo', 0, undef, 23]);
is($na_heavy_vec, $na_heavy_vec, 'NA-heavy vector equality');
isnt($na_heavy_vec, $na_heavy_vec2, 'NA-heavy vector inequality');

is($empty_vec->to_s, 'character()', 'empty character vector text representation');
is($vec->to_s, 'character(3.3, 4.7, bar)', 'character vector text representation');
is(Statistics::R::REXP::Character->new(elements => [undef])->to_s,
   'character(undef)', 'text representation of a singleton NA');
is($na_heavy_vec->to_s, 'character(foo, , undef, 23)', 'empty characters representation');

is_deeply($empty_vec->elements, [], 'empty character vector contents');
is_deeply($vec->elements, [3.3, 4.7, 'bar'], 'character vector contents');
is($vec->elements->[1], 4.7, 'single element access');

is_deeply(Statistics::R::REXP::Character->new(elements => [3.3, 4.0, '3x', 11])->elements,
          [3.3, 4, '3x', 11], 'constructor with non-numeric values');

is_deeply(Statistics::R::REXP::Character->new(elements => [3.3, 4.0, [7, ['a', 'foo']], 11])->elements,
          [3.3, 4, 7, 'a', 'foo', 11], 'constructor from nested arrays');

ok(! $empty_vec->is_null, 'is not null');
ok( $empty_vec->is_vector, 'is vector');
