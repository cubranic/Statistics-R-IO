package Statistics::R::REXP::Vector;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Scalar::Util qw(blessed);

use Moo::Role;

with 'Statistics::R::REXP';

requires qw(to_s _type);

use overload '""' => sub { shift->to_s; };

has type => (
    is => 'ro',
    default => sub { shift->_type; },
);

has elements => (
    is => 'ro',
    default => sub { []; },
);


sub BUILDARGS {
    my $class = shift;
    if ( scalar @_ == 1 ) {
        if ( defined $_[0] ) {
            if ( ref $_[0] eq 'HASH' ) {
                return { %{ $_[0] } };
            } elsif ( ref $_[0] eq 'ARRAY' ) {
                return { elements => $_[0] };
            } elsif ( blessed $_[0] && $_[0]->can('does') &&
                      $_[0]->does('Statistics::R::REXP::Vector') ) {
                return { elements => $_[0]->elements };
            }
        }
        die "Single parameters to new() must be a HASH or ARRAY ref"
            ." data or a Statistics::R::REXP::Vector object => ". $_[0] ."\n";
    }
    elsif ( @_ % 2 ) {
        die "The new() method for $class expects a hash reference or a key/value list."
                . " You passed an odd number of arguments\n";
    }
    else {
        return {@_};
    }
}


around _eq => sub {
    my $orig = shift;

    return undef unless $orig->(@_);

    my ($self, $obj) = (shift, shift);
    
    return undef unless scalar(@{$self->elements}) ==
        scalar(@{$obj->elements});
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
};


sub to_s {
    my $self = shift;
    sub stringify { map { defined $_ ? $_ : 'undef'} @_ };
    $self->_type . '(' . join(', ', stringify(@{$self->elements})) . ')';
}


sub is_vector {
    return 1;
}

1; # End of Statistics::R::REXP::Vector
