package Statistics::R::REXP::Character;
# ABSTRACT: an R character vector
$Statistics::R::REXP::Character::VERSION = '0.05';
use 5.012;

use Scalar::Util qw(looks_like_number);

use Moo;
use namespace::clean;

with 'Statistics::R::REXP::Vector';

has '+elements' => (
    coerce => sub {
        my $x = shift;
        [ _flatten(@{$x}) ] if ref $x eq ref [];
    },
);


sub _type { 'character'; }

1; # End of Statistics::R::REXP::Character

__END__

=pod

=encoding UTF-8

=head1 NAME

Statistics::R::REXP::Character - an R character vector

=head1 VERSION

version 0.05

=head1 SYNOPSIS

    use Statistics::R::REXP::Character
    
    my $vec = Statistics::R::REXP::Character->new([
        1, '', 'foo', []
    ]);
    print $vec->elements;

=head1 DESCRIPTION

An object of this class represents an R character vector
(C<STRSXP>).

=head1 METHODS

C<Statistics::R::REXP:Character> inherits from
L<Statistics::R::REXP::Vector>, with the added restriction that its
elements are scalar values. Elements that are not scalars (i.e.,
numbers or strings) have value C<undef>, as do elements with R value
C<NA>.

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
