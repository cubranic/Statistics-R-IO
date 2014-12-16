package Statistics::R::REXP::Logical;
# ABSTRACT: an R logical vector

use 5.010;

use Moose;
use namespace::clean;

with 'Statistics::R::REXP::Vector';
use overload;


has '+sexptype' => (
    default => 'LGLSXP'
);

has '+elements' => (
    isa => 'LogicalElements',
    );

sub _type { 'logical'; }


__PACKAGE__->meta->make_immutable;

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


=head1 BUGS AND LIMITATIONS

Classes in the C<REXP> hierarchy are intended to be immutable. Please
do not try to change their value or attributes.

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.


=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.

=cut
