#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 16;

use Statistics::R::REXP::Logical;

my $empty_vec = new_ok('Statistics::R::REXP::Logical', [  ], 'new logical vector' );

is($empty_vec, $empty_vec, 'self equality');

my $empty_vec_2 = Statistics::R::REXP::Logical->new();
is($empty_vec, $empty_vec_2, 'empty logical vector equality');

my $vec = Statistics::R::REXP::Logical->new(elements => [1, 0, 1, 0]);
my $vec2 = Statistics::R::REXP::Logical->new([3.3, '', 'bla', '0']);
is($vec, $vec2, 'logical vector equality');

my $another_vec = Statistics::R::REXP::Logical->new(elements => [1, 0, 1, undef]);
isnt($vec, $another_vec, 'logical vector inequality');

is($empty_vec->to_s, 'logical()', 'empty logical vector text representation');
is($vec->to_s, 'logical(1, 0, 1, 0)', 'logical vector text representation');
is($another_vec->to_s, 'logical(1, 0, 1, undef)', 'text representation with logical NAs');
is(Statistics::R::REXP::Logical->new(elements => [undef])->to_s,
   'logical(undef)', 'text representation of a singleton NA');

is_deeply($empty_vec->elements, [], 'empty logical vector contents');
is_deeply($vec->elements, [1, 0, 1, 0], 'logical vector contents');
is($vec->elements->[2], 1, 'single element access');

is_deeply(Statistics::R::REXP::Logical->new(elements => [3.3, '', undef, 'foo'])->elements,
          [1, 0, undef, 1], 'constructor with undefined values');

is_deeply(Statistics::R::REXP::Logical->new(elements => [3.3, '', [0, ['00', undef]], 1])->elements,
          [1, 0, 0, 1, undef, 1], 'constructor from nested arrays');

ok(! $empty_vec->is_null, 'is not null');
ok( $empty_vec->is_vector, 'is vector');
