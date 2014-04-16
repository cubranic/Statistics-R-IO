package Statistics::R::REXP::Symbol;
# ABSTRACT: an R symbol
$Statistics::R::REXP::Symbol::VERSION = '0.06';
use 5.012;

use Scalar::Util qw(blessed);

use Moo;
use namespace::clean;

with 'Statistics::R::REXP';

has name => (
    is => 'ro',
    default => '',
    coerce => sub {
        my $x = shift;
        if (defined $x && ! ref $x) {
            $x;
        } elsif (blessed $x && $x->isa('Statistics::R::REXP::Symbol')) {
            $x->name;
        } else {
            die "Symbol name must be a non-reference scalar or another Symbol".
                $x ."\n";
        }
    },
);

use overload
    '""' => sub { 'symbol `'. shift->name .'`' };

sub BUILDARGS {
    my $class = shift;
    if ( scalar @_ == 1 ) {
        if ( defined $_[0] ) {
            if ( ref $_[0] eq 'HASH' ) {
                return { %{ $_[0] } };
            } elsif ( blessed $_[0] && $_[0]->isa('Statistics::R::REXP::Symbol') ) {
                # copy constructor from another name
                return { name => $_[0]->name };
            } elsif ( ! ref $_[0] ) {
                # name as scalar
                return { name => $_[0] };
            }
        }
        die "Single parameters to new() must be a HASH data"
            ." or a Statistics::R::REXP::Symbol object => ". $_[0] ."\n";
    }
    elsif ( @_ % 2 ) {
        die "The new() method for $class expects a hash reference or a key/value list."
                . " You passed an odd number of arguments\n";
    }
    else {
        return {@_};
    }
}


around _eq => sub {
    my $orig = shift;
    $orig->(@_) and ($_[0]->name eq $_[1]->name);
};


sub to_pl {
    my $self = shift;
    $self->name
}

1; # End of Statistics::R::REXP::Symbol

__END__

=pod

=encoding UTF-8

=head1 NAME

Statistics::R::REXP::Symbol - an R symbol

=head1 VERSION

version 0.06

=head1 SYNOPSIS

    use Statistics::R::REXP::Symbol;
    
    my $sym = Statistics::R::REXP::Symbol->new('some name');
    print $sym->name;

=head1 DESCRIPTION

An object of this class represents an R symbol/name object (C<SYMSXP>).

=head1 METHODS

C<Statistics::R::REXP::Symbol> inherits from L<Statistics::R::REXP>.

=head2 ACCESSORS

=over

=item name

String value of the symbol.

=item to_pl

Perl value of the symbol is just its C<name>.

=back

=for Pod::Coverage BUILDARGS

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
