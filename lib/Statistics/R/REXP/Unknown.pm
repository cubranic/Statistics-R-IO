package Statistics::R::REXP::Unknown;
# ABSTRACT: R object not representable in Rserve

use 5.010;

use Scalar::Util qw(looks_like_number blessed);

use Class::Tiny::Antlers qw(-default around);
use namespace::clean;

extends 'Statistics::R::REXP';

has _sexptype => (
    is => 'ro',
);

use overload
    '""' => sub { 'Unknown' };

sub BUILDARGS {
    my $class = shift;
    my $attributes = {};
    
    if ( scalar @_ == 1) {
        if ( ref $_[0] eq 'HASH' ) {
            $attributes = $_[0]
        }
        else {
            $attributes->{_sexptype} = $_[0]
        }
    }
    elsif ( @_ % 2 ) {
        die "The new() method for $class expects a hash reference or a key/value list."
                . " You passed an odd number of arguments\n";
    }
    else {
        $attributes = { @_ };
    }
    
    if (blessed($attributes->{_sexptype}) &&
        $attributes->{_sexptype}->isa('Statistics::R::REXP::Unknown')) {
        $attributes->{_sexptype} = $attributes->{_sexptype}->sexptype
    }
    $attributes
}


sub BUILD {
    my ($self, $args) = @_;

    die 'Attribute (_sexptype) does not pass the type constraint' unless
        looks_like_number($self->sexptype) &&
        ($self->sexptype >= 0) && ($self->sexptype <= 255)
}


sub sexptype {
    my $self = shift;

    $self->_sexptype
}

around _eq => sub {
    my $orig = shift;
    $orig->(@_) and ($_[0]->sexptype eq $_[1]->sexptype);
};


sub to_pl {
    undef
}


1; # End of Statistics::R::REXP::Unknown

__END__


=head1 SYNOPSIS

    use Statistics::R::REXP::Unknown;
    
    my $unknown = Statistics::R::REXP::Unknown->new(4);
    say $unknown->sexptype;
    say $unknown->to_pl;


=head1 DESCRIPTION

An object of this class represents an R object that's currently not
representable by the Rserve protocol.

=head1 METHODS

C<Statistics::R::REXP::Unknown> inherits from L<Statistics::R::REXP> and
adds no methods of its own.

=head2 ACCESSORS

=over

=item sexptype

The R L<SEXPTYPE|http://cran.r-project.org/doc/manuals/r-release/R-ints.html#SEXPTYPEs> of the object.

=item to_pl

The Perl value of the unknown type is C<undef>.

=back


=head1 BUGS AND LIMITATIONS

Classes in the C<REXP> hierarchy are intended to be immutable. Please
do not try to change their value or attributes.

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.


=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.

=cut
