#!perl
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 19;
use Test::Fatal;

use Statistics::R::IO::Parser qw(:all);
use Statistics::R::IO::ParserState;
use Statistics::R::IO::REXPFactory qw( readRDS );


## integer vectors

## serialize 1:3, XDR: true
is(readRDS('t/data/noatt-123l-xdr'),
   Statistics::R::REXP::Integer->new([ 1, 2, 3 ]),
   'int vector no atts');

## serialize 1:3, XDR: false
is(readRDS('t/data/noatt-123l-noxdr'),
   Statistics::R::REXP::Integer->new([ 1, 2, 3 ]),
   'int vector no atts - binary');

## serialize a=1L, b=2L, c=3L, XDR: true
is(readRDS('t/data/abc-123l-xdr'),
   Statistics::R::REXP::Integer->new(
       elements => [ 1, 2, 3 ],
       attributes => { names => ['a', 'b', 'c'] }),
   'int vector names att - xdr');


## double vectors
## serialize 1234.56, XDR: true
is(readRDS('t/data/noatt-123456-xdr'),
   Statistics::R::REXP::Double->new([ 1234.56 ]),
   'double vector no atts');

## serialize 1234.56, XDR: false
is(readRDS('t/data/noatt-123456-noxdr'),
   Statistics::R::REXP::Double->new([ 1234.56 ]),
   'double vector no atts - binary');

## serialize foo=1234.56, XDR: true
is(readRDS('t/data/foo-123456-xdr'),
   Statistics::R::REXP::Double->new(
       elements => [ 1234.56 ],
       attributes => { names => ['foo'] }),
   'double vector names att - xdr');


## character vectors
## serialize letters[1:3], XDR: true
is(readRDS('t/data/noatt-abc-xdr'),
   Statistics::R::REXP::Character->new([ 'a', 'b', 'c' ]),
   'character vector no atts');

is(readRDS('t/data/noatt-abc-noxdr'),
   Statistics::R::REXP::Character->new([ 'a', 'b', 'c' ]),
   'character vector no atts - binary');

## serialize A='a', B='b', C='c', XDR: true
is(readRDS('t/data/ABC-abc-xdr'),
   Statistics::R::REXP::Character->new(
       elements => [ 'a', 'b', 'c' ],
       attributes => { names => ['A', 'B', 'C'] }),
   'character vector names att - xdr');


## raw vectors
## serialize as.raw(c(1:3, 255, 0), XDR: true
is(readRDS('t/data/noatt-raw-xdr'),
   Statistics::R::REXP::Raw->new([ 1, 2, 3, 255, 0 ]),
   'raw vector');

is(readRDS('t/data/noatt-raw-noxdr'),
   Statistics::R::REXP::Raw->new([ 1, 2, 3, 255, 0 ]),
   'raw vector');


## list (i.e., generic vector)
## serialize list(1:3, list('a', 'b', 11), 'foo'), XDR: true
is(readRDS('t/data/noatt-list-xdr'),
   Statistics::R::REXP::List->new([
       Statistics::R::REXP::Integer->new([ 1, 2, 3]),
       Statistics::R::REXP::List->new([
           Statistics::R::REXP::Character->new(['a']),
           Statistics::R::REXP::Character->new(['b']),
           Statistics::R::REXP::Double->new([11]) ]),
       Statistics::R::REXP::Character->new(['foo']) ]),
   'generic vector no atts');

is(readRDS('t/data/noatt-list-noxdr'),
   Statistics::R::REXP::List->new([
       Statistics::R::REXP::Integer->new([ 1, 2, 3]),
       Statistics::R::REXP::List->new([
           Statistics::R::REXP::Character->new(['a']),
           Statistics::R::REXP::Character->new(['b']),
           Statistics::R::REXP::Double->new([11]) ]),
       Statistics::R::REXP::Character->new(['foo']) ]),
   'generic vector no atts - binary');

## serialize list(foo=1:3, list('a', 'b', 11), bar='foo'), XDR: true
is(readRDS('t/data/foobar-list-xdr'),
   Statistics::R::REXP::List->new(
       elements => [
           Statistics::R::REXP::Integer->new([ 1, 2, 3]),
           Statistics::R::REXP::List->new([
               Statistics::R::REXP::Character->new(['a']),
               Statistics::R::REXP::Character->new(['b']),
               Statistics::R::REXP::Double->new([11]) ]),
           Statistics::R::REXP::Character->new(['foo']) ],
       attributes => {names => ['foo', '', 'bar'] }),
   'generic vector names att - xdr');


## matrix

## serialize matrix(-1:4, 2, 3), XDR: true
is(readRDS('t/data/noatt-mat-xdr'),
   Statistics::R::REXP::Integer->new(
       elements => [ -1, 0, 1, 2, 3, 4 ],
   attributes => { dim => [2, 3] }),
   'int matrix no atts');

## serialize matrix(-1:4, 2, 3), XDR: false
is(readRDS('t/data/noatt-mat-noxdr'),
   Statistics::R::REXP::Integer->new(
       elements => [ -1, 0, 1, 2, 3, 4 ],
   attributes => { dim => [2, 3] }),
   'int matrix no atts - binary');

## serialize matrix(-1:4, 2, 3, dimnames=list(c('a', 'b'))), XDR: true
is(readRDS('t/data/ab-mat-xdr'),
   Statistics::R::REXP::Integer->new(
       elements => [ -1, 0, 1, 2, 3, 4 ],
   attributes => { dim => [2, 3],
                   dimnames => [ ['a', 'b'],
                                 undef ] }),
   'int matrix rownames');


## data frames
## serialize head(cars)
is(readRDS('t/data/cars-xdr'),
   Statistics::R::REXP::List->new(
       elements => [
           Statistics::R::REXP::Double->new([ 4, 4, 7, 7, 8, 9]),
           Statistics::R::REXP::Double->new([ 2, 10, 4, 22, 16, 10]),
       ],
       attributes => {names => ['speed', 'dist'],
                      'row.names' => [1, 2, 3, 4, 5, 6],
                      class => ['data.frame'] }),
   'the cars data frame');

is(readRDS('t/data/cars-noxdr'),
   Statistics::R::REXP::List->new(
       elements => [
           Statistics::R::REXP::Double->new([ 4, 4, 7, 7, 8, 9]),
           Statistics::R::REXP::Double->new([ 2, 10, 4, 22, 16, 10]),
       ],
       attributes => {names => ['speed', 'dist'],
                      'row.names' => [1, 2, 3, 4, 5, 6],
                      class => ['data.frame'] }),
   'the cars data frame - binary');
