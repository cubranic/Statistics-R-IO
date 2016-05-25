package Statistics::R::REXP::BaseEnvironment;
# ABSTRACT: the base R environment (C<baseenv()>)

use 5.010;

use Class::Tiny::Antlers;
use namespace::clean;

extends 'Statistics::R::REXP::Environment';


sub BUILD {
    my ($self, $args) = @_;

    # Required attribute type
    die 'Base environment has implicit attributes' if defined $self->attributes;
    die 'Nothing can be assigned to the base environment' if exists $args->{frame};
    die 'Base environment has an implicit enclosure' if defined $self->enclosure;
}

sub name {
    'R_BaseEnv'
}


1; # End of Statistics::R::REXP::BaseEnvironment

__END__


=head1 SYNOPSIS

    use Statistics::R::REXP::BaseEnvironment
    
    my $env = Statistics::R::REXP::BaseEnvironment->new;
    print $env->name;


=head1 DESCRIPTION

An object of this class represents a special R environment (C<ENVSXP>)
that is the environment of the base package itself.

You shouldn't create instances of this class, it exists mainly to
handle deserialization of C<baseenv()> by the C<IO> classes.


=head1 METHODS

C<Statistics::R::REXP::BaseEnvironment> inherits from
L<Statistics::R::REXP::Environment>, with the added restriction that it
doesn't have attributes, enclosure, or any contents. Trying to create an
BaseEnvironment instance that doesn't follow this restriction will
raise an exception.

=head2 ACCESSORS

=over

=item name

Just as in R, the name of the BaseEnvironment is "R_BaseEnv".

=back


=head1 BUGS AND LIMITATIONS

Classes in the C<REXP> hierarchy are intended to be immutable. Please
do not try to change their value or attributes.

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.


=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.

=cut
