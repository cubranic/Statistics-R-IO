package Statistics::R::REXP::Logical;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Moo;
use namespace::clean;

with 'Statistics::R::REXP::Vector';

around BUILDARGS => sub {
    my $orig = shift;
    my $args = $orig->(@_);
    
    sub flatten { map { ref $_ ? flatten(@{$_}) : $_ } @_; }
    $args->{elements} = [ map { defined $_ ? ($_ ? 1 : 0) : undef } flatten(@{$args->{elements}}) ];
    
    return $args;
};

sub _type { 'logical'; }

1; # End of Statistics::R::REXP::Logical
