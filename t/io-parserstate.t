#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 8;
use Test::Fatal;

use Statistics::R::IO::ParserState;

my $state = Statistics::R::IO::ParserState->new(data => 'foobar');

## basic state sanity
is_deeply($state->data, ['f', 'o', 'o', 'b', 'a', 'r'],
    'split data');
is($state->at, 'f', 'starting at');
is($state->position, 0, 'starting position');
ok(!$state->eof, 'starting eof');

## state next
my $next_state = $state->next;
is_deeply($next_state,
          Statistics::R::IO::ParserState->new(data => 'foobar',
                                              position =>1),
          "next");
is($next_state->at, 'o', 'next value');
is($next_state->position, 1, 'next position');
is_deeply($state,
          Statistics::R::IO::ParserState->new(data => 'foobar'),
          "next doesn't mutate in place");
