package Statistics::R::REXP;

use 5.012;

use Moo::Role;

requires qw( to_pl );

has attributes => (
    is => 'ro',
    isa => sub {
        die "$_[0] is not a HASH ref" unless ref $_[0] eq ref {};
    },
);

use overload
    eq => sub { shift->_eq(@_) },
    ne => sub { ! shift->_eq(@_) };


sub _eq {
    my ($self, $obj) = (shift, shift);
    return undef unless ref($self) eq ref($obj);
    
    my $a = $self->attributes;
    my $b = $obj->attributes;

    compare_deeply($a, $b)
}


sub compare_deeply {
    my ($a, $b) = @_ or die 'Need two arguments';
    if (defined($a) and defined($b)) {
        return 0 unless ref $a eq ref $b;
        if (ref $a eq ref []) {
            return undef unless scalar(@$a) == scalar(@$b);
            for (my $i = 0; $i < scalar(@{$a}); $i++) {
                return undef unless compare_deeply($a->[$i], $b->[$i]);
            }
        } elsif (ref $a eq ref {}) {
            return undef unless scalar(keys %$a) == scalar(keys %$b);
            foreach my $name (keys %$a) {
                return undef unless exists $b->{$name} &&
                    compare_deeply($a->{$name}, $b->{$name});
            }
        } else {
            return undef unless $a eq $b;
        }
    } else {
        return undef if defined($a) or defined($b);
    }

    return 1;
}


sub equal_class {
    my ($self, $obj) = (shift, shift);

    return (ref($self) eq ref($obj));
}


sub is_null {
    return 0;
}

1; # End of Statistics::R::REXP
