#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 41;
use Test::Fatal;

use Statistics::R::IO::Parser qw(:all);
use Statistics::R::IO::ParserState;
use Statistics::R::IO::REXPFactory qw(:all);


## integer vectors

## serialize 1:3, XDR: true
my $noatt_123_xdr = Statistics::R::IO::ParserState->new(
    data => "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x0d\0\0\0\5" .
    "\xff\xff\xff\xff" . "\0\0\0\0" . "\0\0\0\1" . "\0\0\0\2" . "\0\0\0\3");

is_deeply(Statistics::R::IO::REXPFactory::header->($noatt_123_xdr)->[0],
          [ "X\n", 2, 0x030002, 0x020300 ],
          'XDR header');

is_deeply(bind(Statistics::R::IO::REXPFactory::header,
               sub {
                   Statistics::R::IO::REXPFactory::unpack_object_info
               })->($noatt_123_xdr)->[0],
          { is_object => 0,
            has_attributes => 0,
            has_tag => 0,
            object_type => 13,
            levels => 0,
            flags => 13},
          'header plus object info - int vector no atts');

is(unserialize($noatt_123_xdr->data)->[0],
   Statistics::R::REXP::Integer->new([ -1, 0, 1, 2, 3 ]),
   'int vector no atts');

## serialize 1:3, XDR: false
my $noatt_123_bin = Statistics::R::IO::ParserState->new(
    data => "\x42\x0a\2\0\0\0\2\0\3\0\0\3\2\0\x0d\0\0\0\5\0\0\0" .
    "\xff\xff\xff\xff" . "\0\0\0\0" . "\1\0\0\0" . "\2\0\0\0" . "\3\0\0\0");

is_deeply(Statistics::R::IO::REXPFactory::header->($noatt_123_bin)->[0],
          [ "B\n", 2, 0x030002, 0x020300 ],
          'binary header');

is_deeply(bind(Statistics::R::IO::REXPFactory::header,
               sub {
                   Statistics::R::IO::REXPFactory::unpack_object_info
               })->($noatt_123_bin)->[0],
          { is_object => 0,
            has_attributes => 0,
            has_tag => 0,
            object_type => 13,
            levels => 0,
            flags => 13 },
          'binary header plus object info - int vector no atts');

is(unserialize($noatt_123_bin->data)->[0],
   Statistics::R::REXP::Integer->new([ -1, 0, 1, 2, 3 ]),
   'int vector no atts - binary');


## serialize a=1L, b=2L, c=3L, XDR: true
my $abc_123l_xdr = "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\2\x0d\0\0\0\3\0\0\0" .
    "\1\0\0\0\2\0\0\0\3\0\0\4\2\0\0\0\1\0\4\0\x09\0\0\0\5" .
    "\x6e\x61\x6d\x65\x73\0\0\0\x10\0\0\0\3\0\4\0\x09\0\0\0\1\x61\0\4\0" .
    "\x09\0\0\0\1\x62\0\4\0\x09\0\0\0\1\x63\0\0\0\xfe";

is(unserialize($abc_123l_xdr)->[0],
   Statistics::R::REXP::Integer->new(
       elements => [ 1, 2, 3 ],
       attributes => { names => ['a', 'b', 'c'] }),
   'int vector names att - xdr');


## handling of negative integer vector length
like(exception {
        unserialize("\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x0d\xff\xff\xff\xff" .
                    "\0\0\0\0" . "\0\0\0\1")
     }, qr/TODO: Long vectors are not supported/, 'long integer vector length');

like(exception {
        unserialize("\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x0d\xff\xff\xff\x0")
     }, qr/Negative length/, 'negative integer vector length');


## double vectors
## serialize 1234.56, XDR: true
my $noatt_123456_xdr = Statistics::R::IO::ParserState->new(
    data => "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x0e\0\0\0\1\x40\x93\x4a".
    "\x3d\x70\xa3\xd7\x0a");

