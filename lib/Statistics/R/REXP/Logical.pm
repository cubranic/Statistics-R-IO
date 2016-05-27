package Statistics::R::REXP::Logical;
# ABSTRACT: an R logical vector

use 5.010;

use Class::Tiny::Antlers;
use namespace::clean;

extends 'Statistics::R::REXP::Vector';
use overload;


use constant sexptype => 'LGLSXP';

sub _type { 'logical'; }


sub BUILDARGS {
    my $class = shift;
    my $attributes = $class->SUPER::BUILDARGS(@_);

    if (ref($attributes->{elements}) eq 'ARRAY') {
        $attributes->{elements} = [
            map { defined $_ ? ($_ ? 1 : 0) : undef }
                Statistics::R::REXP::Vector::_flatten(@{$attributes->{elements}})
        ]
    }
    $attributes
}


sub BUILD {
    my ($self, $args) = @_;

    # Required attribute type
    die "Elements of the 'elements' attribute must be 0, 1, or undef" if defined $self->elements &&
        grep { defined($_) && ($_ != 1 && $_ != 0) } @{$self->elements}
}


1; # End of Statistics::R::REXP::Logical

__END__


=head1 SYNOPSIS

    use Statistics::R::REXP::Logical
    
    my $vec = Statistics::R::REXP::Logical->new([
        1, '', 'foo', undef
    ]);
    print $vec->elements;


=head1 DESCRIPTION

An object of this class represents an R logical vector
(C<LGLSXP>).


=head1 METHODS

C<Statistics::R::REXP:Logical> inherits from
L<Statistics::R::REXP::Vector>, with the added restriction that its
elements are boolean (true/false) values. Elements have value 1 or 0,
corresponding to C<TRUE> and C<FALSE>, respectively, while missing
values (C<NA> in R) have value C<undef>.


=over

=item sexptype

SEXPTYPE of logical vectors is C<LGLSXP>.

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
