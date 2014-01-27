package Statistics::R::IO::Parser;

use 5.012;
use strict;
use warnings FATAL => 'all';

sub char {
    my $state = shift;

    return undef if !$state || $state->eof;
    
    [$state->at, $state->next]
}


sub uint8 {
    my ($value, $state) = @{char @_ or return};
    
    [ unpack('C', $value), $state ]
}


sub uint16 {
    my ($value, $state) = @{count(2, \&uint8)->(@_) or return};
    
    [ unpack('S>', pack 'C2' => @{$value}),
      $state ]
}


sub uint24 {
    my ($value, $state) = @{count(3, \&uint8)->(@_) or return};
    
    [ unpack('L>', "\0" . pack 'C3' => @{$value}),
      $state ]
}


sub uint32 {
    my ($value, $state) = @{count(4, \&uint8)->(@_) or return};
    
    [ unpack('L>', pack 'C4' => @{$value}),
      $state ]
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
