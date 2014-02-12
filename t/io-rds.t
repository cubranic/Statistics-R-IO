#!perl
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 21;
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
       attributes => {
           names => Statistics::R::REXP::Character->new(['a', 'b', 'c'])
       }),
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
       attributes => {
           names => Statistics::R::REXP::Character->new(['foo'])
       }),
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
       attributes => {
           names => Statistics::R::REXP::Character->new(['A', 'B', 'C'])
       }),
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
       attributes => {
           names => Statistics::R::REXP::Character->new(['foo', '', 'bar'])
       }),
   'generic vector names att - xdr');


## matrix

## serialize matrix(-1:4, 2, 3), XDR: true
is(readRDS('t/data/noatt-mat-xdr'),
   Statistics::R::REXP::Integer->new(
       elements => [ -1, 0, 1, 2, 3, 4 ],
       attributes => {
           dim => Statistics::R::REXP::Integer->new([2, 3]),
       }),
   'int matrix no atts');

## serialize matrix(-1:4, 2, 3), XDR: false
is(readRDS('t/data/noatt-mat-noxdr'),
   Statistics::R::REXP::Integer->new(
       elements => [ -1, 0, 1, 2, 3, 4 ],
       attributes => {
           dim => Statistics::R::REXP::Integer->new([2, 3]),
       }),
   'int matrix no atts - binary');

## serialize matrix(-1:4, 2, 3, dimnames=list(c('a', 'b'))), XDR: true
is(readRDS('t/data/ab-mat-xdr'),
   Statistics::R::REXP::Integer->new(
       elements => [ -1, 0, 1, 2, 3, 4 ],
       attributes => {
           dim => Statistics::R::REXP::Integer->new([2, 3]),
           dimnames => Statistics::R::REXP::List->new([
               Statistics::R::REXP::Character->new(['a', 'b']),
               Statistics::R::REXP::Null->new
           ]),
       }),
   'int matrix rownames');


## data frames
## serialize head(cars)
is(readRDS('t/data/cars-xdr'),
   Statistics::R::REXP::List->new(
       elements => [
           Statistics::R::REXP::Double->new([ 4, 4, 7, 7, 8, 9]),
           Statistics::R::REXP::Double->new([ 2, 10, 4, 22, 16, 10]),
       ],
       attributes => {
           names => Statistics::R::REXP::Character->new(['speed', 'dist']),
           class => Statistics::R::REXP::Character->new(['data.frame']),
           'row.names' => Statistics::R::REXP::Integer->new([
               1, 2, 3, 4, 5, 6
           ]),
       }),
   'the cars data frame');

is(readRDS('t/data/cars-noxdr'),
   Statistics::R::REXP::List->new(
       elements => [
           Statistics::R::REXP::Double->new([ 4, 4, 7, 7, 8, 9]),
           Statistics::R::REXP::Double->new([ 2, 10, 4, 22, 16, 10]),
       ],
       attributes => {
           names => Statistics::R::REXP::Character->new(['speed', 'dist']),
           class => Statistics::R::REXP::Character->new(['data.frame']),
           'row.names' => Statistics::R::REXP::Integer->new([
               1, 2, 3, 4, 5, 6
           ]),
       }),
   'the cars data frame - binary');

## serialize head(mtcars)
is(readRDS('t/data/mtcars-xdr'),
   Statistics::R::REXP::List->new(
       elements => [
           Statistics::R::REXP::Double->new([ 21.0, 21.0, 22.8, 21.4, 18.7, 18.1 ]),
           Statistics::R::REXP::Double->new([ 6, 6, 4, 6, 8, 6 ]),
           Statistics::R::REXP::Double->new([ 160, 160, 108, 258, 360, 225 ]),
           Statistics::R::REXP::Double->new([ 110, 110, 93, 110, 175, 105 ]),
           Statistics::R::REXP::Double->new([ 3.90, 3.90, 3.85, 3.08, 3.15, 2.76 ]),
           Statistics::R::REXP::Double->new([ 2.620, 2.875, 2.320, 3.215, 3.440, 3.460 ]),
           Statistics::R::REXP::Double->new([ 16.46, 17.02, 18.61, 19.44, 17.02, 20.22 ]),
           Statistics::R::REXP::Double->new([ 0, 0, 1, 1, 0, 1 ]),
           Statistics::R::REXP::Double->new([ 1, 1, 1, 0, 0, 0 ]),
           Statistics::R::REXP::Double->new([ 4, 4, 4, 3, 3, 3 ]),
           Statistics::R::REXP::Double->new([ 4, 4, 1, 1, 2, 1 ]),
       ],
       attributes => {
           names => Statistics::R::REXP::Character->new([
               'mpg' , 'cyl', 'disp', 'hp', 'drat', 'wt', 'qsec',
               'vs', 'am', 'gear', 'carb']),
           class => Statistics::R::REXP::Character->new(['data.frame']),
           'row.names' => Statistics::R::REXP::Character->new([
               'Mazda RX4', 'Mazda RX4 Wag', 'Datsun 710',
               'Hornet 4 Drive', 'Hornet Sportabout', 'Valiant'
           ]),
       }),
   'the mtcars data frame');

## serialize head(iris)
is(readRDS('t/data/iris-xdr'),
   Statistics::R::REXP::List->new(
       elements => [
           Statistics::R::REXP::Double->new([ 5.1, 4.9, 4.7, 4.6, 5.0, 5.4 ]),
           Statistics::R::REXP::Double->new([ 3.5, 3.0, 3.2, 3.1, 3.6, 3.9 ]),
           Statistics::R::REXP::Double->new([ 1.4, 1.4, 1.3, 1.5, 1.4, 1.7 ]),
           Statistics::R::REXP::Double->new([ 0.2, 0.2, 0.2, 0.2, 0.2, 0.4 ]),
           Statistics::R::REXP::Integer->new(
               elements => [ 1, 1, 1, 1, 1, 1 ],
               attributes => {
                   levels => Statistics::R::REXP::Character->new([
                       'setosa', 'versicolor', 'virginica']),
                   class => Statistics::R::REXP::Character->new(['factor'])
               } ),
       ],
       attributes => {
           names => Statistics::R::REXP::Character->new([
               'Sepal.Length', 'Sepal.Width', 'Petal.Length',
               'Petal.Width', 'Species']),
           class => Statistics::R::REXP::Character->new(['data.frame']),
           'row.names' => Statistics::R::REXP::Integer->new([
               1, 2, 3, 4, 5, 6
           ]),
       }),
   'the iris data frame');
