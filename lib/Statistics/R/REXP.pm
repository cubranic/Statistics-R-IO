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

    if (defined($a) and defined($b)) {
        return undef unless $a eq $b;
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
