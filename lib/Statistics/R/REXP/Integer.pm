package Statistics::R::REXP::Integer;
# ABSTRACT: an R integer vector
$Statistics::R::REXP::Integer::VERSION = '0.091';
use 5.010;

use Scalar::Util qw(looks_like_number);

use Moose;
use namespace::clean;

with 'Statistics::R::REXP::Vector';
use overload;


has '+elements' => (
    isa => 'IntegerElements',
);

sub _type { 'integer'; }


__PACKAGE__->meta->make_immutable;

1; # End of Statistics::R::REXP::Integer

__END__

=pod

=encoding UTF-8

=head1 NAME

Statistics::R::REXP::Integer - an R integer vector

=head1 VERSION

version 0.091

=head1 SYNOPSIS

    use Statistics::R::REXP::Integer
    
    my $vec = Statistics::R::REXP::Integer->new([
        1, 4, 'foo', 42
    ]);
    print $vec->elements;

=head1 DESCRIPTION

An object of this class represents an R integer vector (C<INTSXP>).

=head1 METHODS

C<Statistics::R::REXP:Integer> inherits from
L<Statistics::R::REXP::Vector>, with the added restriction that its
elements are truncated to integer values. Elements that are not
numbers have value C<undef>, as do elements with R value C<NA>.

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
