package Statistics::R::REXP::Symbol;

use 5.012;
use strict;
use warnings FATAL => 'all';

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

1; # End of Statistics::R::REXP::Symbol
