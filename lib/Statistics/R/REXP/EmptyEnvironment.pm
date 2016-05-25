package Statistics::R::REXP::EmptyEnvironment;
# ABSTRACT: the empty R environment (C<emptyenv()>)

use 5.010;

use Class::Tiny::Antlers;
use namespace::clean;

extends 'Statistics::R::REXP::Environment';


sub BUILD {
    my ($self, $args) = @_;

    # Required attribute type
    die 'Empty environment has no attributes' if defined $self->attributes;
    die 'Nothing can be assigned to the empty environment' if exists $args->{frame};
    die 'Empty environment has no enclosure' if defined $self->enclosure;
}


sub name {
    'R_EmptyEnv'
}


1; # End of Statistics::R::REXP::EmptyEnvironment

__END__


=head1 SYNOPSIS

    use Statistics::R::REXP::EmptyEnvironment
    
    my $env = Statistics::R::REXP::EmptyEnvironment->new;
    print $env->name;


=head1 DESCRIPTION

An object of this class represents a special R environment (C<ENVSXP>)
that is at the base of the environment enclosure hierarchy, which has
no C<parent.env> and into which nothing can be assigned.


You shouldn't create instances of this class, it exists mainly to
handle deserialization of C<emptyenv()> by the C<IO> classes.


=head1 METHODS

C<Statistics::R::REXP::EmptyEnvironment> inherits from
L<Statistics::R::REXP::Environment>, with the added restriction that it
doesn't have attributes, enclosure, or any contents. Trying to create an
EmptyEnvironment instance that doesn't follow this restriction will
raise an exception.

=head2 ACCESSORS

=over

=item name

Just as in R, the name of the EmptyEnvironment is "R_EmptyEnv".

=back


=head1 BUGS AND LIMITATIONS

Classes in the C<REXP> hierarchy are intended to be immutable. Please
do not try to change their value or attributes.

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.


=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.

=cut
