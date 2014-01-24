#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 24;

use Statistics::R::REXP::Double;
use Statistics::R::REXP::List;

my $empty_vec = new_ok('Statistics::R::REXP::Double', [  ], 'new double vector' );

is($empty_vec, $empty_vec, 'self equality');

my $empty_vec_2 = Statistics::R::REXP::Double->new();
is($empty_vec, $empty_vec_2, 'empty double vector equality');

my $vec = Statistics::R::REXP::Double->new(elements => [3.3, 4.7, 11]);
my $vec2 = Statistics::R::REXP::Double->new([3.3, 4.7, 11]);
is($vec, $vec2, 'double vector equality');

is(Statistics::R::REXP::Double->new($vec2), $vec, 'copy constructor');
is(Statistics::R::REXP::Double->new(Statistics::R::REXP::List->new([3.3, [4.7, 11]])),
   $vec, 'copy constructor from a vector');

my $another_vec = Statistics::R::REXP::Double->new(elements => [3, 4.7, 11]);
isnt($vec, $another_vec, 'double vector inequality');

my $na_heavy_vec = Statistics::R::REXP::Double->new(elements => [11.3, '', undef, 0.0]);
my $na_heavy_vec2 = Statistics::R::REXP::Double->new(elements => [11.3, 0, undef, 0]);
is($na_heavy_vec, $na_heavy_vec, 'NA-heavy vector equality');
isnt($na_heavy_vec, $na_heavy_vec2, 'NA-heavy vector inequality');

is($empty_vec->to_s, 'double()', 'empty double vector text representation');
is($vec->to_s, 'double(3.3, 4.7, 11)', 'double vector text representation');
is(Statistics::R::REXP::Double->new(elements => [undef])->to_s,
   'double(undef)', 'text representation of a singleton NA');
is($na_heavy_vec->to_s, 'double(11.3, undef, undef, 0)', 'empty numbers representation');

is_deeply($empty_vec->elements, [], 'empty double vector contents');
is_deeply($vec->elements, [3.3, 4.7, 11], 'double vector contents');
is($vec->elements->[1], 4.7, 'single element access');

is_deeply(Statistics::R::REXP::Double->new(elements => [3.3, 4.0, '3x', 11])->elements,
          [3.3, 4, undef, 11], 'constructor with non-numeric values');

is_deeply(Statistics::R::REXP::Double->new(elements => [3.3, 4.0, [7, [20.9, 44.1]], 11])->elements,
          [3.3, 4, 7, 20.9, 44.1, 11], 'constructor from nested arrays');

ok(! $empty_vec->is_null, 'is not null');
ok( $empty_vec->is_vector, 'is vector');


## attributes
is_deeply($vec->attributes, undef, 'default attributes');

my $vec_attr = Statistics::R::REXP::Double->new(elements => $vec->elements,
                                                attributes => { foo => 'bar', x => 42 });
is_deeply($vec_attr->attributes, { foo => 'bar', x => 42 }, 'constructed attributes');
is($vec_attr, $vec_attr, 'equality considers attributes');
isnt($vec_attr, $vec, 'inequality considers attributes');
