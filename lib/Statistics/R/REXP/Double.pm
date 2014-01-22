package Statistics::R::REXP::Double;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Scalar::Util qw(looks_like_number);

use Moo;
use namespace::clean;

with 'Statistics::R::REXP::Vector';

has elements => (
    is => 'ro',
    default => sub { []; },
    coerce => sub { 
        my $x = shift;
        sub flatten { map { ref $_ ? flatten(@{$_}) : $_ } @_; }
        [ map { looks_like_number $_ ? $_ : undef } flatten(@{$x}) ]
    },
);

use overload 'eq' => \&equals,
    'ne' => sub { ! equals(@_); },
    '""' => \&to_s;

sub equals {
    my ($self, $obj) = (shift, shift);
    
    return undef unless equal_class(@_) and 
        scalar(@{$self->elements}) == scalar(@{$obj->elements});
    for (my $i = 0; $i < scalar(@{$self->elements}); $i++) {
        my $a = $self->elements->[$i];
        my $b = $obj->elements->[$i];
        if (defined($a) and defined($b)) {
            return undef unless $a == $b;
        } else {
            return undef if defined($a) or defined($b);
        }
    }
    return 1;
}

sub to_s {
    my $self = shift;
    sub stringify { map { defined $_ ? $_ : 'undef'} @_ };
    'double(' . join(', ', stringify(@{$self->elements})) . ')';
}

1; # End of Statistics::R::REXP::Double
