package TestCases;

use 5.012;

use strict;
use warnings FATAL => 'all';

use Exporter 'import';

our @EXPORT = qw( TEST_CASES );

use ShortDoubleVector;

use Statistics::R::IO::Parser qw( :all );
use Statistics::R::IO::ParserState;
use Statistics::R::REXP::Character;
use Statistics::R::REXP::Double;
use Statistics::R::REXP::Integer;
use Statistics::R::REXP::List;
use Statistics::R::REXP::Logical;
use Statistics::R::REXP::Raw;
use Statistics::R::REXP::Language;
use Statistics::R::REXP::Symbol;
use Statistics::R::REXP::Null;
use Statistics::R::REXP::GlobalEnvironment;
use Statistics::R::REXP::Unknown;

use constant TEST_CASES => {
    'empty_char' => {
        desc => 'empty char vector',
        expr => 'character()',
        value => Statistics::R::REXP::Character->new()},
    'empty_int' => {
        desc => 'empty int vector',
        expr => 'integer()',
        value => Statistics::R::REXP::Integer->new()},
    'empty_num' => {
        desc => 'empty double vector',
        expr => 'numeric()',
        value => ShortDoubleVector->new()},
    'empty_lgl' => {
        desc => 'empty logical vector',
        expr => 'logical()',
        value => Statistics::R::REXP::Logical->new()},
    'empty_list' => {
        desc => 'empty list',
        expr => 'list()',
        value => Statistics::R::REXP::List->new()},
    'empty_raw' => {
        desc => 'empty raw vector',
        expr => 'raw()',
        value => Statistics::R::REXP::Raw->new()},
    'empty_sym' => {
        desc => 'empty symbol',
        expr => 'bquote()',
        value => Statistics::R::REXP::Symbol->new()},
    'null' => {
        desc => 'null',
        expr => 'NULL',
        value => Statistics::R::REXP::Null->new()},
    'char_na' => {
        desc => 'char vector with NAs',
        expr => 'c("foo", "", NA, 23)',
        value => Statistics::R::REXP::Character->new([ 'foo', '', undef, '23' ]) },
    'num_na' => {
        desc => 'double vector with NAs',
        expr => 'c(11.3, NaN, -Inf, NA, 0)',
        value => ShortDoubleVector->new([ 11.3, 'nan', '-inf', undef, 0 ]) },
    'int_na' => {
        desc => 'int vector with NAs',
        expr => 'c(11L, 0L, NA, 0L)',
        value => Statistics::R::REXP::Integer->new([ 11, 0, undef, 0 ]) },
    'lgl_na' => {
        desc => 'logical vector with NAs',
        expr => 'c(TRUE, FALSE, TRUE, NA)',
        value => Statistics::R::REXP::Logical->new([ 1, 0, 1, undef ]) },
    'list_na' => {
        desc => 'list with NAs',
        expr => 'list(1, 1L, list("b", list(letters[4:7], NA, c(44.1, NA)), list()))',
        value => Statistics::R::REXP::List->new([
            ShortDoubleVector->new([ 1 ]),
            Statistics::R::REXP::Integer->new([ 1 ]),
            Statistics::R::REXP::List->new([
                Statistics::R::REXP::Character->new(['b']),
                Statistics::R::REXP::List->new([
                    Statistics::R::REXP::Character->new(['d', 'e', 'f', 'g']),
                    Statistics::R::REXP::Logical->new([undef]),
                    ShortDoubleVector->new([44.1, undef]) ]),
                Statistics::R::REXP::List->new([]) ]) ]) },
    'list_null' => {
        desc => 'list with a single NULL',
        expr => 'list(NULL)',
        value => Statistics::R::REXP::List->new( [
            Statistics::R::REXP::Null->new() ]) },
};

1;
