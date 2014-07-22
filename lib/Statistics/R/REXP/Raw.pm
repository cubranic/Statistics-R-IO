package Statistics::R::REXP::Raw;
# ABSTRACT: an R raw vector
$Statistics::R::REXP::Raw::VERSION = '0.092';
use 5.010;

use Scalar::Util qw(looks_like_number);

use Moose;
use namespace::clean;

with 'Statistics::R::REXP::Vector';
use overload;


has '+attributes' => (
    trigger => sub {
        die 'Raw vectors cannot have attributes'
    });

has '+elements' => (
    isa => 'RawElements',
);

sub _type { 'raw'; }


__PACKAGE__->meta->make_immutable;

1; # End of Statistics::R::REXP::Raw

__END__

=pod

=encoding UTF-8

=head1 NAME

Statistics::R::REXP::Raw - an R raw vector

=head1 VERSION

version 0.092

=head1 SYNOPSIS

    use Statistics::R::REXP::Raw
    
    my $vec = Statistics::R::REXP::Raw->new([
        1, 27, 143, 33
    ]);
    print $vec->elements;

=head1 DESCRIPTION

An object of this class represents an R raw vector (C<RAWSXP>). It is
intended to hold the data of arbitrary binary objects, for instance
bytes read from a socket connection.

=head1 METHODS

C<Statistics::R::REXP:Raw> inherits from
L<Statistics::R::REXP::Vector>, with the added restriction that its
elements are byte values and cannot have missing values. Trying to
create a raw vectors with elements that are not numbers in range 0-255
will raise an exception.

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
