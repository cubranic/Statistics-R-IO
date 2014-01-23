package Statistics::R::REXP::Character;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Scalar::Util qw(looks_like_number);

use Moo;
use namespace::clean;

with 'Statistics::R::REXP::Vector';

around BUILDARGS => sub {
    my $orig = shift;
    my $args = $orig->(@_);
    
    sub flatten { map { ref $_ ? flatten(@{$_}) : $_ } @_; }
    $args->{elements} = [ flatten(@{$args->{elements}}) ];
    
    return $args;
};

sub _type { 'character'; }

1; # End of Statistics::R::REXP::Character
