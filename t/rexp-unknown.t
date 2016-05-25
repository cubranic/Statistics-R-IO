#!perl -T
use 5.010;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 19;
use Test::Fatal;

use Statistics::R::REXP::Unknown;

my $unk = new_ok('Statistics::R::REXP::Unknown', [_sexptype=>42], 'new unknown');

is($unk, $unk, 'self equality');

my $unk_2 = Statistics::R::REXP::Unknown->new(_sexptype => 42);
is($unk, $unk_2, 'unknown equality');
is(Statistics::R::REXP::Unknown->new(42), $unk, 'scalar constructor');

## error checking in constructor arguments
like(exception {
        Statistics::R::REXP::Unknown->new([1, 2, 3])
     }, qr/Attribute \(_sexptype\) does not pass the type constraint/,
     'error-check in single-arg constructor');
like(exception {
        Statistics::R::REXP::Unknown->new(1, 2, 3)
     }, qr/odd number of arguments/,
     'odd constructor arguments');
like(exception {
        Statistics::R::REXP::Unknown->new(_sexptype => [1, 2, 3])
     }, qr/Attribute \(_sexptype\) does not pass the type constraint/,
     'bad name argument');

my $unk_foo = Statistics::R::REXP::Unknown->new(_sexptype => 100);
isnt($unk, $unk_foo, 'unknown inequality');

is($unk->sexptype, 42, 'unknown sexptype');

ok(! $unk->is_null, 'is not null');
ok(! $unk->is_vector, 'is not vector');

is($unk .'', 'Unknown', 'unknown text representation');

## attributes
is_deeply($unk->attributes, undef, 'default attributes');

my $unk_attr = Statistics::R::REXP::Unknown->new(_sexptype => 42,
                                                attributes => { foo => 'bar',
                                                                x => [40, 41, 42] });
is_deeply($unk_attr->attributes,
          { foo => 'bar', x => [40, 41, 42] }, 'constructed attributes');

my $unk_attr2 = Statistics::R::REXP::Unknown->new(_sexptype => 42,
                                                 attributes => { foo => 'bar',
                                                                 x => [40, 41, 42] });
my $another_unk_attr = Statistics::R::REXP::Unknown->new(_sexptype => 42,
                                                        attributes => { foo => 'bar',
                                                                        x => [40, 42, 42] });
is($unk_attr, $unk_attr2, 'equality considers attributes');
isnt($unk_attr, $unk, 'inequality considers attributes');
isnt($unk_attr, $another_unk_attr, 'inequality considers attributes deeply');

## attributes must be a hash
like(exception {
        Statistics::R::REXP::Unknown->new(_sexptype => 42,
                                          attributes => 1)
     }, qr/Attribute \(attributes\) does not pass the type constraint/,
     'setting non-HASH attributes');

## Perl representation
is_deeply($unk->to_pl,
          undef, 'Perl representation');
