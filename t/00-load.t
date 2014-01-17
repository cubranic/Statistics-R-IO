#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';
use Test::More tests => 1;

BEGIN {
    use_ok( 'Statistics::R::IO' ) || print "Bail out!\n";
}

diag( "Testing Statistics::R::IO $Statistics::R::IO::VERSION, Perl $], $^X" );
