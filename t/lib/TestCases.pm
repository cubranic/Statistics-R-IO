package TestCases;

use 5.010;

use strict;
use warnings FATAL => 'all';

use Exporter 'import';

our @EXPORT = qw( TEST_CASES );

use ShortDoubleVector;
use ClosureLenientEnv;
use RexpOrUnknown;
use LenientSrcFile;

use Statistics::R::IO::Parser qw( :all );
use Statistics::R::IO::ParserState;
use Statistics::R::REXP::Character;
use Statistics::R::REXP::Double;
use Statistics::R::REXP::Integer;
use Statistics::R::REXP::List;
use Statistics::R::REXP::Logical;
use Statistics::R::REXP::Raw;
use Statistics::R::REXP::Language;
use Statistics::R::REXP::Expression;
use Statistics::R::REXP::Closure;
use Statistics::R::REXP::Symbol;
use Statistics::R::REXP::Null;
use Statistics::R::REXP::GlobalEnvironment;
use Statistics::R::REXP::EmptyEnvironment;
use Statistics::R::REXP::BaseEnvironment;
use Statistics::R::REXP::Unknown;

use constant TEST_SRC_FILE => {
    clos_args => LenientSrcFile->new(
        frame => {
            Enc => Statistics::R::REXP::Character->new(['unknown']),
            filename => Statistics::R::REXP::Character->new(['<text>']),
            fixedNewlines => Statistics::R::REXP::Logical->new([1]),
            isFile => Statistics::R::REXP::Logical->new([0]),
            lines => Statistics::R::REXP::Character->new(['function(a, b) {a - b}']),
            parseData => Statistics::R::REXP::Integer->new(
                elements => [
                    1, 1, 1, 8, 1, 264, 1, 22, 1, 9, 1, 9, 1, 40,
                    2, 22, 1, 10, 1, 10, 1, 292, 3, 22, 1, 11, 1,
                    11, 1, 44, 4, 22, 1, 13, 1, 13, 1, 292, 6, 22,
                    1, 14, 1, 14, 1, 41, 7, 22, 1, 16, 1, 16, 1,
                    123, 9, 19, 1, 17, 1, 17, 1, 263, 10, 12, 1,
                    19, 1, 19, 1, 45, 11, 16, 1, 17, 1, 17, 0, 77,
                    12, 16, 1, 21, 1, 21, 1, 263, 13, 15, 1, 22,
                    1, 22, 1, 125, 14, 19, 1, 21, 1, 21, 0, 77,
                    15, 16, 1, 17, 1, 21, 0, 77, 16, 19, 1, 16, 1,
                    22, 0, 77, 19, 22, 1, 1, 1, 22, 0, 77, 22, 0],
                attributes => {
                    class => Statistics::R::REXP::Character->new(['parseData']),
                    dim => Statistics::R::REXP::Integer->new([8, 16]),
                    text => Statistics::R::REXP::Character->new([
                        'function', '(', 'a', ',', 'b', ')', '{', 'a', '-', '', 'b', '}', '', '', '', '']),
                    tokens => Statistics::R::REXP::Character->new([
                        'FUNCTION', "'('", 'SYMBOL_FORMALS', "','", 'SYMBOL_FORMALS', "')'",
                        "'{'", 'SYMBOL', "'-'", 'expr', 'SYMBOL', "'}'", 'expr', 'expr', 'expr', 'expr']),
                }),
            timestamp => Statistics::R::REXP::Double->new(
                elements => [12345],
                attributes => {
                    class => Statistics::R::REXP::Character->new(['POSIXct', 'POSIXt']),
                }),
            wd => Statistics::R::REXP::Character->new(['abcd'])
        },
        attributes => {
            class => Statistics::R::REXP::Character->new(['srcfilecopy', 'srcfile'])
        },
        enclosure => Statistics::R::REXP::EmptyEnvironment->new),
    clos_defaults => LenientSrcFile->new(
        frame => {
            Enc => Statistics::R::REXP::Character->new(['unknown']),
            filename => Statistics::R::REXP::Character->new(['<text>']),
            fixedNewlines => Statistics::R::REXP::Logical->new([1]),
            isFile => Statistics::R::REXP::Logical->new([0]),
            lines => Statistics::R::REXP::Character->new(['function(a=3, b) {a + b * pi}']),
            parseData => Statistics::R::REXP::Integer->new(
                elements => [
                    1, 1, 1, 8, 1, 264, 1, 29, 1, 9, 1, 9,
                    1, 40, 2, 29, 1, 10, 1, 10, 1, 292, 3,
                    29, 1, 11, 1, 11, 1, 293, 4, 29, 1, 12,
                    1, 12, 1, 261, 5, 6, 1, 12, 1, 12, 0,
                    77, 6, 29, 1, 13, 1, 13, 1, 44, 7, 29,
                    1, 15, 1, 15, 1, 292, 9, 29, 1, 16, 1,
                    16, 1, 41, 10, 29, 1, 18, 1, 18, 1, 123,
                    12, 26, 1, 19, 1, 19, 1, 263, 13, 15, 1,
                    21, 1, 21, 1, 43, 14, 23, 1, 19, 1, 19,
                    0, 77, 15, 23, 1, 23, 1, 23, 1, 263, 16,
                    18, 1, 25, 1, 25, 1, 42, 17, 22, 1, 23,
                    1, 23, 0, 77, 18, 22, 1, 27, 1, 28, 1,
                    263, 19, 21, 1, 29, 1, 29, 1, 125, 20,
                    26, 1, 27, 1, 28, 0, 77, 21, 22, 1, 23,
                    1, 28, 0, 77, 22, 23, 1, 19, 1, 28, 0,
                    77, 23, 26, 1, 18, 1, 29, 0, 77, 26, 29,
                    1, 1, 1, 29, 0, 77, 29, 0],
                attributes => {
                    class => Statistics::R::REXP::Character->new(['parseData']),
                    dim => Statistics::R::REXP::Integer->new([8, 23]),
                    text => Statistics::R::REXP::Character->new([
                        'function', '(', 'a', '=', '3', '', ',', 'b', ')', '{', 'a', '+', '', 'b', '*', '', 'pi', '}', '', '', '', '', '']),
                    tokens => Statistics::R::REXP::Character->new([
                        'FUNCTION', "'('", 'SYMBOL_FORMALS', 'EQ_FORMALS', 'NUM_CONST', 'expr', "','", 'SYMBOL_FORMALS', "')'",
                        "'{'", 'SYMBOL', "'+'", 'expr', 'SYMBOL', "'*'", 'expr', 'SYMBOL', "'}'", 'expr', 'expr', 'expr', 'expr', 'expr']),
                }),
            timestamp => Statistics::R::REXP::Double->new(
                elements => [12345],
                attributes => {
                    class => Statistics::R::REXP::Character->new(['POSIXct', 'POSIXt']),
                }),
            wd => Statistics::R::REXP::Character->new(['abcd'])
        },
        attributes => {
            class => Statistics::R::REXP::Character->new(['srcfilecopy', 'srcfile'])
        },
        enclosure => Statistics::R::REXP::EmptyEnvironment->new),
    clos_dots => LenientSrcFile->new(
        frame => {
            Enc => Statistics::R::REXP::Character->new(['unknown']),
            filename => Statistics::R::REXP::Character->new(['<text>']),
            fixedNewlines => Statistics::R::REXP::Logical->new([1]),
            isFile => Statistics::R::REXP::Logical->new([0]),
            lines => Statistics::R::REXP::Character->new(['function(x=3, y, ...) {x * log(y) }']),
            parseData => Statistics::R::REXP::Integer->new(
                elements => [
                    1, 1, 1, 8, 1, 264, 1, 35, 1, 9, 1, 9, 1,
                    40, 2, 35, 1, 10, 1, 10, 1, 292, 3, 35, 1,
                    11, 1, 11, 1, 293, 4, 35, 1, 12, 1, 12, 1,
                    261, 5, 6, 1, 12, 1, 12, 0, 77, 6, 35, 1,
                    13, 1, 13, 1, 44, 7, 35, 1, 15, 1, 15, 1,
                    292, 9, 35, 1, 16, 1, 16, 1, 44, 10, 35, 1,
                    18, 1, 20, 1, 292, 12, 35, 1, 21, 1, 21, 1,
                    41, 13, 35, 1, 23, 1, 23, 1, 123, 15, 32,
                    1, 24, 1, 24, 1, 263, 16, 18, 1, 26, 1, 26,
                    1, 42, 17, 29, 1, 24, 1, 24, 0, 77, 18, 29,
                    1, 28, 1, 30, 1, 296, 19, 21, 1, 31, 1, 31,
                    1, 40, 20, 27, 1, 28, 1, 30, 0, 77, 21, 27,
                    1, 32, 1, 32, 1, 263, 22, 24, 1, 33, 1, 33,
                    1, 41, 23, 27, 1, 32, 1, 32, 0, 77, 24, 27,
                    1, 28, 1, 33, 0, 77, 27, 29, 1, 35, 1, 35,
                    1, 125, 28, 32, 1, 24, 1, 33, 0, 77, 29,
                    32, 1, 23, 1, 35, 0, 77, 32, 35, 1, 1, 1,
                    35, 0, 77, 35, 0],
                attributes => {
                    class => Statistics::R::REXP::Character->new(['parseData']),
                    dim => Statistics::R::REXP::Integer->new([8, 26]),
                    text => Statistics::R::REXP::Character->new([
                        'function', '(', 'x', '=', '3', '', ',', 'y', ',', '...', ')', '{', 'x', '*', '', 'log', '(', '', 'y', ')', '', '', '}', '', '', '']),
                    tokens => Statistics::R::REXP::Character->new([
                        'FUNCTION', "'('", 'SYMBOL_FORMALS', 'EQ_FORMALS', 'NUM_CONST', 'expr', "','", 'SYMBOL_FORMALS', "','", 'SYMBOL_FORMALS', "')'",
                        "'{'", 'SYMBOL', "'*'", 'expr', 'SYMBOL_FUNCTION_CALL', "'('", 'expr', 'SYMBOL', "')'", 'expr', 'expr', "'}'", 'expr', 'expr', 'expr']),
                }),
            timestamp => Statistics::R::REXP::Double->new(
                elements => [12345],
                attributes => {
                    class => Statistics::R::REXP::Character->new(['POSIXct', 'POSIXt']),
                }),
            wd => Statistics::R::REXP::Character->new(['abcd'])
        },
        attributes => {
            class => Statistics::R::REXP::Character->new(['srcfilecopy', 'srcfile'])
        },
        enclosure => Statistics::R::REXP::EmptyEnvironment->new),
};

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
    'empty_expr' => {
        desc => 'empty expr',
        expr => 'expression()',
        value => Statistics::R::REXP::Expression->new()},
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
    'expr_null' => {
        desc => 'expression(NULL)',
        expr => 'expression(NULL)',
        value => Statistics::R::REXP::Expression->new([
            Statistics::R::REXP::Null->new()
        ])},
    'expr_int' => {
        desc => 'expression(42L)',
        expr => 'expression(42L)',
        value => Statistics::R::REXP::Expression->new([
            Statistics::R::REXP::Integer->new([42])
        ])},
    'expr_call' => {
        desc => 'expression(1+2)',
        expr => 'expression(1+2)',
        value => Statistics::R::REXP::Expression->new([
            Statistics::R::REXP::Language->new([
                Statistics::R::REXP::Symbol->new('+'),
                ShortDoubleVector->new([1]),
                ShortDoubleVector->new([2]) ])
        ])},
    'expr_many' => {
        desc => 'expression(u, v, 1+0:9)',
        expr => 'expression(u, v, 1+0:9)',
        value => Statistics::R::REXP::Expression->new([
            Statistics::R::REXP::Symbol->new('u'),
            Statistics::R::REXP::Symbol->new('v'),
            Statistics::R::REXP::Language->new([
                Statistics::R::REXP::Symbol->new('+'),
                ShortDoubleVector->new([1]),
                Statistics::R::REXP::Language->new([
                    Statistics::R::REXP::Symbol->new(':'),
                    ShortDoubleVector->new([0]),
                    ShortDoubleVector->new([9]) ])
            ])
        ])},
    'empty_clos' => {
        desc => 'function() {}',
        expr => 'function() {}',
        value => ClosureLenientEnv->new(
            body => Statistics::R::REXP::Language->new([
                Statistics::R::REXP::Symbol->new('{') ]),
            environment => Statistics::R::REXP::GlobalEnvironment->new())
    },
    'clos_null' => {
        desc => 'function() NULL',
        expr => 'function() NULL',
        value => ClosureLenientEnv->new(
            body => Statistics::R::REXP::Null->new,
            environment => Statistics::R::REXP::GlobalEnvironment->new(),
            attributes => {
                srcref => Statistics::R::REXP::Integer->new(
                    elements => [1, 1, 1, 15, 1, 15, 1, 1],
                    attributes => {
                        class => Statistics::R::REXP::Character->new(['srcref']),
                        srcfile => LenientSrcFile->new(
                            frame => {
                                Enc => Statistics::R::REXP::Character->new(['unknown']),
                                filename => Statistics::R::REXP::Character->new(['<text>']),
                                fixedNewlines => Statistics::R::REXP::Logical->new([1]),
                                isFile => Statistics::R::REXP::Logical->new([0]),
                                lines => Statistics::R::REXP::Character->new(['function() NULL']),
                                parseData => Statistics::R::REXP::Integer->new(
                                    elements => [
                                        1, 1, 1, 8, 1, 264, 1, 8, 1, 9, 1, 9, 1,
                                        40, 2, 8, 1, 10, 1, 10, 1, 41, 3, 8, 1,
                                        12, 1, 15, 1, 262, 4, 5, 1, 12, 1, 15, 0,
                                        77, 5, 8, 1, 1, 1, 15, 0, 77, 8, 0],
                                    attributes => {
                                        class => Statistics::R::REXP::Character->new(['parseData']),
                                        dim => Statistics::R::REXP::Integer->new([8, 6]),
                                        text => Statistics::R::REXP::Character->new([
                                            'function', '(', ')', 'NULL', '', '']),
                                        tokens => Statistics::R::REXP::Character->new([
                                            'FUNCTION', "'('", "')'", 'NULL_CONST', 'expr', 'expr']),
                                    }),
                                timestamp => Statistics::R::REXP::Double->new(
                                    elements => [12345],
                                    attributes => {
                                        class => Statistics::R::REXP::Character->new(['POSIXct', 'POSIXt']),
                                    }),
                                wd => Statistics::R::REXP::Character->new(['abcd'])
                            },
                            attributes => {
                                class => Statistics::R::REXP::Character->new(['srcfilecopy', 'srcfile'])
                            },
                            enclosure => Statistics::R::REXP::EmptyEnvironment->new)})
            })
    },
    'clos_int' => {
        desc => 'function() 1L',
        expr => 'function() 1L',
        value => ClosureLenientEnv->new(
            body => Statistics::R::REXP::Integer->new([1]),
            environment => Statistics::R::REXP::GlobalEnvironment->new(),
            attributes => {
                srcref => Statistics::R::REXP::Integer->new(
                    elements => [1, 1, 1, 13, 1, 13, 1, 1],
                    attributes => {
                        class => Statistics::R::REXP::Character->new(['srcref']),
                        srcfile => LenientSrcFile->new(
                            frame => {
                                Enc => Statistics::R::REXP::Character->new(['unknown']),
                                filename => Statistics::R::REXP::Character->new(['<text>']),
                                fixedNewlines => Statistics::R::REXP::Logical->new([1]),
                                isFile => Statistics::R::REXP::Logical->new([0]),
                                lines => Statistics::R::REXP::Character->new(['function() 1L']),
                                parseData => Statistics::R::REXP::Integer->new(
                                    elements => [
                                        1, 1, 1, 8, 1, 264, 1, 8, 1, 9, 1, 9, 1,
                                        40, 2, 8, 1, 10, 1, 10, 1, 41, 3, 8, 1,
                                        12, 1, 13, 1, 261, 4, 5, 1, 12, 1, 13, 0,
                                        77, 5, 8, 1, 1, 1, 13, 0, 77, 8, 0],
                                    attributes => {
                                        class => Statistics::R::REXP::Character->new(['parseData']),
                                        dim => Statistics::R::REXP::Integer->new([8, 6]),
                                        text => Statistics::R::REXP::Character->new([
                                            'function', '(', ')', '1L', '', '']),
                                        tokens => Statistics::R::REXP::Character->new([
                                            'FUNCTION', "'('", "')'", 'NUM_CONST', 'expr', 'expr']),
                                    }),
                                timestamp => Statistics::R::REXP::Double->new(
                                    elements => [12345],
                                    attributes => {
                                        class => Statistics::R::REXP::Character->new(['POSIXct', 'POSIXt']),
                                    }),
                                wd => Statistics::R::REXP::Character->new(['abcd'])
                            },
                            attributes => {
                                class => Statistics::R::REXP::Character->new(['srcfilecopy', 'srcfile'])
                            },
                            enclosure => Statistics::R::REXP::EmptyEnvironment->new)})
            })
    },
    'clos_add' => {
        desc => 'function() 1+2',
        expr => 'function() 1+2',
        value => ClosureLenientEnv->new(
            body => Statistics::R::REXP::Language->new([
                Statistics::R::REXP::Symbol->new('+'),
                ShortDoubleVector->new([1]),
                ShortDoubleVector->new([2]) ]),
            environment => Statistics::R::REXP::GlobalEnvironment->new(),
            attributes => {
                srcref => Statistics::R::REXP::Integer->new(
                    elements => [1, 1, 1, 14, 1, 14, 1, 1],
                    attributes => {
                        class => Statistics::R::REXP::Character->new(['srcref']),
                        srcfile => LenientSrcFile->new(
                            frame => {
                                Enc => Statistics::R::REXP::Character->new(['unknown']),
                                filename => Statistics::R::REXP::Character->new(['<text>']),
                                fixedNewlines => Statistics::R::REXP::Logical->new([1]),
                                isFile => Statistics::R::REXP::Logical->new([0]),
                                lines => Statistics::R::REXP::Character->new(['function() 1+2']),
                                parseData => Statistics::R::REXP::Integer->new(
                                    elements => [
                                        1, 1, 1, 8, 1, 264, 1, 12, 1, 9, 1, 9, 1, 40,
                                        2, 12, 1, 10, 1, 10, 1, 41, 3, 12, 1, 12, 1,
                                        12, 1, 261, 4, 5, 1, 12, 1, 12, 0, 77, 5, 10,
                                        1, 13, 1, 13, 1, 43, 6, 10, 1, 14, 1, 14, 1,
                                        261, 7, 8, 1, 14, 1, 14, 0, 77, 8, 10, 1, 12,
                                        1, 14, 0, 77, 10, 12, 1, 1, 1, 14, 0, 77, 12, 0 ],
                                    attributes => {
                                        class => Statistics::R::REXP::Character->new(['parseData']),
                                        dim => Statistics::R::REXP::Integer->new([8, 10]),
                                        text => Statistics::R::REXP::Character->new([
                                            'function', '(', ')', '1', '', '+', '2', '', '', '']),
                                        tokens => Statistics::R::REXP::Character->new([
                                            'FUNCTION', "'('", "')'", 'NUM_CONST', 'expr',
                                            "'+'", 'NUM_CONST', 'expr', 'expr', 'expr']),
                                    }),
                                timestamp => Statistics::R::REXP::Double->new(
                                    elements => [12345],
                                    attributes => {
                                        class => Statistics::R::REXP::Character->new(['POSIXct', 'POSIXt']),
                                    }),
                                wd => Statistics::R::REXP::Character->new(['abcd'])
                            },
                            attributes => {
                                class => Statistics::R::REXP::Character->new(['srcfilecopy', 'srcfile'])
                            },
                            enclosure => Statistics::R::REXP::EmptyEnvironment->new)})
            })
    },
    'clos_args' => {
        desc => 'function(a, b) {a - b}',
        expr => 'function(a, b) {a - b}',
        value => ClosureLenientEnv->new(
            args => ['a', 'b'],
            body => Statistics::R::REXP::Language->new(
                elements => [
                    Statistics::R::REXP::Symbol->new('{'),
                    Statistics::R::REXP::Language->new([
                        Statistics::R::REXP::Symbol->new('-'),
                        Statistics::R::REXP::Symbol->new('a'),
                        Statistics::R::REXP::Symbol->new('b') ])
                ],
                attributes => {
                    srcfile => TEST_SRC_FILE->{clos_args},
                    wholeSrcref => Statistics::R::REXP::Integer->new(
                        elements => [1, 0, 1, 22, 0, 22, 1, 1],
                        attributes => {
                            class => Statistics::R::REXP::Character->new(['srcref']),
                            srcfile => TEST_SRC_FILE->{clos_args}}),
                    srcref => Statistics::R::REXP::List->new([
                        Statistics::R::REXP::Integer->new(
                            elements => [1, 16, 1, 16, 16, 16, 1, 1],
                            attributes => {
                                class => Statistics::R::REXP::Character->new(['srcref']),
                                srcfile => TEST_SRC_FILE->{clos_args}}),
                        Statistics::R::REXP::Integer->new(
                            elements => [1, 17, 1, 21, 17, 21, 1, 1],
                            attributes => {
                                class => Statistics::R::REXP::Character->new(['srcref']),
                                srcfile => TEST_SRC_FILE->{clos_args}}),
                    ])
                }),
            environment => Statistics::R::REXP::GlobalEnvironment->new(),
            attributes => {
                srcref => Statistics::R::REXP::Integer->new(
                    elements => [1, 1, 1, 22, 1, 22, 1, 1],
                    attributes => {
                        class => Statistics::R::REXP::Character->new(['srcref']),
                        srcfile => TEST_SRC_FILE->{clos_args}})
            })
    },
    'clos_defaults' => {
        desc => 'function(a=3, b) {a + b * pi}',
        expr => 'function(a=3, b) {a + b * pi}',
        value => ClosureLenientEnv->new(
            args => ['a', 'b'],
            defaults => [ShortDoubleVector->new([2]), undef],
            body => Statistics::R::REXP::Language->new(
                elements => [
                    Statistics::R::REXP::Symbol->new('{'),
                    Statistics::R::REXP::Language->new([
                        Statistics::R::REXP::Symbol->new('+'),
                        Statistics::R::REXP::Symbol->new('a'),
                        Statistics::R::REXP::Language->new([
                            Statistics::R::REXP::Symbol->new('*'),
                            Statistics::R::REXP::Symbol->new('b'),
                            Statistics::R::REXP::Symbol->new('pi')])
                        ])
                ],
                attributes => {
                    srcfile => TEST_SRC_FILE->{clos_defaults},
                    wholeSrcref => Statistics::R::REXP::Integer->new(
                        elements => [1, 0, 1, 29, 0, 29, 1, 1],
                        attributes => {
                            class => Statistics::R::REXP::Character->new(['srcref']),
                            srcfile => TEST_SRC_FILE->{clos_defaults}}),
                    srcref => Statistics::R::REXP::List->new([
                        Statistics::R::REXP::Integer->new(
                            elements => [1, 18, 1, 18, 18, 18, 1, 1],
                            attributes => {
                                class => Statistics::R::REXP::Character->new(['srcref']),
                                srcfile => TEST_SRC_FILE->{clos_defaults}}),
                        Statistics::R::REXP::Integer->new(
                            elements => [1, 19, 1, 28, 19, 28, 1, 1],
                            attributes => {
                                class => Statistics::R::REXP::Character->new(['srcref']),
                                srcfile => TEST_SRC_FILE->{clos_defaults}}),
                    ])
                }),
            environment => Statistics::R::REXP::GlobalEnvironment->new(),
            attributes => {
                srcref => Statistics::R::REXP::Integer->new(
                    elements => [1, 1, 1, 29, 1, 29, 1, 1],
                    attributes => {
                        class => Statistics::R::REXP::Character->new(['srcref']),
                        srcfile => TEST_SRC_FILE->{clos_defaults}})
            })
    },
    'clos_dots' => {
        desc => 'function(x=3, y, ...) {x * log(y) }',
        expr => 'function(x=3, y, ...) {x * log(y) }',
        value => ClosureLenientEnv->new(
            args => ['x', 'y', '...'],
            defaults => [ShortDoubleVector->new([3]), undef, undef],
            body => Statistics::R::REXP::Language->new(
                elements => [
                    Statistics::R::REXP::Symbol->new('{'),
                    Statistics::R::REXP::Language->new([
                        Statistics::R::REXP::Symbol->new('*'),
                        Statistics::R::REXP::Symbol->new('x'),
                        Statistics::R::REXP::Language->new([
                            Statistics::R::REXP::Symbol->new('log'),
                            Statistics::R::REXP::Symbol->new('y')] ) ])
                ],
                attributes => {
                    srcfile => TEST_SRC_FILE->{clos_dots},
                    wholeSrcref => Statistics::R::REXP::Integer->new(
                        elements => [1, 0, 1, 35, 0, 35, 1, 1],
                        attributes => {
                            class => Statistics::R::REXP::Character->new(['srcref']),
                            srcfile => TEST_SRC_FILE->{clos_dots}}),
                    srcref => Statistics::R::REXP::List->new([
                        Statistics::R::REXP::Integer->new(
                            elements => [1, 23, 1, 23, 23, 23, 1, 1],
                            attributes => {
                                class => Statistics::R::REXP::Character->new(['srcref']),
                                srcfile => TEST_SRC_FILE->{clos_dots}}),
                        Statistics::R::REXP::Integer->new(
                            elements => [1, 24, 1, 33, 24, 33, 1, 1],
                            attributes => {
                                class => Statistics::R::REXP::Character->new(['srcref']),
                                srcfile => TEST_SRC_FILE->{clos_dots}}),
                    ])
                }),
            environment => Statistics::R::REXP::GlobalEnvironment->new(),
            attributes => {
                srcref => Statistics::R::REXP::Integer->new(
                    elements => [1, 1, 1, 35, 1, 35, 1, 1],
                    attributes => {
                        class => Statistics::R::REXP::Character->new(['srcref']),
                        srcfile => TEST_SRC_FILE->{clos_dots}})
            })
    },
    'baseenv' => {
        desc => 'baseenv()',
        expr => 'baseenv()',
        value => RexpOrUnknown->new(Statistics::R::REXP::BaseEnvironment->new),
    },
    'emptyenv' => {
        desc => 'emptyenv()',
        expr => 'emptyenv()',
        value => RexpOrUnknown->new(Statistics::R::REXP::EmptyEnvironment->new),
    },
    'globalenv' => {
        desc => 'globalenv()',
        expr => 'globalenv()',
        value => RexpOrUnknown->new(Statistics::R::REXP::GlobalEnvironment->new),
    },
    'env_attr' => {
        desc => 'environment with attributes',
        expr => 'local({ e <- new.env(parent=globalenv()); attributes(e) <- list(foo = "bar", fred = 1:3); e })',
        value => RexpOrUnknown->new(Statistics::R::REXP::Environment->new(
            enclosure => Statistics::R::REXP::GlobalEnvironment->new,
            attributes => {
                foo => Statistics::R::REXP::Character->new(['bar']),
                fred => Statistics::R::REXP::Integer->new([1, 2, 3]),
            })),
    },
};

1;
