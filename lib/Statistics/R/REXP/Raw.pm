package Statistics::R::REXP::Raw;
# ABSTRACT: an R raw vector

use 5.010;

use Scalar::Util qw(looks_like_number);

use Class::Tiny::Antlers;
use namespace::clean;

extends 'Statistics::R::REXP::Vector';
use overload;


use constant sexptype => 'RAWSXP';

sub _type { 'raw'; }


sub BUILDARGS {
    my $class = shift;
    my $attributes = $class->SUPER::BUILDARGS(@_);

    if (ref($attributes->{elements}) eq 'ARRAY') {
        $attributes->{elements} = [
            map int,
                Statistics::R::REXP::Vector::_flatten(@{$attributes->{elements}})
        ]
    }
    $attributes
}


sub BUILD {
    my ($self, $args) = @_;

    # Required attribute type
    die 'Raw vectors cannot have attributes' if defined $self->attributes;
    die 'Elements of raw vectors must be 0-255' if defined $self->elements &&
        grep { !($_ >= 0 && $_ <= 255) } @{$self->elements}
}


1; # End of Statistics::R::REXP::Raw

__END__


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

=over

=item sexptype

SEXPTYPE of raw vectors is C<RAWSXP>.

=back


=head1 BUGS AND LIMITATIONS

Classes in the C<REXP> hierarchy are intended to be immutable. Please
do not try to change their value or attributes.

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.


=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.

=for Pod::Coverage BUILDARGS BUILD

=cut