is_deeply(bind(Statistics::R::IO::REXPFactory::header,
               sub {
                   Statistics::R::IO::REXPFactory::unpack_object_info
               })->($noatt_123456_xdr)->[0],
          { is_object => 0,
            has_attributes => 0,
            has_tag => 0,
            object_type => 14,
            levels => 0,
            flags => 14 },
          'header plus object info - double vector no atts');

is(unserialize($noatt_123456_xdr->data)->[0],
   Statistics::R::REXP::Double->new([ 1234.56 ]),
   'double vector no atts');


## serialize 1234.56, XDR: false
my $noatt_123456_bin = Statistics::R::IO::ParserState->new(
    data => "\x42\x0a\2\0\0\0\2\0\3\0\0\3\2\0\x0e\0\0\0\1\0\0\0\x0a\xd7\xa3".
    "\x70\x3d\x4a\x93\x40");

is_deeply(bind(Statistics::R::IO::REXPFactory::header,
               sub {
                   Statistics::R::IO::REXPFactory::unpack_object_info
               })->($noatt_123456_bin)->[0],
          { is_object => 0,
            has_attributes => 0,
            has_tag => 0,
            object_type => 14,
            levels => 0,
            flags => 14 },
          'binary header plus object info - double vector no atts');

is(unserialize($noatt_123456_bin->data)->[0],
   Statistics::R::REXP::Double->new([ 1234.56 ]),
   'double vector no atts - binary');


## serialize foo=1234.56, XDR: true
my $foo_123456_xdr = "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\2\x0e\0\0\0\1\x40\x93\x4a" .
    "\x3d\x70\xa3\xd7\x0a\0\0\4\2\0\0\0\1\0\4\0\x09\0\0\0\5\x6e\x61\x6d\x65" .
    "\x73\0\0\0\x10\0\0\0\1\0\4\0\x09\0\0\0\3\x66\x6f\x6f\0\0\0\xfe";

is(unserialize($foo_123456_xdr)->[0],
   Statistics::R::REXP::Double->new(
       elements => [ 1234.56 ],
       attributes => { names => ['foo'] }),
   'double vector names att - xdr');


## handling of negative double vector length
like(exception {
        unserialize("\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x0e\xff\xff\xff\xff" .
                    "\0\0\0\0" . "\0\0\0\1")
     }, qr/TODO: Long vectors are not supported/, 'long double vector length');

like(exception {
        unserialize("\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x0e\xff\xff\xff\x0")
     }, qr/Negative length/, 'negative double vector length');


## character vectors
## serialize letters[1:3], XDR: true
my $noatt_abc_xdr = Statistics::R::IO::ParserState->new(
    data => "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x10\0\0\0\3\0\4\0" .
    "\x09\0\0\0\1\x61\0\4\0\x09\0\0\0\1\x62\0\4\0\x09\0\0\0\1\x63");

is_deeply(bind(Statistics::R::IO::REXPFactory::header,
               sub {
                   Statistics::R::IO::REXPFactory::unpack_object_info
               })->($noatt_abc_xdr)->[0],
          { is_object => 0,
            has_attributes => 0,
            has_tag => 0,
            object_type => 16,
            levels => 0,
            flags => 16 },
          'header plus object info - character vector no atts');

is(unserialize($noatt_abc_xdr->data)->[0],
   Statistics::R::REXP::Character->new([ 'a', 'b', 'c' ]),
   'character vector no atts');


## serialize A='a', B='b', C='c', XDR: true
my $ABC_abc_xdr = "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\2\x10\0\0\0\3\0\4\0" .
    "\x09\0\0\0\1\x61\0\4\0\x09\0\0\0\1\x62\0\4\0\x09\0\0\0\1\x63\0" .
    "\0\4\2\0\0\0\1\0\4\0\x09\0\0\0\5\x6e\x61\x6d\x65\x73\0\0\0\x10\0" .
    "\0\0\3\0\4\0\x09\0\0\0\1\x41\0\4\0\x09\0\0\0\1\x42\0\4\0\x09" .
    "\0\0\0\1\x43\0\0\0\xfe";

