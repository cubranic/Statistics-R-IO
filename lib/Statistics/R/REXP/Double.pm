package Statistics::R::REXP::Double;

use 5.012;

use Scalar::Util qw(looks_like_number);

use Moo;
use namespace::clean;

with 'Statistics::R::REXP::Vector';

has '+elements' => (
    coerce => sub {
        my $x = shift;
        [ map { looks_like_number $_ ? $_ : undef } _flatten(@{$x}) ] if ref $x eq ref []
    },
);


sub _type { 'double'; }

1; # End of Statistics::R::REXP::Double

=head1 NAME

Statistics::R::REXP::Double - an R numeric vector


=head1 VERSION

This documentation refers to version 0.03 of the module.


=head1 SYNOPSIS

    use Statistics::R::REXP::Double
    
    my $vec = Statistics::R::REXP::Double->new([
        1, 4, 'foo', 42
    ]);
    print $vec->elements;


=head1 DESCRIPTION

An object of this class represents an R numeric (aka double) vector
(C<REALSXP>).


=head1 METHODS

C<Statistics::R::REXP:Double> inherits from
L<Statistics::R::REXP::Vector>, with the added restriction that its
elements are real numbers. Elements that are not numbers have value
C<undef>, as do elements with R value C<NA>.


=head1 BUGS AND LIMITATIONS

Classes in the C<REXP> hierarchy are intended to be immutable. Please
do not try to change their value or attributes.

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.


=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.


=head1 AUTHOR

Davor Cubranic, C<< <cubranic at stat.ubc.ca> >>


=head1 LICENSE AND COPYRIGHT

Copyright 2014 University of British Columbia.

See L<Statistics::R::IO> for the license.

=cut
