package Statistics::R::REXP::Environment;

use 5.012;

use Scalar::Util qw(refaddr blessed);

use Moo;
use namespace::clean;

with 'Statistics::R::REXP';

has frame => (
    is => 'ro',
    default => sub {
        { }
    },
    isa => sub {
        die 'Environment frame must be a HASH reference'
            unless ref $_[0] eq ref {}
    },
);

has enclosure => (
    is => 'ro',
    isa => sub {
        my $parent_env = shift;
        die 'Environment enclosure must be another Environment'
            if defined $parent_env &&
                !(blessed $parent_env &&
                  $parent_env->isa('Statistics::R::REXP::Environment'))
    },
);


use overload
    '""' => sub { 'environment '. shift->name };


sub BUILDARGS {
    my $class = shift;
    if ( scalar @_ == 1 ) {
        if ( defined $_[0] ) {
            if ( ref $_[0] eq 'HASH' ) {
                return { %{ $_[0] } };
            } elsif ( blessed $_[0] && $_[0]->isa('Statistics::R::REXP::Environment') ) {
                # copy constructor from another environment
                return { frame => $_[0]->frame,
                         enclosure => $_[0]->enclosure };
            }
        }
        die "Single parameters to new() must be a HASH data"
            ." or a Statistics::R::REXP::Environment object => ". $_[0] ."\n";
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
    return unless $orig->(@_);
    my ($self, $obj) = (shift, shift);
    compare_deeply($self->frame, $obj->frame) &&
        compare_deeply($self->enclosure, $obj->enclosure)
};


sub name {
    my $self = shift;
    ($self->attributes && exists $self->attributes->{name}) ?
        $self->attributes->{name} :
        '0x' . sprintf('%x', refaddr $self)
}


sub to_pl {
    die "Environments do not have a native Perl representation"
}


1; # End of Statistics::R::REXP::Environment
