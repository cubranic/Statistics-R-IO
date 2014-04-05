package ShortDoubleVector;
# ABSTRACT: numeric vector that compares elements using 

use 5.012;

use Scalar::Util qw(looks_like_number);

use Moo;
use namespace::clean;

extends 'Statistics::R::REXP::Double';

around _eq => sub {
    my $orig = shift;

    return unless Statistics::R::REXP::_eq @_;
    
    my ($self, $obj) = (shift, shift);

    my $a = $self->elements;
    my $b = $obj->elements;
    return undef unless scalar(@$a) == scalar(@$b);
    for (my $i = 0; $i < scalar(@{$a}); $i++) {
        return undef unless abs($a->[$i] - $b->[$i]) < 1e-13;
    }
    
    1
};


## we have to REXPs `_compare_deeply` this way because private methods
## aren't available in the subclass
sub _compare_deeply {
    Statistics::R::REXP::Double::_compare_deeply(@_)
}

sub _type { 'shortdouble'; }

1;
