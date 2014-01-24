#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 29;
use Test::Fatal;

use Statistics::R::REXP::List;
use Statistics::R::REXP::Double;

my $empty_list = new_ok('Statistics::R::REXP::List', [  ], 'new generic vector' );

is($empty_list, $empty_list, 'self equality');

my $empty_list_2 = Statistics::R::REXP::List->new();
is($empty_list, $empty_list_2, 'empty generic vector equality');

my $list = Statistics::R::REXP::List->new(elements => [3.3, '4', 11]);
my $list2 = Statistics::R::REXP::List->new([3.3, 4, 11]);
is($list, $list2, 'generic vector equality');

is(Statistics::R::REXP::List->new($list2), $list, 'copy constructor');
is(Statistics::R::REXP::List->new(Statistics::R::REXP::Double->new([3.3, 4, 11])),
   $list, 'copy constructor from a vector');

my $another_list = Statistics::R::REXP::List->new(elements => [3.3, 4, 10.9]);
isnt($list, $another_list, 'generic vector inequality');

my $na_heavy_list = Statistics::R::REXP::List->new(elements => [11.3, ['', undef], '0']);
my $na_heavy_list2 = Statistics::R::REXP::List->new(elements => [11.3, [undef, undef], 0]);
is($na_heavy_list, $na_heavy_list, 'NA-heavy generic vector equality');
isnt($na_heavy_list, $na_heavy_list2, 'NA-heavy generic vector inequality');

is($empty_list->to_s, 'list()', 'empty generic vector text representation');
is($list->to_s, 'list(3.3, 4, 11)', 'generic vector text representation');
is(Statistics::R::REXP::List->new(elements => [undef])->to_s,
   'list(undef)', 'text representation of a singleton NA');
is(Statistics::R::REXP::List->new(elements => [[[undef]]])->to_s,
   'list([[undef]])', 'text representation of a nested singleton NA');
is($na_heavy_list->to_s, 'list(11.3, [, undef], 0)', 'empty string representation');

is_deeply($empty_list->elements, [], 'empty generic vector contents');
is_deeply($list->elements, [3.3, 4, 11], 'generic vector contents');
is($list->elements->[2], 11, 'single element access');

is_deeply(Statistics::R::REXP::List->new(elements => [3.3, 4.0, '3x', 11])->elements,
          [3.3, 4, '3x', 11], 'constructor with non-numeric values');

my $nested_list = Statistics::R::REXP::List->new(elements => [3.3, 4.0, ['b', ['cc', 44.1]], 11]);
is_deeply($nested_list->elements,
          [3.3, 4, ['b', ['cc', 44.1]], 11], 'nested list contents');
is_deeply($nested_list->elements->[2]->[1], ['cc', 44.1], 'nested element');
is_deeply($nested_list->elements->[3], 11, 'non-nested element');

is($nested_list->to_s, 'list(3.3, 4, [b, [cc, 44.1]], 11)', 
   'nested generic vector text representation');

ok(! $empty_list->is_null, 'is not null');
ok( $empty_list->is_vector, 'is vector');


## attributes
is_deeply($list->attributes, undef, 'default attributes');

my $list_attr = Statistics::R::REXP::List->new(elements => $list->elements,
                                               attributes => { foo => 'bar', x => 42 });
is_deeply($list_attr->attributes, { foo => 'bar', x => 42 }, 'constructed attributes');
is($list_attr, $list_attr, 'equality considers attributes');
isnt($list_attr, $list, 'inequality considers attributes');

## attributes must be a hash
like(exception {
        Statistics::R::REXP::List->new(attributes => 1)
     }, qr/not a HASH ref/, 'setting non-HASH attributes');
