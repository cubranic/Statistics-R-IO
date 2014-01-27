#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 13;
use Test::Fatal;

use Statistics::R::IO::Parser;
use Statistics::R::IO::ParserState;

my $state = Statistics::R::IO::ParserState->new(data => 'foobar');

## char parser
is_deeply(Statistics::R::IO::Parser::char($state),
          ['f',
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                           position => 1)],
          'char');
is_deeply(Statistics::R::IO::Parser::char($state->next->next->next->next->next->next),
          undef,
          'char at eof');

## count combinator
is_deeply(Statistics::R::IO::Parser::count(3, \&Statistics::R::IO::Parser::char)->($state),
          [['f', 'o', 'o'],
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                           position => 3)],
          'count 3 char');

is_deeply(Statistics::R::IO::Parser::count(0, \&Statistics::R::IO::Parser::char)->($state),
          [[],
           Statistics::R::IO::ParserState->new(data => 'foobar',
                                           position => 0)],
          'count 0 char');

is(Statistics::R::IO::Parser::count(7, \&Statistics::R::IO::Parser::char)->($state), undef,
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
