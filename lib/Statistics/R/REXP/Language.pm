package Statistics::R::REXP::Language;
# ABSTRACT: an R language vector

use 5.012;

use Scalar::Util qw(blessed);

use Moose;
use namespace::clean;

extends 'Statistics::R::REXP::List';

has '+elements' => (
    isa => 'ArrayRef',
);

around BUILDARGS => sub {
    my $orig = shift;
    my $attributes = $orig->(@_);
    my $elements = $attributes->{elements} // [];
    if (ref $elements eq ref []) {
        die 'The first element must be a Symbol or Language' unless
            blessed $elements->[0] &&
            ($elements->[0]->isa('Statistics::R::REXP::Language') ||
             $elements->[0]->isa('Statistics::R::REXP::Symbol'))
    }
    $attributes
};

around _type => sub { 'language' };


__PACKAGE__->meta->make_immutable;

1; # End of Statistics::R::REXP::Language

__END__


=head1 SYNOPSIS

    use Statistics::R::REXP::Language
    
    # Representation of the R call C<mean(c(1, 2, 3))>:
    my $vec = Statistics::R::REXP::Language->new([
        Statistics::R::REXP::Symbol->new('mean'),
        Statistics::R::REXP::Double->new([1, 2, 3])
    ]);
    print $vec->elements;


=head1 DESCRIPTION

An object of this class represents an R language vector (C<LANGSXP>).
These objects represent calls (such as model formulae), with first
element a reference to the function being called, and the remainder
the actual arguments of the call. Names of arguments, if given, are
recorded in the 'names' attribute (itself as
L<Statistics::R::REXP::Character> vector), with unnamed arguments
having name C<''>. If no arguments were named, the language objects
will not have a defined 'names' attribute.


=head1 METHODS

C<Statistics::R::REXP:Language> inherits from
L<Statistics::R::REXP::Vector>, with the added restriction that its
first element has to be a L<Statistics::R::REXP::Symbol> or another
C<Language> instance. Trying to create a Language instance that
doesn't follow this restriction will raise an exception.


=head1 BUGS AND LIMITATIONS

Classes in the C<REXP> hierarchy are intended to be immutable. Please
do not try to change their value or attributes.

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.


=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.

=cut
