#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 30;
use Test::Fatal;

use Statistics::R::IO::Parser;
use Statistics::R::IO::ParserState;

my $state = Statistics::R::IO::ParserState->new(data => 'foobar');

## any_char parser
is_deeply(Statistics::R::IO::Parser::any_char($state),
          ['f',
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                           position => 1)],
          'any_char');
is_deeply(Statistics::R::IO::Parser::any_char($state->next->next->next->next->next->next),
          undef,
          'any_char at eof');

## char parser
my $f_char = Statistics::R::IO::Parser::char('f');

is_deeply($f_char->($state),
          ['f',
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                               position => 1)],
          'char');
is($f_char->($state->next),
          undef,
          'char doesn\'t match');
is($f_char->($state->next->next->next->next->next->next),
          undef,
          'char at eof');
like(exception { Statistics::R::IO::Parser::char('foo') },
     qr/Must be a single-char argument/, "bad 'char' argument");

## count combinator
is_deeply(Statistics::R::IO::Parser::count(3, \&Statistics::R::IO::Parser::any_char)->($state),
          [['f', 'o', 'o'],
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                           position => 3)],
          'count 3 any_char');

is_deeply(Statistics::R::IO::Parser::count(0, \&Statistics::R::IO::Parser::any_char)->($state),
          [[],
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                               position => 0)],
          'count 0 any_char');

is(Statistics::R::IO::Parser::count(7, \&Statistics::R::IO::Parser::any_char)->($state), undef,
   'count fails');


## int parsers
my $num_state = Statistics::R::IO::ParserState->new(data => pack('N', 0x12345678));
is(Statistics::R::IO::Parser::uint8($num_state)->[0], 0x12,
   'uint8');
is(Statistics::R::IO::Parser::uint8(Statistics::R::IO::Parser::uint8($num_state)->[1])->[0], 0x34,
   'second uint8');

is(Statistics::R::IO::Parser::uint16($num_state)->[0], 0x1234,
   'uint16');
is(Statistics::R::IO::Parser::uint16(Statistics::R::IO::Parser::uint16($num_state)->[1])->[0], 0x5678,
   'second uint16');

is(Statistics::R::IO::Parser::uint24($num_state)->[0], 0x123456,
   'uint24');
is(Statistics::R::IO::Parser::uint24(Statistics::R::IO::Parser::uint24($num_state)->[1]), undef,
   'second uint24');

is(Statistics::R::IO::Parser::uint32($num_state)->[0], 0x12345678,
   'uint32');
is(Statistics::R::IO::Parser::uint32(Statistics::R::IO::Parser::uint32($num_state)->[1]), undef,
   'second uint32');


## floating point parsers
is(Statistics::R::IO::Parser::real32(Statistics::R::IO::ParserState->new(data => "\x45\xcc\x79\0"))->[0],
   6543.125, 'real32');

is(Statistics::R::IO::Parser::real64(Statistics::R::IO::ParserState->new(data => "\x40\x93\x4a\x45\x6d\x5c\xfa\xad"))->[0],
   1234.5678, 'real64');


## endianness
is(Statistics::R::IO::Parser::endianness, '>',
   'get endianness');
is(Statistics::R::IO::Parser::endianness('<'), '<',
   'set endianness');
is(Statistics::R::IO::Parser::endianness('bla'), '<',
   'ignore bad endianness value');

is(Statistics::R::IO::Parser::uint16($num_state)->[0], 0x3412,
   'uint16 little endian');
is(Statistics::R::IO::Parser::uint16(Statistics::R::IO::Parser::uint16($num_state)->[1])->[0], 0x7856,
   'second uint16 little endian');

is(Statistics::R::IO::Parser::uint24($num_state)->[0], 0x563412,
   'uint24 little endian');
is(Statistics::R::IO::Parser::uint24(Statistics::R::IO::Parser::uint24($num_state)->[1]), undef,
   'second uint24 little endian');

is(Statistics::R::IO::Parser::uint32($num_state)->[0], 0x78563412,
   'uint32 little endian');
is(Statistics::R::IO::Parser::uint32(Statistics::R::IO::Parser::uint32($num_state)->[1]), undef,
   'second uint32 little endian');

is(Statistics::R::IO::Parser::real32(Statistics::R::IO::ParserState->new(data => "\0\x79\xcc\x45"))->[0],
   6543.125, 'real32 little endian');

is(Statistics::R::IO::Parser::real64(Statistics::R::IO::ParserState->new(data => "\xad\xfa\x5c\x6d\x45\x4a\x93\x40"))->[0],
   1234.5678, 'real64 little endian');
