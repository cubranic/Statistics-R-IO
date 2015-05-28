package Statistics::R::REXP::Closure;
# ABSTRACT: an R closure

use 5.010;

use Scalar::Util qw(refaddr blessed);

use Moose;
use namespace::clean;

with 'Statistics::R::REXP';


has '+sexptype' => (
    default => 'CLOSXP'
);

has args => (
    is => 'ro',
    default => sub { [] },
    isa => 'ArrayRef[Str]',
);

has defaults => (
    is => 'ro',
    default => sub { [] },
    isa => 'ArrayRef[Maybe[Statistics::R::REXP]]',
);

has body => (
    is => 'ro',
    required => 1,
    isa => 'Statistics::R::REXP',
);

has environment => (
    is => 'ro',
    isa => 'Maybe[Statistics::R::REXP::Environment]',
);


use overload
    '""' => sub {
        my $self = shift;
        'function('. join(', ', @{$self->args}) . ') ' . $self->body
    };


sub BUILDARGS {
    my $class = shift;
    if ( scalar @_ == 1 ) {
        if ( ref $_[0] eq 'HASH' ) {
            return $_[0];
        } elsif ( blessed $_[0] && $_[0]->isa('Statistics::R::REXP::Closure') ) {
            # copy constructor from another closure
            return { args => $_[0]->args,
                     defaults => $_[0]->defaults,
                     body => $_[0]->body,
                     environment => $_[0]->environment };
        }
        die "Single parameters to new() must be a HASH data"
            ." or a Statistics::R::REXP::Closure object => ". $_[0] ."\n";
    }
    elsif ( @_ % 2 ) {
        die "The new() method for $class expects a hash reference or a key/value list."
                . " You passed an odd number of arguments\n";
    }
    else {
        return {@_};
    }
}


sub BUILD {
    my $self = shift;

    my $defaults_length = @{$self->defaults};
    if ($defaults_length) {
        die 'argument names don\'t match their defaults' 
            unless $defaults_length == @{$self->args}
    }
}

around _eq => sub {
    my $orig = shift;
    return unless $orig->(@_);
    my ($self, $obj) = (shift, shift);
    _compare_deeply($self->args, $obj->args) &&
        ((scalar(grep {$_} @{$self->defaults}) == scalar(grep {$_} @{$obj->defaults})) ||
         _compare_deeply($self->defaults, $obj->defaults)) &&
        _compare_deeply($self->body, $obj->body) &&
        _compare_deeply($self->environment, $obj->environment)
};


sub to_pl {
    die "Closures do not have a native Perl representation"
}


__PACKAGE__->meta->make_immutable;

1; # End of Statistics::R::REXP::Closure

__END__


=head1 SYNOPSIS

    use Statistics::R::REXP::Closure
    
    my $clos = Statistics::R::REXP::Closure->new(body => {
        Statistics::R::REXP::Language->new([
            Statistics::R::REXP::Symbol->new('mean'),
            Statistics::R::REXP::Double->new([1, 2, 3])
    ])
    });
    print $env->elements;


=head1 DESCRIPTION

An object of this class represents an R closure (C<ENVSXP>). Closures
in R are constructed with C<function> and consist of a
arguments(I<args>) -- optionally with default values (I<defaults>); a
I<body>; and an I<environment>, a pointer to an enclosing evaluation
frame when the closure is used.

These objects represent calls (such as model formulae), with first
element a reference to the function being called, and the remainder
the actual arguments of the call. Names of arguments, if given, are
recorded in the 'names' attribute (itself as
L<Statistics::R::REXP::Character> vector), with unnamed arguments
having name C<''>. If no arguments were named, the environment objects
will not have a defined 'names' attribute.

You shouldn't create instances of this class, it exists mainly to
handle deserialization of C<ENVSXP>s by the C<IO> classes.


=head1 METHODS

C<Statistics::R::REXP:Environment> inherits from
L<Statistics::R::REXP>, with the added restriction that its first
element has to be a L<Statistics::R::REXP::Symbol> or another
C<Environment> instance. Trying to create a Closure instance that
doesn't follow this restriction will raise an exception.

=head2 ACCESSORS

=over

=item args

An reference to the array of argument names.

=item defaults

Returns an array reference to default values of corresponding
arguments, or C<undef>s if the argument does not have a default. (If
none of the arguments have defaults, this can be an empty array.

=item body

Returns the L<Statistics::R::REXP> representing the body of the
function.

=item environment

Returns a reference to the enclosing evaluation frame, i.e., the
environment within which the function is defined and looks up any free
variables. This attribute is optional because some serialization
mechanisms (notably Rserve's QAP), do not save the closure's
environment.

=item to_pl

Closures do not have a native Perl representation and trying to call
this access will raise an exception.

=back

=for Pod::Coverage BUILDARGS BUILD


=head1 BUGS AND LIMITATIONS

Classes in the C<REXP> hierarchy are intended to be immutable. Please
do not try to change their value or attributes.

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.


=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.

=cut
