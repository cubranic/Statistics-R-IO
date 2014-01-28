package Statistics::R::IO::Parser;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Scalar::Util qw(looks_like_number);

sub endianness {
    state $endianness = '>';
    my $new_value = shift if @_ or return $endianness;
    $endianness = $new_value =~ /^[<>]$/ && $new_value || $endianness;
}


sub any_char {
    my $state = shift;

    return undef if !$state || $state->eof;
    
    [$state->at, $state->next]
}


sub char {
    my $arg = shift;
    die 'Must be a single-char argument: ' . $arg unless length($arg) == 1;
    
    sub {
        my $state = shift or return;
        return if $state->eof || $arg ne $state->at;
        
        [ $arg, $state->next ]
    }
}


sub string {
    my $arg = shift;
    die 'Must be a scalar argument: ' . $arg unless $arg && !ref($arg);
    my $chars = count(length($arg), \&any_char);

    sub {
        my ($char_values, $state) = @{$chars->(@_) or return};
        return unless join('', @{$char_values}) eq $arg;
        [ $arg, $state ]
    }
}


sub byte {
    my $arg = shift;
    die 'Argument must be a number 0-255: ' . $arg
        unless looks_like_number($arg) && $arg < 256 && $arg >= 0;
    
    sub {
        my ($value, $state) = @{any_char @_ or return};
        return unless $arg == unpack('C', $value);

        [ $arg, $state ]
    }
}


sub uint8 {
    my ($value, $state) = @{any_char @_ or return};
    
    [ unpack('C', $value), $state ]
}


sub uint16 {
    my ($value, $state) = @{count(2, \&uint8)->(@_) or return};
    
    [ unpack("S" . endianness, pack 'C2' => @{$value}),
      $state ]
}


sub uint24 {
    my ($value, $state) = @{count(3, \&uint8)->(@_) or return};
    
    [ unpack("L" . endianness,
             pack(endianness eq '>' ? 'xC3' : 'C3x', @{$value})),
      $state ]
}


sub uint32 {
    my ($value, $state) = @{count(4, \&uint8)->(@_) or return};
    
    [ unpack("L" . endianness, pack 'C4' => @{$value}),
      $state ]
}


sub real32 {
    my ($value, $state) = @{count(4, \&uint8)->(@_) or return};
    
    [ unpack("f" . endianness, pack 'C4' => @{$value}),
      $state ]
}


sub real64 {
    my ($value, $state) = @{count(8, \&uint8)->(@_) or return};
    
    [ unpack("d" . endianness, pack 'C8' => @{$value}),
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


sub seq {
    my @parsers = @_;
    
    sub {
        my $state = shift;
        my @value;

        foreach my $parser (@parsers) {
            my $result = $parser->($state) or return;

            push @value, shift @$result;
            $state = shift @$result;
        }

        return [ [ @value ], $state ];
    }
}


sub choose {
    my @parsers = @_;
    
    sub {
        my $state = shift or return;
        
        foreach my $parser (@parsers) {
            my $result = $parser->($state);
            return $result if $result;
        }
        
        return;
    }
}


sub bind {
    my ($p1, $fp2) = (shift, shift);
    die "'bind' expects two arguments" unless $p1 && $fp2;
    
    sub {
        my $v1 = $p1->(shift or return);
        
        my ($value, $state) = @{$v1 or return};
        $fp2->($value)->($state)
    }
}


1;
