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
    is => 'rwp',
    default => sub { 0 },
);

sub at {
    my $self = shift;
    $self->data->[$self->position]
}

sub next {
    my $copy = shift->clone;
    $copy->_set_position($copy->position+1);
    $copy
}

sub eof {
    my $self = shift;
    $self->position >= scalar @{$self->data};
}

sub clone {
    my $self = shift;
    ref($self)->new(data => $self->data,
                    position => $self->position)
}
        
    
1;
