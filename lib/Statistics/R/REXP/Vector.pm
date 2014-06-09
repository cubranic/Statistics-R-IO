package Statistics::R::REXP::Vector;
# ABSTRACT: an R vector

use 5.012;

use Scalar::Util qw(blessed);

use Moose::Role;

with 'Statistics::R::REXP';

requires qw(_type);

use overload '""' => sub { shift->_to_s; };

has type => (
    is => 'ro',
    default => sub { shift->_type; },
);

has elements => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { []; },
);


sub BUILDARGS {
    my $class = shift;
    if ( scalar @_ == 1 ) {
        if ( defined $_[0] ) {
            if ( ref $_[0] eq 'HASH' ) {
                return { %{ $_[0] } };
            } elsif ( ref $_[0] eq 'ARRAY' ) {
                return { elements => $_[0] };
            } elsif ( blessed $_[0] && $_[0]->can('does') &&
                      $_[0]->does('Statistics::R::REXP::Vector') ) {
                return { elements => $_[0]->elements };
            }
        }
        die "Single parameters to new() must be a HASH or ARRAY ref"
            ." data or a Statistics::R::REXP::Vector object => ". $_[0] ."\n";
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

    return undef unless $orig->(@_);

    my ($self, $obj) = (shift, shift);

    _compare_deeply($self->elements, $obj->elements)
};


sub _to_s {
    my $self = shift;
    my $stringify = sub { map { defined $_ ? $_ : 'undef'} @_ };
    $self->_type . '(' . join(', ', &$stringify(@{$self->elements})) . ')';
}


## Turns any references (nested lists) into a plain-old flat list.
## Lists can nest to an arbitrary level, but having references to
## anything other than arrays is not supported.
sub _flatten {
    map { ref $_ ? _flatten(@{$_}) : $_ } @_
}

sub is_vector {
    return 1;
}


sub to_pl {
    my $self = shift;
    [ map { (blessed $_ && $_->can('to_pl')) ?
                $_->to_pl : $_ }
          @{$self->elements} ]
}

1; # End of Statistics::R::REXP::Vector

__END__


=head1 SYNOPSIS

    use Statistics::R::REXP::Vector;
    
    # $vec is an instance of Vector
    $vec->does('Statistics::R::REXP::Vector');
    print $vec->elements;


=head1 DESCRIPTION

An object of this class represents an R vector. This class
cannot be directly instantiated (it's a L<Moose::Role>), because it is
intended as a base abstract class with concrete subclasses to
represent specific types of vectors, such as numeric or list.


=head1 METHODS

C<Statistics::R::REXP::Vector> inherits from L<Statistics::R::REXP>.

=head2 ACCESSORS

=over

=item elements

Returns an array reference to the vector's elements.

=item to_pl

Perl value of the symbol is an array reference to the Perl values of
its C<elements>. (That is, it's equivalent to C<map {$_->to_pl},
$vec->elements>.

=back

=for Pod::Coverage BUILDARGS is_vector


=head1 BUGS AND LIMITATIONS

Classes in the C<REXP> hierarchy are intended to be immutable. Please
do not try to change their value or attributes.

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.


=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.

=cut
