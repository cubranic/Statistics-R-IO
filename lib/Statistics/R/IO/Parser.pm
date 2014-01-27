package Statistics::R::IO::Parser;

use 5.012;
use strict;
use warnings FATAL => 'all';

sub char {
    my $state = shift;

    return undef if !$state || $state->eof;
    
    [$state->at, $state->next]
}


sub count {
    my ($n, $parser) = (shift, shift);
    sub {
        my $state = shift;
        my @value;

        for (1..$n) {
            my $result = $parser->($state) or return;

            push @value, shift @$result;
            $state = shift @$result;
        }

        return [ [ @value ], $state ];
    }
}

1;
