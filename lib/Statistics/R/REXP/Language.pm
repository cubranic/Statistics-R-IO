package Statistics::R::REXP::Language;

use 5.012;

use Scalar::Util qw(blessed);

use Moo;
use namespace::clean;

extends 'Statistics::R::REXP::List';

has '+elements' => (
    isa => sub {
        die "Vector elements must be an ARRAY ref". $_[0] ."\n"
            if defined $_[0] and ref $_[0] ne ref [];
        my $first_element_isa = ref($_[0]->[0]);
        die 'The first element must be a Symbol or Language'
            unless $first_element_isa eq 'Statistics::R::REXP::Language' ||
                $first_element_isa eq 'Statistics::R::REXP::Symbol'
    },
);

around _type => sub { 'language' };

1; # End of Statistics::R::REXP::Language
