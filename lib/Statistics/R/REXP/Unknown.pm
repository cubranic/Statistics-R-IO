package Statistics::R::REXP::Unknown;
# ABSTRACT: R object not representable in Rserve
$Statistics::R::REXP::Unknown::VERSION = '0.091';
use 5.010;

use Scalar::Util qw(looks_like_number);

use Moose;
use Statistics::R::REXP::Types;
use namespace::clean;

with 'Statistics::R::REXP';

has sexptype => (
    is => 'ro',
    isa => 'SexpType',
    required => 1,
);

use overload
    '""' => sub { 'Unknown' };

sub to_pl {
    undef
}


__PACKAGE__->meta->make_immutable;

1; # End of Statistics::R::REXP::Unknown

__END__

=pod

=encoding UTF-8

=head1 NAME

Statistics::R::REXP::Unknown - R object not representable in Rserve

=head1 VERSION

version 0.091

=head1 SYNOPSIS

    use Statistics::R::REXP::Unknown;
    
    my $unknown = Statistics::R::REXP::Unknown->new(4);
    say $unknown->sexptype;
    say $unknown->to_pl;

=head1 DESCRIPTION

An object of this class represents an R object that's currently not
representable by the Rserve protocol.

=head1 METHODS

C<Statistics::R::REXP::Unknown> inherits from L<Statistics::R::REXP> and
adds no methods of its own.

=head2 ACCESSORS

=over

=item sexptype

The R L<SEXPTYPE|http://cran.r-project.org/doc/manuals/r-release/R-ints.html#SEXPTYPEs> of the object.

=item to_pl

The Perl value of the unknown type is C<undef>.

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