is(unserialize($ABC_abc_xdr)->[0],
   Statistics::R::REXP::Character->new(
       elements => [ 'a', 'b', 'c' ],
       attributes => { names => ['A', 'B', 'C'] }),
   'character vector names att - xdr');


## handling of negative character vector length
like(exception {
        unserialize("\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x10\xff\xff\xff\xff" .
                    "\0\0\0\0" . "\0\0\0\1")
     }, qr/TODO: Long vectors are not supported/, 'long character vector length');

like(exception {
        unserialize("\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x10\xff\xff\xff\x0")
     }, qr/Negative length/, 'negative character vector length');


## handling of negative charsxp length
like(exception {
        unserialize("\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x10\0\0\0\1".
            "\0\4\0\x09" . "\xff\xff\xff\xff")
     }, qr/TODO: NA charsxp/, 'NA_STRING');

like(exception {
        unserialize("\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x10\0\0\0\1".
            "\0\4\0\x09" . "\xff\xff\xff\xf0")
     }, qr/Negative length/, 'negative charsxp length');


## raw vectors
## serialize as.raw(c(1:3, 255, 0), XDR: true
my $noatt_raw_xdr = "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x18\0\0\0\5" .
    "\1\2\3\xff\0";

is(unserialize($noatt_raw_xdr)->[0],
   Statistics::R::REXP::Raw->new([ 1, 2, 3, 255, 0 ]),
   'raw vector');

my $noatt_raw_bin = "\x42\x0a\2\0\0\0\2\0\3\0\0\3\2\0\x18\0\0\0\5\0\0\0" .
    "\1\2\3\xff\0";

is(unserialize($noatt_raw_bin)->[0],
   Statistics::R::REXP::Raw->new([ 1, 2, 3, 255, 0 ]),
   'raw vector');


## handling of negative raw vector length
like(exception {
        unserialize("\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x18\xff\xff\xff\xff" .
                    "\0\0\0\0" . "\0\0\0\1")
     }, qr/TODO: Long vectors are not supported/, 'long raw vector length');

like(exception {
        unserialize("\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x18\xff\xff\xff\x0")
     }, qr/Negative length/, 'negative raw vector length');


## list (i.e., generic vector)
## serialize list(1:3, list('a', 'b', 11), 'foo'), XDR: true
my $noatt_list_xdr = Statistics::R::IO::ParserState->new(
    data => "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x13\0\0\0\3\0\0\0" .
    "\x0d\0\0\0\3\0\0\0\1\0\0\0\2\0\0\0\3\0\0\0\x13\0\0\0\3" .
    "\0\0\0\x10\0\0\0\1\0\4\0\x09\0\0\0\1\x61\0\0\0\x10\0\0\0\1" .
    "\0\4\0\x09\0\0\0\1\x62\0\0\0\x0e\0\0\0\1\x40\x26\0\0\0\0\0\0" .
    "\0\0\0\x10\0\0\0\1\0\4\0\x09\0\0\0\3\x66\x6f\x6f");

is_deeply(bind(Statistics::R::IO::REXPFactory::header,
               sub {
                   Statistics::R::IO::REXPFactory::unpack_object_info
               })->($noatt_list_xdr)->[0],
          { is_object => 0,
            has_attributes => 0,
            has_tag => 0,
            object_type => 19,
            levels => 0,
            flags => 19 },
          'header plus object info - generic vector no atts');

is(unserialize($noatt_list_xdr->data)->[0],
   Statistics::R::REXP::List->new([
       Statistics::R::REXP::Integer->new([ 1, 2, 3]),
       Statistics::R::REXP::List->new([
           Statistics::R::REXP::Character->new(['a']),
           Statistics::R::REXP::Character->new(['b']),
           Statistics::R::REXP::Double->new([11]) ]),
       Statistics::R::REXP::Character->new(['foo']) ]),
   'generic vector no atts');


