#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 21;

use Statistics::R::REXP::Integer;
use Statistics::R::REXP::List;

my $empty_vec = new_ok('Statistics::R::REXP::Integer', [  ], 'new integer vector' );

is($empty_vec, $empty_vec, 'self equality');

my $empty_vec_2 = Statistics::R::REXP::Integer->new();
is($empty_vec, $empty_vec_2, 'empty integer vector equality');

my $vec = Statistics::R::REXP::Integer->new(elements => [3, 4, 11]);
my $vec2 = Statistics::R::REXP::Integer->new([3, 4, 11]);
is($vec, $vec2, 'integer vector equality');

is(Statistics::R::REXP::Integer->new($vec2), $vec, 'copy constructor');
is(Statistics::R::REXP::Integer->new(Statistics::R::REXP::List->new([3.3, [4, '11']])),
   $vec, 'copy constructor from a vector');

my $another_vec = Statistics::R::REXP::Integer->new(elements => [3, 4, 1]);
isnt($vec, $another_vec, 'integer vector inequality');

## TODO: undef == 0!

my $truncated_vec = Statistics::R::REXP::Integer->new(elements => [3.3, 4.0, 11]);
is($truncated_vec, $vec, 'constructing from floats');

my $na_heavy_vec = Statistics::R::REXP::Integer->new(elements => [11.3, '', undef, '0.0']);
my $na_heavy_vec2 = Statistics::R::REXP::Integer->new(elements => [11, 0, undef, 0]);
is($na_heavy_vec, $na_heavy_vec, 'NA-heavy vector equality');
isnt($na_heavy_vec, $na_heavy_vec2, 'NA-heavy vector inequality');

is($empty_vec->to_s, 'integer()', 'empty integer vector text representation');
is($vec->to_s, 'integer(3, 4, 11)', 'integer vector text representation');
is(Statistics::R::REXP::Integer->new(elements => [undef])->to_s,
   'integer(undef)', 'text representation of a singleton NA');
is($na_heavy_vec->to_s, 'integer(11, undef, undef, 0)', 'empty numbers representation');

is_deeply($empty_vec->elements, [], 'empty integer vector contents');
is_deeply($vec->elements, [3, 4, 11], 'integer vector contents');
is($vec->elements->[2], 11, 'single element access');

is_deeply(Statistics::R::REXP::Integer->new(elements => [3.3, 4.0, '3x', 11])->elements,
          [3, 4, undef, 11], 'constructor with non-numeric values');

is_deeply(Statistics::R::REXP::Integer->new(elements => [3.3, 4.0, [7, [20.9, 44.1]], 11])->elements,
          [3, 4, 7, 21, 44, 11], 'constructor from nested arrays');

ok(! $empty_vec->is_null, 'is not null');
ok( $empty_vec->is_vector, 'is vector');
