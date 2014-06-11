package Statistics::R::REXP::GlobalEnvironment;
# ABSTRACT: the global R environment (C<.GlobalEnv>)

use 5.012;

use Moose;
use namespace::clean;

extends 'Statistics::R::REXP::Environment';

around BUILDARGS => sub {
    my $orig = shift;
    my $attributes = $orig->(@_);
    die 'Global environment has implicit attributes' if
        exists $attributes->{attributes};
    die 'Global environment has an implicit enclosure' if
        exists $attributes->{enclosure};
    $attributes
};


around name => sub {
    'R_GlobalEnvironment'
};


__PACKAGE__->meta->make_immutable;

1; # End of Statistics::R::REXP::GlobalEnvironment

__END__


=head1 SYNOPSIS

    use Statistics::R::REXP::GlobalEnvironment
    
    my $env = Statistics::R::REXP::GlobalEnvironment->new([
        x => Statistics::R::REXP::Character->new(['foo', 'bar']),
        b => Statistics::R::REXP::Double->new([1, 2, 3]),
    ]);
    print $env->elements;


=head1 DESCRIPTION

An object of this class represents an R environment (C<ENVSXP>), more
often known as the user's workspace. An assignment operation from the
command line will cause the relevant object to be placed in this
environment.

You shouldn't create instances of this class, it exists mainly to
handle deserialization of C<.GlobalEnv> by the C<IO> classes.


=head1 METHODS

C<Statistics::R::REXP:GlobalEnvironment> inherits from
L<Statistics::R::REXP::Environment>, with the added restriction that it
doesn't have attributes or enclosure. Trying to create a
GlobalEnvironment instance that doesn't follow this restriction will
raise an exception.

=head2 ACCESSORS

=over

=item name

Just as in R, the name of the GlobalEnvironment is "R_GlobalEnvironment".

=back


=head1 BUGS AND LIMITATIONS

Classes in the C<REXP> hierarchy are intended to be immutable. Please
do not try to change their value or attributes.

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.


=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.

=cut
