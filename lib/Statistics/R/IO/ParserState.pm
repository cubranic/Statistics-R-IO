package Statistics::R::IO::ParserState;
# ABSTRACT: Current state of the IO parser
$Statistics::R::IO::ParserState::VERSION = '0.06';
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

__END__

=pod

=encoding UTF-8

=head1 NAME

Statistics::R::IO::ParserState - Current state of the IO parser

=head1 VERSION

version 0.06

=head1 SYNOPSIS

    use Statistics::R::IO::ParserState;
    
    my $state = Statistics::R::IO::ParserState->new(
        data => 'file.rds'
    );
    say $state->at
    say $state->next->at;

=head1 DESCRIPTION

You shouldn't create instances of this class, it exists mainly to
handle deserialization of R data files by the C<IO> classes.

=head1 METHODS

=head2 ACCESSORS

=over

=item data

An array reference to the data being parsed. The constructs accepts a
scalar, which will be L<split> into individual characters.

=item position

Position of the next data element to be processed.

=item at

Returns the element (byte) at the current C<position>.

=item eof

Returns true if the cursor (C<position>) is at the end of the C<data>.

=item singletons

An array reference in which unserialized data that should be exists as
singletons can be "stashed" by the parser for later reference.

=item get_singleton $id

Return the singleton data object with the given C<$id>.

=back

=head2 MUTATORS

C<ParserState> is intended to be immutable, so the "mutator" methods
actually return a new instance with appropriately modified values of
the attributes.

=over

=item next

Returns a new ParserState instance with C<position> advanced by one.

=item add_singleton $singleton

Returns a new ParserState instance with C<$singleton> argument
appended to the instance's C<singletons>.

=back

=head1 BUGS AND LIMITATIONS

Instances of this class are intended to be immutable. Please do not
try to change their value or attributes.

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
