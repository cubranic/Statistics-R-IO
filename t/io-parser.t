#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 5;
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

is_deeply(Statistics::R::IO::Parser::count(7, \&Statistics::R::IO::Parser::char)->($state),
          undef,
          'count fails');
