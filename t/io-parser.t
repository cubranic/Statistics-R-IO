#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 45;
use Test::Fatal;

use Statistics::R::IO::Parser qw(:all);
use Statistics::R::IO::ParserState;

my $state = Statistics::R::IO::ParserState->new(data => 'foobar');

## any_char parser
is_deeply(any_char($state),
          ['f',
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                           position => 1)],
          'any_char');
is_deeply(any_char($state->next->next->next->next->next->next),
          undef,
          'any_char at eof');

## char parser
my $f_char = char('f');

is_deeply($f_char->($state),
          ['f',
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                               position => 1)],
          'char');
is($f_char->($state->next),
   undef, 'char doesn\'t match');
is($f_char->($state->next->next->next->next->next->next),
   undef, 'char at eof');
like(exception { char('foo') },
     qr/Must be a single-char argument/, "bad 'char' argument");


## string parser
my $foo_string = string('foo');

is_deeply($foo_string->($state),
          ['foo',
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                               position => 3)],
          'string');
is($foo_string->($state->next),
   undef, 'string doesn\'t match');
is($foo_string->($state->next->next->next->next->next->next),
   undef, 'string at eof');
like(exception { string(['foo']) },
     qr/Must be a scalar argument/, "bad 'string' argument");


## byte parser
my $f_byte = byte(ord('f'));

is_deeply($f_byte->($state),
          [ord('f'),
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                               position => 1)],
          'byte');
is($f_byte->($state->next),
   undef, 'byte doesn\'t match');
is($f_byte->($state->next->next->next->next->next->next),
   undef, 'byte at eof');
like(exception { byte('f') },
     qr/Argument must be a number 0-255/, "bad 'byte' argument");


## count combinator
is_deeply(count(3, \&any_char)->($state),
          [['f', 'o', 'o'],
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                           position => 3)],
          'count 3 any_char');

is_deeply(count(0, \&any_char)->($state),
          [[],
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                               position => 0)],
          'count 0 any_char');

is(count(7, \&any_char)->($state), undef,
   'count fails');


## int parsers
my $num_state = Statistics::R::IO::ParserState->new(data => pack('N', 0x12345678));
is(any_uint8($num_state)->[0], 0x12,
   'any_uint8');
is(any_uint8(any_uint8($num_state)->[1])->[0], 0x34,
   'second any_uint8');

is(any_uint16($num_state)->[0], 0x1234,
   'any_uint16');
is(any_uint16(any_uint16($num_state)->[1])->[0], 0x5678,
   'second any_uint16');

is(any_uint24($num_state)->[0], 0x123456,
   'any_uint24');
is(any_uint24(any_uint24($num_state)->[1]), undef,
   'second any_uint24');

is(any_uint32($num_state)->[0], 0x12345678,
   'any_uint32');
is(any_uint32(any_uint32($num_state)->[1]), undef,
   'second any_uint32');


## floating point parsers
is(any_real32(Statistics::R::IO::ParserState->new(data => "\x45\xcc\x79\0"))->[0],
   6543.125, 'any_real32');

is(any_real64(Statistics::R::IO::ParserState->new(data => "\x40\x93\x4a\x45\x6d\x5c\xfa\xad"))->[0],
   1234.5678, 'any_real64');


## endianness
is(endianness, '>',
   'get endianness');
is(endianness('<'), '<',
   'set endianness');
is(endianness('bla'), '<',
   'ignore bad endianness value');

is(any_uint16($num_state)->[0], 0x3412,
   'any_uint16 little endian');
is(any_uint16(any_uint16($num_state)->[1])->[0], 0x7856,
   'second any_uint16 little endian');

is(any_uint24($num_state)->[0], 0x563412,
   'any_uint24 little endian');
is(any_uint24(any_uint24($num_state)->[1]), undef,
   'second any_uint24 little endian');

is(any_uint32($num_state)->[0], 0x78563412,
   'any_uint32 little endian');
is(any_uint32(any_uint32($num_state)->[1]), undef,
   'second any_uint32 little endian');

is(any_real32(Statistics::R::IO::ParserState->new(data => "\0\x79\xcc\x45"))->[0],
   6543.125, 'any_real32 little endian');

is(any_real64(Statistics::R::IO::ParserState->new(data => "\xad\xfa\x5c\x6d\x45\x4a\x93\x40"))->[0],
   1234.5678, 'any_real64 little endian');


## seq combinator
my $f_oob_seq = seq(char('f'),
                                               string('oob'));
is_deeply($f_oob_seq->($state),
          [['f', 'oob'],
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                               position => 4)],
          'seq');
is($f_oob_seq->($state->next),
   undef, 'seq fails');


## choose combinator
my $f_oob_choose = choose(char('f'),
                                                     string('oob'),
                                                     char('o'));
is_deeply($f_oob_choose->($state),
          ['f',
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                               position => 1)],
          'seq first');
is_deeply($f_oob_choose->($state->next),
          ['oob',
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                               position => 4)],
          'seq second');
is($f_oob_choose->($state->next->next->next),
   undef, 'choose fails');


## bind combinator
my $len_chars_bind = bind(
    \&any_uint8,
    sub {
        my $n = shift or return;
        count($n, \&any_uint8)
    });

is_deeply($len_chars_bind->(Statistics::R::IO::ParserState->new(data => "\3\x2a\7\0"))->[0],
          [42, 7, 0],
          'bind');
is($len_chars_bind->(Statistics::R::IO::ParserState->new(data => "\3\x2a\7")),
   undef, 'bind fails');