## serialize list(foo=1:3, list('a', 'b', 11), bar='foo'), XDR: true
my $foobar_list_xdr = "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\2\x13\0\0\0\3\0\0\0" .
    "\x0d\0\0\0\3\0\0\0\1\0\0\0\2\0\0\0\3\0\0\0\x13\0\0\0\3" .
    "\0\0\0\x10\0\0\0\1\0\4\0\x09\0\0\0\1\x61\0\0\0\x10\0\0\0\1" .
    "\0\4\0\x09\0\0\0\1\x62\0\0\0\x0e\0\0\0\1\x40\x26\0\0\0\0\0\0" .
    "\0\0\0\x10\0\0\0\1\0\4\0\x09\0\0\0\3\x66\x6f\x6f\0\0\4\2\0\0" .
    "\0\1\0\4\0\x09\0\0\0\5\x6e\x61\x6d\x65\x73\0\0\0\x10\0\0\0\3\0\4" .
    "\0\x09\0\0\0\3\x66\x6f\x6f\0\4\0\x09\0\0\0\0\0\4\0\x09\0\0\0\3" .
    "\x62\x61\x72\0\0\0\xfe";


is(unserialize($foobar_list_xdr)->[0],
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


## handling of negative generic vector length
like(exception {
        unserialize("\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x13\xff\xff\xff\xff" .
                    "\0\0\0\0" . "\0\0\0\1")
     }, qr/TODO: Long vectors are not supported/, 'long generic vector length');

like(exception {
        unserialize("\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x13\xff\xff\xff\x0")
     }, qr/Negative length/, 'negative generic vector length');


## matrix

## serialize matrix(-1:4, 2, 3), XDR: true
my $noatt_mat_xdr =
    "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\2\x0d\0\0\0\6\xff\xff\xff" .
    "\xff\0\0\0\0\0\0\0\1\0\0\0\2\0\0\0\3\0\0\0\4\0\0\4\2" .
    "\0\0\0\1\0\4\0\x09\0\0\0\3\x64\x69\x6d\0\0\0\x0d\0\0\0\2\0\0" .
    "\0\2\0\0\0\3\0\0\0\xfe";
is(unserialize($noatt_mat_xdr)->[0],
   Statistics::R::REXP::Integer->new(
       elements => [ -1, 0, 1, 2, 3, 4 ],
   attributes => { dim => [2, 3] }),
   'int matrix no atts');

## serialize matrix(-1:4, 2, 3), XDR: false
my $noatt_mat_noxdr =
    "\x42\x0a\2\0\0\0\2\0\3\0\0\3\2\0\x0d\2\0\0\6\0\0\0\xff\xff\xff" .
    "\xff\0\0\0\0\1\0\0\0\2\0\0\0\3\0\0\0\4\0\0\0\2\4\0\0" .
    "\1\0\0\0\x09\0\4\0\3\0\0\0\x64\x69\x6d\x0d\0\0\0\2\0\0\0\2\0" .
    "\0\0\3\0\0\0\xfe\0\0\0";
is(unserialize($noatt_mat_noxdr)->[0],
   Statistics::R::REXP::Integer->new(
       elements => [ -1, 0, 1, 2, 3, 4 ],
   attributes => { dim => [2, 3] }),
   'int matrix no atts - binary');

## serialize matrix(-1:4, 2, 3, dimnames=list(c('a', 'b'))), XDR: true
my $ab_mat_xdr =
    "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\2\x0d\0\0\0\6\xff\xff\xff" .
    "\xff\0\0\0\0\0\0\0\1\0\0\0\2\0\0\0\3\0\0\0\4\0\0\4\2" .
    "\0\0\0\1\0\4\0\x09\0\0\0\3\x64\x69\x6d\0\0\0\x0d\0\0\0\2\0\0" .
    "\0\2\0\0\0\3\0\0\4\2\0\0\0\1\0\4\0\x09\0\0\0\x08\x64\x69\x6d" .
    "\x6e\x61\x6d\x65\x73\0\0\0\x13\0\0\0\2\0\0\0\x10\0\0\0\2\0\4\0\x09" .
    "\0\0\0\1\x61\0\4\0\x09\0\0\0\1\x62\0\0\0\xfe\0\0\0\xfe";
is(unserialize($ab_mat_xdr)->[0],
   Statistics::R::REXP::Integer->new(
       elements => [ -1, 0, 1, 2, 3, 4 ],
   attributes => { dim => [2, 3],
                   dimnames => [ ['a', 'b'],
                                 undef ] }),
   'int matrix rownames');


## pairlist

my $names_attribute_pairlist = Statistics::R::IO::ParserState->new(
    data => "\0\0\4\2\0\0\0\1\0\4\0\x09\0\0\0\5".
    "\x6e\x61\x6d\x65\x73\0\0\0\x10\0\0\0\3\0\4\0\x09\0\0\0\1\x61\0\4\0".
    "\x09\0\0\0\1\x62\0\4\0\x09\0\0\0\1\x63\0\0\0\xfe");

is_deeply(Statistics::R::IO::REXPFactory::unpack_object_info->($names_attribute_pairlist)->[0],
          { is_object => 0,
            has_attributes => 0,
            has_tag => 1<<10,
            object_type => 2,
            levels => 0,
            flags => 1026 },
          'object info - names attribute pairlist');

is_deeply(Statistics::R::IO::REXPFactory::object_content->($names_attribute_pairlist)->[0],
          [ { tag => Statistics::R::REXP::Symbol->new('names'),
              value => Statistics::R::REXP::Character->new([ 'a', 'b', 'c' ]) } ],
          'names attribute pairlist');


## a more complicated pairlist:
## attributes from a matrix(1:6, 2, 3, dimnames=list(c('a', 'b'))),
## i.e., dims = c(2,3) and dimnames = list(c('a', 'b'), NULL)
my $matrix_dims_attribute_pairlist = Statistics::R::IO::ParserState->new(
    data => "\0\0\4\2" .
    "\0\0\0\1\0\4\0\x09\0\0\0\3\x64\x69\x6d\0\0\0\x0d\0\0\0\2\0\0" .
    "\0\2\0\0\0\3\0\0\4\2\0\0\0\1\0\4\0\x09\0\0\0\x08\x64\x69\x6d" .
    "\x6e\x61\x6d\x65\x73\0\0\0\x13\0\0\0\2\0\0\0\x10\0\0\0\2\0\4\0\x09" .
    "\0\0\0\1\x61\0\4\0\x09\0\0\0\1\x62\0\0\0\xfe\0\0\0\xfe");

is_deeply(Statistics::R::IO::REXPFactory::unpack_object_info->($matrix_dims_attribute_pairlist)->[0],
          { is_object => 0,
            has_attributes => 0,
            has_tag => 1<<10,
            object_type => 2,
            levels => 0,
            flags => 1026 },
          'object info - matrix dims attribute pairlist');

is_deeply(Statistics::R::IO::REXPFactory::object_content->($matrix_dims_attribute_pairlist)->[0],
          [ { tag => Statistics::R::REXP::Symbol->new('dim'),
              value => Statistics::R::REXP::Integer->new([ 2, 3 ]) },
            { tag => Statistics::R::REXP::Symbol->new('dimnames'),
              value => Statistics::R::REXP::List->new([
                  Statistics::R::REXP::Character->new([ 'a', 'b' ]),
                  Statistics::R::REXP::Null->new ]) } ],
          'matrix dims attribute pairlist');

## yet more complicated pairlist:
## attributes from the head of the 'cars' data frame,
## i.e., names = ['speed', 'dist'], row.names = 1..6, class = 'data.frame'
my $cars_attribute_pairlist = Statistics::R::IO::ParserState->new(
    data => "\0\0\4\2" .
    "\0\0\0\1\0\4\0\x09\0\0\0\5" .
    "\x6e\x61\x6d\x65\x73\0\0\0\x10\0\0\0\2\0\4\0\x09\0\0\0\5\x73\x70\x65\x65" .
    "\x64\0\4\0\x09\0\0\0\4\x64\x69\x73\x74\0\0\4\2\0\0\0\1\0\4\0\x09" .
    "\0\0\0\x09\x72\x6f\x77\x2e\x6e\x61\x6d\x65\x73\0\0\0\x0d\0\0\0\2\x80\0\0\0" .
    "\0\0\0\6\0\0\4\2\0\0\0\1\0\4\0\x09\0\0\0\5\x63\x6c\x61\x73\x73" .
    "\0\0\0\x10\0\0\0\1\0\4\0\x09\0\0\0\x0a\x64\x61\x74\x61\x2e\x66\x72\x61\x6d" .
    "\x65\0\0\0\xfe");

is_deeply(Statistics::R::IO::REXPFactory::object_content->($cars_attribute_pairlist)->[0],
          [ { tag => Statistics::R::REXP::Symbol->new('names'),
              value => Statistics::R::REXP::Character->new([ 'speed', 'dist' ]) },
            { tag => Statistics::R::REXP::Symbol->new('row.names'), # compact encoding
              value => Statistics::R::REXP::Integer->new([ -(1<<31), 6 ]) },
            { tag => Statistics::R::REXP::Symbol->new('class'),
              value => Statistics::R::REXP::Character->new([ 'data.frame' ]) },
          ],
          'cars dataframe attribute pairlist');


## data frames
my $mtcars_xdr =
    "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\3\x13\0\0\0\2\0\0\0" .
    "\x0e\0\0\0\6\x40\x10\0\0\0\0\0\0\x40\x10\0\0\0\0\0\0\x40\x1c\0\0" .
    "\0\0\0\0\x40\x1c\0\0\0\0\0\0\x40\x20\0\0\0\0\0\0\x40\x22\0\0\0" .
    "\0\0\0\0\0\0\x0e\0\0\0\6\x40\0\0\0\0\0\0\0\x40\x24\0\0\0\0" .
    "\0\0\x40\x10\0\0\0\0\0\0\x40\x36\0\0\0\0\0\0\x40\x30\0\0\0\0\0" .
    "\0\x40\x24\0\0\0\0\0\0\0\0\4\2\0\0\0\1\0\4\0\x09\0\0\0\5" .
    "\x6e\x61\x6d\x65\x73\0\0\0\x10\0\0\0\2\0\4\0\x09\0\0\0\5\x73\x70\x65\x65" .
    "\x64\0\4\0\x09\0\0\0\4\x64\x69\x73\x74\0\0\4\2\0\0\0\1\0\4\0\x09" .
    "\0\0\0\x09\x72\x6f\x77\x2e\x6e\x61\x6d\x65\x73\0\0\0\x0d\0\0\0\2\x80\0\0\0" .
    "\0\0\0\6\0\0\4\2\0\0\0\1\0\4\0\x09\0\0\0\5\x63\x6c\x61\x73\x73" .
    "\0\0\0\x10\0\0\0\1\0\4\0\x09\0\0\0\x0a\x64\x61\x74\x61\x2e\x66\x72\x61\x6d" .
    "\x65\0\0\0\xfe";
is(unserialize($mtcars_xdr)->[0],
   Statistics::R::REXP::List->new(
       elements => [
           Statistics::R::REXP::Double->new([ 4, 4, 7, 7, 8, 9]),
           Statistics::R::REXP::Double->new([ 2, 10, 4, 22, 16, 10]),
       ],
       attributes => {names => ['speed', 'dist'],
                      'row.names' => [1, 2, 3, 4, 5, 6],
                      class => ['data.frame'] }),
   'the cars data frame');
