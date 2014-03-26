#!perl
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 16;
use Test::Fatal;
use Test::MockObject::Extends;

use Statistics::R::IO::Parser qw(:all);
use Statistics::R::IO qw( evalRserve );


sub mock_rserve_response {
    my $filename = shift;
    open (my $f, $filename) or die $! . " $filename";
    my $data;
    sysread($f, $data, 1<<30);
    my $response = pack("VVA*", 0x10001, length($data), "\0"x8) .
        $data;

    my $mock = Test::MockObject::Extends->new('IO::Socket');
    $mock->mock('syswrite',
                sub {
                    my ($self, $data) = (shift, shift);
                    length($data);
                });
    $mock->mock('sysread',
                sub {
                    state $pos = 0;
                    
                    # args: self, $data, length
                    $_[1] = substr($response, $pos, $_[2]);
                    
                    $pos += length($_[1]); # advance the cursor
                    
                    length($_[1]); # return the amount read
                })
}


sub parse_rserve_eval {
    my ($file, $expected, $message) = @_;

    my $filename = $file . '-xdr';
    
    subtest 'mock ' . $message => sub {
        plan tests => 9;
        
        my $mock = mock_rserve_response($filename);
        is(evalRserve('testing, please ignore',
                      $mock),
           $expected, $message);

        my ($request, $args) = $mock->next_call();
        
        is($request,
           'syswrite', 'send request');
        
        my ($command, $length, $offset, $length_hi) =
            unpack('V4', $args->[1]);
        is($command,
           0xf5, 'request CMD_serEval');
        is($length+16,
           length($args->[1]), 'request length');
        is($offset,
           0, 'request offset');
        is($length_hi,
           0, 'request hi-length');
        
        is($mock->next_call(),
           'sysread', 'read response status');
        is($mock->next_call(),
           'sysread', 'read response data');
        is($mock->next_call(),
           undef, 'last call');
    }
}


## integer vectors
## serialize 1:3, XDR: true
parse_rserve_eval('t/data/noatt-123l',
                  Statistics::R::REXP::Integer->new([ 1, 2, 3 ]),
                  'int vector no atts');

## serialize a=1L, b=2L, c=3L, XDR: true
parse_rserve_eval('t/data/abc-123l',
   Statistics::R::REXP::Integer->new(
       elements => [ 1, 2, 3 ],
       attributes => {
           names => Statistics::R::REXP::Character->new(['a', 'b', 'c'])
       }),
   'int vector names att');


## double vectors
## serialize 1234.56, XDR: true
parse_rserve_eval('t/data/noatt-123456',
   Statistics::R::REXP::Double->new([ 1234.56 ]),
   'double vector no atts');

## serialize foo=1234.56, XDR: true
parse_rserve_eval('t/data/foo-123456',
   Statistics::R::REXP::Double->new(
       elements => [ 1234.56 ],
       attributes => {
           names => Statistics::R::REXP::Character->new(['foo'])
       }),
   'double vector names att');


## character vectors
## serialize letters[1:3], XDR: true
parse_rserve_eval('t/data/noatt-abc',
   Statistics::R::REXP::Character->new([ 'a', 'b', 'c' ]),
   'character vector no atts');

## serialize A='a', B='b', C='c', XDR: true
parse_rserve_eval('t/data/ABC-abc',
   Statistics::R::REXP::Character->new(
       elements => [ 'a', 'b', 'c' ],
       attributes => {
           names => Statistics::R::REXP::Character->new(['A', 'B', 'C'])
       }),
   'character vector names att - xdr');


## raw vectors
## serialize as.raw(c(1:3, 255, 0), XDR: true
parse_rserve_eval('t/data/noatt-raw',
   Statistics::R::REXP::Raw->new([ 1, 2, 3, 255, 0 ]),
   'raw vector');


## list (i.e., generic vector)
## serialize list(1:3, list('a', 'b', 11), 'foo'), XDR: true
parse_rserve_eval('t/data/noatt-list',
   Statistics::R::REXP::List->new([
       Statistics::R::REXP::Integer->new([ 1, 2, 3]),
       Statistics::R::REXP::List->new([
           Statistics::R::REXP::Character->new(['a']),
           Statistics::R::REXP::Character->new(['b']),
           Statistics::R::REXP::Double->new([11]) ]),
       Statistics::R::REXP::Character->new(['foo']) ]),
   'generic vector no atts');

