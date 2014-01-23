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
                $_[0] ."\n";
        }
    },
);

use overload
    'cmp' => \&cmp,
    '""' => sub { 'symbol `'. shift->name .'`' };

sub cmp {
    my ($self, $obj) = (shift, shift);
    return (equal_class($self, $obj) and
            ($self->name cmp $obj->name));
}

1; # End of Statistics::R::REXP::Symbol
