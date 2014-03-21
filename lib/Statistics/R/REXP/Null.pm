package Statistics::R::REXP::Null;

use 5.012;

use Moo;
use namespace::clean;

with 'Statistics::R::REXP';

has '+attributes' => (
    isa => sub { die 'Null cannot have attributes' if defined shift; },
);

sub is_null {
    return 1;
}

use overload
    '""' => sub { 'NULL' };

sub to_pl {
    undef
}

1; # End of Statistics::R::REXP::Null

=head1 NAME

Statistics::R::REXP::Null - the R null object


=head1 VERSION

This documentation refers to version 0.03 of the module.


=head1 SYNOPSIS

    use Statistics::R::REXP;
    
    my $null = Statistics::R::REXP::Null->new();
    say $rexp->is_null;
    print $rexp->to_pl;


=head1 DESCRIPTION

An object of this class represents the null R object (C<NILSXP>). The
null object does not have a value or attributes, and trying to set
them will cause an exception.


=head1 METHODS

C<Statistics::R::REXP::Null> inherits from L<Statistics::R::REXP> and
adds no methods of its own.

=head2 ACCESSORS

=over

=item to_pl

The Perl value of C<NULL> is C<undef>.

=item attributes

Null objects have no attributes, so the attributes accessor always
returns C<undef>.

=back


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
