package Statistics::R::IO::ParserState;

use 5.012;

use Moo;
use namespace::clean;

has data => (
    is => 'ro',
    default => sub { [] },
    coerce => sub {
        my $x = shift;
        (!ref($x)) ? [split //, $x] : $x
    }
);

has position => (
    is => 'ro',
    default => sub { 0 },
);

has singletons => (
    is => 'ro',
    default => sub { [] },
);

sub at {
    my $self = shift;
    $self->data->[$self->position]
}

sub next {
    my $self = shift;
    
    ref($self)->new(data => $self->data,
                    position => $self->position+1,
                    singletons => [ @{$self->singletons} ])
}

sub add_singleton {
    my ($self, $singleton) = (shift, shift);

    my @new_singletons = @{$self->singletons};
    push @new_singletons, $singleton;
    ref($self)->new(data => $self->data,
                    position => $self->position,
                    singletons => [ @new_singletons ])
}

sub get_singleton {
    my ($self, $singleton_id) = (shift, shift);
    $self->singletons->[$singleton_id]
}

sub eof {
    my $self = shift;
    $self->position >= scalar @{$self->data};
}

    
1;