## serialize list(foo=1:3, list('a', 'b', 11), bar='foo'), XDR: true
parse_rserve_eval('t/data/foobar-list',
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
parse_rserve_eval('t/data/noatt-mat',
   Statistics::R::REXP::Integer->new(
       elements => [ -1, 0, 1, 2, 3, 4 ],
       attributes => {
           dim => Statistics::R::REXP::Integer->new([2, 3]),
       }),
   'int matrix no atts');

## serialize matrix(-1:4, 2, 3, dimnames=list(c('a', 'b'))), XDR: true
parse_rserve_eval('t/data/ab-mat',
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
parse_rserve_eval('t/data/cars',
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

## serialize head(mtcars)
parse_rserve_eval('t/data/mtcars',
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
parse_rserve_eval('t/data/iris',
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

## serialize lm(mpg ~ wt, data = head(mtcars))
parse_rserve_eval('t/data/mtcars-lm-mpgwt',
   Statistics::R::REXP::List->new(
       elements => [
           # coefficients
           Statistics::R::REXP::Double->new(
               elements => [ 30.3002034730204, -3.27948805566774 ],
               attributes => {
                   names => Statistics::R::REXP::Character->new(['(Intercept)', 'wt'])
               }),
           # residuals
           Statistics::R::REXP::Double->new(
               elements => [ -0.707944767170941, 0.128324687024322, 0.108208816128727,
                             1.64335062595135, -0.318764561523408, -0.853174800410051 ],
               attributes => {
                   names => Statistics::R::REXP::Character->new([
                       "Mazda RX4", "Mazda RX4 Wag",
                       "Datsun 710", "Hornet 4 Drive",
                       "Hornet Sportabout", "Valiant" ])
               }),
           # effects
           Statistics::R::REXP::Double->new(
               elements => [ -50.2145397270552, -3.39713386075597, 0.13375416348722,
                             1.95527848390874, 0.0651588996571721, -0.462851730054076 ],
               attributes => {
                   names => Statistics::R::REXP::Character->new([
                       '(Intercept)', 'wt', '',
                       '', '', '' ])
               }),
           # rank
           Statistics::R::REXP::Integer->new([2]),
           # fitted.values
           Statistics::R::REXP::Double->new(
               elements => [ 21.7079447671709, 20.8716753129757, 22.6917911838713,
                             19.7566493740486, 19.0187645615234, 18.9531748004101  ],
               attributes => {
                   names => Statistics::R::REXP::Character->new([
                       "Mazda RX4", "Mazda RX4 Wag",
                       "Datsun 710", "Hornet 4 Drive",
                       "Hornet Sportabout", "Valiant" ])
               }),
           # assign
           Statistics::R::REXP::Integer->new([0, 1]),
           # qr
           Statistics::R::REXP::List->new(
               elements => [
                   # qr
                   Statistics::R::REXP::Double->new(
                       elements => [ -2.44948974278318, 0.408248290463863,
                                     0.408248290463863, 0.408248290463863,
                                     0.408248290463863, 0.408248290463863,
                                     -7.31989184801706, 1.03587322261623,
                                     0.542107126002057, -0.321898217952644,
                                     -0.539106265315558, -0.558413647303373 ],
                       attributes => {
                           dim => Statistics::R::REXP::Integer->new([ 6, 2 ]),
                           dimnames => Statistics::R::REXP::List->new([
                               Statistics::R::REXP::Character->new([
                                   "Mazda RX4", "Mazda RX4 Wag",
                                   "Datsun 710", "Hornet 4 Drive",
                                   "Hornet Sportabout", "Valiant" ]),
                               Statistics::R::REXP::Character->new([
                                   '(Intercept)', 'wt' ])
                               ]),
                           assign => Statistics::R::REXP::Integer->new([
                               0, 1
                           ]),
                       }),
                   # qraux
                   Statistics::R::REXP::Double->new(
                       [ 1.40824829046386, 1.0063272758402 ]),
                   # pivot
                   Statistics::R::REXP::Integer->new([1, 2]),
                   # tol
                   Statistics::R::REXP::Double->new([1E-7]),
                   # rank
                   Statistics::R::REXP::Integer->new([2]),
               ],
               attributes => {
                   names => Statistics::R::REXP::Character->new([
                       "qr", "qraux", "pivot",
                       "tol", "rank" ]),
                   class => Statistics::R::REXP::Character->new(['qr'])
               }),
           # df.residual
           Statistics::R::REXP::Integer->new([4]),
           # xlevels
           Statistics::R::REXP::List->new(
               elements => [],
               attributes => {
                   names => Statistics::R::REXP::Character->new([])
               }),
           # call
           Statistics::R::REXP::Language->new(
               elements => [
                   Statistics::R::REXP::Symbol->new('lm'),
                   Statistics::R::REXP::Language->new(
                       elements => [
                           Statistics::R::REXP::Symbol->new('~'),
                           Statistics::R::REXP::Symbol->new('mpg'),
                           Statistics::R::REXP::Symbol->new('wt'),
                       ]),
                   Statistics::R::REXP::Language->new(
                       elements => [
                           Statistics::R::REXP::Symbol->new('head'),
                           Statistics::R::REXP::Symbol->new('mtcars'),
                       ]),
               ],
               attributes => {
                   names => Statistics::R::REXP::Character->new([
                       '', 'formula', 'data' ])
               }),
           # terms
           Statistics::R::REXP::Language->new(
               elements => [
                   Statistics::R::REXP::Symbol->new('~'),
                   Statistics::R::REXP::Symbol->new('mpg'),
                   Statistics::R::REXP::Symbol->new('wt'),
               ],
               attributes => {
                   variables => Statistics::R::REXP::Language->new(
                       elements => [
                           Statistics::R::REXP::Symbol->new('list'),
                           Statistics::R::REXP::Symbol->new('mpg'),
                           Statistics::R::REXP::Symbol->new('wt'),
                       ]),
                   factors => Statistics::R::REXP::Integer->new(
                       elements => [ 0, 1 ],
                       attributes => {
                           dim => Statistics::R::REXP::Integer->new([ 2, 1 ]),
                           dimnames => Statistics::R::REXP::List->new([
                               Statistics::R::REXP::Character->new([
                                   'mpg', 'wt' ]),
                               Statistics::R::REXP::Character->new([ 'wt' ]),
                           ]),
                       }),
                   'term.labels' => Statistics::R::REXP::Character->new(['wt']),
                   order => Statistics::R::REXP::Integer->new([1]),
                   intercept => Statistics::R::REXP::Integer->new([1]),
                   response => Statistics::R::REXP::Integer->new([1]),
                   class => Statistics::R::REXP::Character->new([
                       'terms', 'formula'
                   ]),
                   '.Environment' => Statistics::R::REXP::GlobalEnvironment->new,
                   predvars => Statistics::R::REXP::Language->new(
                       elements => [
                           Statistics::R::REXP::Symbol->new('list'),
                           Statistics::R::REXP::Symbol->new('mpg'),
                           Statistics::R::REXP::Symbol->new('wt'),
                       ]),
                   dataClasses => Statistics::R::REXP::Character->new(
                       elements => ['numeric', 'numeric'],
                       attributes => {
                           names => Statistics::R::REXP::Character->new(['mpg', 'wt'])
                       }),
               }),
           # model
           Statistics::R::REXP::List->new(
               elements => [
                   Statistics::R::REXP::Double->new([ 21.0, 21.0, 22.8, 21.4, 18.7, 18.1 ]),
                   Statistics::R::REXP::Double->new([ 2.62, 2.875, 2.32, 3.215, 3.44, 3.46 ]),
               ],
               attributes => {
                   names => Statistics::R::REXP::Character->new(['mpg', 'wt']),
                   'row.names' => Statistics::R::REXP::Character->new([
                       'Mazda RX4', 'Mazda RX4 Wag', 'Datsun 710',
                       'Hornet 4 Drive', 'Hornet Sportabout', 'Valiant']),
                   class => Statistics::R::REXP::Character->new(['data.frame']),
                   terms => Statistics::R::REXP::Language->new(
                       elements => [
                           Statistics::R::REXP::Symbol->new('~'),
                           Statistics::R::REXP::Symbol->new('mpg'),
                           Statistics::R::REXP::Symbol->new('wt'),
                       ],
                       attributes => {
                           variables => Statistics::R::REXP::Language->new(
                               elements => [
                                   Statistics::R::REXP::Symbol->new('list'),
                                   Statistics::R::REXP::Symbol->new('mpg'),
                                   Statistics::R::REXP::Symbol->new('wt'),
                               ]),
                           factors => Statistics::R::REXP::Integer->new(
                               elements => [ 0, 1 ],
                               attributes => {
                                   dim => Statistics::R::REXP::Integer->new([ 2, 1 ]),
                                   dimnames => Statistics::R::REXP::List->new([
                                       Statistics::R::REXP::Character->new([
                                           'mpg', 'wt' ]),
                                       Statistics::R::REXP::Character->new([ 'wt' ]),
                                   ]),
                               }),
                           'term.labels' => Statistics::R::REXP::Character->new(['wt']),
                           order => Statistics::R::REXP::Integer->new([1]),
                           intercept => Statistics::R::REXP::Integer->new([1]),
                           response => Statistics::R::REXP::Integer->new([1]),
                           class => Statistics::R::REXP::Character->new([
                               'terms', 'formula'
                           ]),
                           '.Environment' => Statistics::R::REXP::GlobalEnvironment->new,
                           predvars => Statistics::R::REXP::Language->new(
                               elements => [
                                   Statistics::R::REXP::Symbol->new('list'),
                                   Statistics::R::REXP::Symbol->new('mpg'),
                                   Statistics::R::REXP::Symbol->new('wt'),
                               ]),
                           dataClasses => Statistics::R::REXP::Character->new(
                               elements => ['numeric', 'numeric'],
                               attributes => {
                                   names => Statistics::R::REXP::Character->new(['mpg', 'wt'])
                               }),
                       }),
               }),
       ],
       attributes => {
           names => Statistics::R::REXP::Character->new([
               'coefficients', 'residuals', 'effects', 'rank',
               'fitted.values', 'assign', 'qr', 'df.residual',
               'xlevels', 'call', 'terms', 'model',
           ]),
           class => Statistics::R::REXP::Character->new(['lm']) }),
   'lm mpg~wt, head(mtcars)');


## Server error
my $error_mock = Test::MockObject::Extends->new('IO::Socket');
$error_mock->mock('syswrite',
                  sub {
                      my ($self, $data) = (shift, shift);
                      length($data);
                  });
$error_mock->mock('sysread',
                  sub {
                      # args: self, $data, length
                      $_[1] = pack('VVA*', 123, 0, "\0"x8);
                      0
                  });

like(exception {
    evalRserve('testing, please ignore',
               $error_mock),
     }, qr/Server returned an error: 123/,
    'server error');
