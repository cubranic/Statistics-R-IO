package Statistics::R::REXP::Vector;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Moo::Role;

with 'Statistics::R::REXP';

requires qw(to_s _type);

use overload 'eq' => \&_eq,
    'ne' => sub { ! _eq(@_); },
    '""' => sub { shift->to_s; };

has type => (
    is => 'ro',
    default => sub { shift->_type; },
);


sub _eq {
    my ($self, $obj) = (shift, shift);
    
    return undef unless equal_class(@_) and
        scalar(@{$self->elements}) == scalar(@{$obj->elements});
    for (my $i = 0; $i < scalar(@{$self->elements}); $i++) {
        my $a = $self->elements->[$i];
        my $b = $obj->elements->[$i];
        if (defined($a) and defined($b)) {
            return undef unless $a eq $b;
        } else {
            return undef if defined($a) or defined($b);
        }
    }
    return 1;
}


sub to_s {
    my $self = shift;
    sub stringify { map { defined $_ ? $_ : 'undef'} @_ };
    $self->_type . '(' . join(', ', stringify(@{$self->elements})) . ')';
}


sub is_vector {
    return 1;
}

1; # End of Statistics::R::REXP::Vector
