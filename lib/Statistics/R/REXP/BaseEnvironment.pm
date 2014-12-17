package Statistics::R::REXP::BaseEnvironment;
# ABSTRACT: the base R environment (C<baseenv()>)
$Statistics::R::REXP::BaseEnvironment::VERSION = '0.10';
use 5.010;

use Moose;
use namespace::clean;

extends 'Statistics::R::REXP::Environment';


has '+attributes' => (
    trigger => sub {
        die 'Base environment has implicit attributes'
    });

has '+frame' => (
    trigger => sub {
        die 'Nothing can be assigned to the base environment'
    });

has '+enclosure' => (
    trigger => sub {
        die 'Base environment has an implicit enclosure'
    });


around name => sub {
    'R_BaseEnv'
};


__PACKAGE__->meta->make_immutable;

1; # End of Statistics::R::REXP::BaseEnvironment

__END__

=pod

=encoding UTF-8

=head1 NAME

Statistics::R::REXP::BaseEnvironment - the base R environment (C<baseenv()>)

=head1 VERSION

version 0.10

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

=head1 AUTHOR

Davor Cubranic <cubranic@stat.ubc.ca>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by University of British Columbia.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
