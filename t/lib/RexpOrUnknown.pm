package RexpOrUnknown;
# ABSTRACT: Utility class that is equal to a specified object or XT_UNKNOWN

use 5.010;

use Scalar::Util qw(blessed);

use Statistics::R::REXP::Unknown;

use Moose;
use namespace::clean;

has obj => (
    is => 'ro',
    required => 1,
    );

use overload
    '""' => sub {
        my $self = shift;
        'maybe ' . $self->obj
    },
    eq => sub {
        my ($self, $obj) = @_;
        return $self->obj eq $obj ||
            blessed $obj && $obj->isa('Statistics::R::REXP::Unknown')
    };

sub BUILDARGS {
    my $class = shift;
    if ( scalar @_ == 1 ) {
        if ( ref $_[0] eq 'HASH' ) {
            return $_[0];
        }
        else {
            return { obj => $_[0] }
        }
    }
    else {
        return @_
    }
}

1; # end of RexpOrUnknown
