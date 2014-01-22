package Statistics::R::REXP::List;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Moo;
use namespace::clean;

with 'Statistics::R::REXP::Vector';

has elements => (
    is => 'ro',
    default => sub { []; },
);

sub to_s {
    my $self = shift;
    
    sub unfold {
        join(', ', map { ref $_ ?
                             '[' . unfold(@{$_}) . ']' :
                             (defined $_? $_ : 'undef') } @_);
    }
    $self->_type . '(' . unfold(@{$self->elements}) . ')';
}

sub _type { 'list'; }

1; # End of Statistics::R::REXP::List
