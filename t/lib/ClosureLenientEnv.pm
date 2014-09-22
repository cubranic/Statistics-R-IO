package ClosureLenientEnv;
# ABSTRACT: closure that is equal to another closure if it only differs by undefined environment

use 5.010;

use Scalar::Util qw(looks_like_number);

use Moose;
use namespace::clean;

extends 'Statistics::R::REXP::Closure';

## Loosen the equality check to accept another closure if it only
## differs by having an undefined environment
around _eq => sub {
    my $orig = shift;

    return unless Statistics::R::REXP::_eq @_;
    
    my ($self, $obj) = (shift, shift);

    ## Duplicate from REXP::Closure, except for looser check on 'environment'
    _compare_deeply($self->args, $obj->args) &&
        ((scalar(grep {$_} @{$self->defaults}) == scalar(grep {$_} @{$obj->defaults})) ||
         _compare_deeply($self->defaults, $obj->defaults)) &&
         _compare_deeply($self->body, $obj->body) &&
         ## if the other closure has undefined environment, accept that as OK
         (defined($obj->environment) ?
          _compare_deeply($self->environment, $obj->environment) : 1)
};


## we have to REXPs `_compare_deeply` this way because private methods
## aren't available in the subclass
sub _compare_deeply {
    Statistics::R::REXP::Double::_compare_deeply(@_)
}

sub _type { 'shortdouble'; }

1; # End of ClosureLenientEnv
