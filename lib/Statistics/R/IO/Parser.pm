package Statistics::R::IO::Parser;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Exporter 'import';

our @EXPORT = qw( );
our @EXPORT_OK = qw( endianness any_char char string byte
                     any_uint8 any_uint16 any_uint24 any_uint32 any_real32 any_real64
                     uint8 uint16 uint24 uint32
                     any_int8 any_int16 any_int24 any_int32
                     int8 int16 int24 int32
                     count with_count seq choose mreturn error add_singleton get_singleton reserve_singleton bind );

our %EXPORT_TAGS = ( all => [ @EXPORT_OK ],
                     num => [ qw( any_uint8 any_uint16 any_uint24 any_uint32 any_real32 any_real64 uint8 uint16 uint24 uint32 ) ],
                     char => [ qw( any_char char string byte ) ],
                     combinator => [ qw( count with_count seq choose mreturn bind ) ] );


use Scalar::Util qw(looks_like_number);
use Carp;

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


sub any_uint8 {
    my ($value, $state) = @{any_char @_ or return};
    
    [ unpack('C', $value), $state ]
}


sub any_uint16 {
    my ($value, $state) = @{count(2, \&any_uint8)->(@_) or return};
    
    [ unpack("S" . endianness, pack 'C2' => @{$value}),
      $state ]
}


sub any_uint24 {
    my ($value, $state) = @{count(3, \&any_uint8)->(@_) or return};
    
    [ unpack("L" . endianness,
             pack(endianness eq '>' ? 'xC3' : 'C3x', @{$value})),
      $state ]
}


sub any_uint32 {
    my ($value, $state) = @{count(4, \&any_uint8)->(@_) or return};
    
    [ unpack("L" . endianness, pack 'C4' => @{$value}),
      $state ]
}


sub uint8 {
    my $arg = shift;
    die 'Argument must be a number 0-255: ' . $arg
        unless looks_like_number($arg) && $arg < 1<<8 && $arg >= 0;
    
    sub {
        my ($value, $state) = @{any_uint8 @_ or return};
        return unless $arg == $value;
        
        [ $arg, $state ]
    }
}


sub uint16 {
    my $arg = shift;
    die 'Argument must be a number 0-65535: ' . $arg
        unless looks_like_number($arg) && $arg < 1<<16 && $arg >= 0;
    
    sub {
        my ($value, $state) = @{any_uint16 @_ or return};
        return unless $arg == $value;
        
        [ $arg, $state ]
    }
}


sub uint24 {
    my $arg = shift;
    die 'Argument must be a number 0-16777215: ' . $arg
        unless looks_like_number($arg) && $arg < 1<<24 && $arg >= 0;
    
    sub {
        my ($value, $state) = @{any_uint24 @_ or return};
        return unless $arg == $value;
        
        [ $arg, $state ]
    }
}


sub uint32 {
    my $arg = shift;
    die 'Argument must be a number 0-4294967295: ' . $arg
        unless looks_like_number($arg) && $arg < 1<<32 && $arg >= 0;
    
    sub {
        my ($value, $state) = @{any_uint32 @_ or return};
        return unless $arg == $value;
        
        [ $arg, $state ]
    }
}


sub any_int8 {
    my ($value, $state) = @{any_char @_ or return};
    
    [ unpack('c', $value), $state ]
}


sub any_int16 {
    my ($value, $state) = @{any_uint16 @_ or return};
    
    $value |= 0x8000 if ($value >= 1<<15);
    [ unpack('s', pack 's' => $value),
      $state ]
}


sub any_int24 {
    my ($value, $state) = @{any_uint24 @_ or return};
    
    $value |= 0xff800000 if ($value >= 1<<23);
    [ unpack('l', pack 'l' => $value),
      $state ]
}


sub any_int32 {
    my ($value, $state) = @{any_uint32 @_ or return};
    
    $value |= 0x80000000 if ($value >= 1<<31);
    [ unpack('l', pack 'l' => $value),
      $state ]
}


sub int8 {
    my $arg = shift;
    die 'Argument must be a number -128-127: ' . $arg
        unless looks_like_number($arg) && $arg < 1<<7 && $arg >= -(1<<7);
    
    sub {
        my ($value, $state) = @{any_int8 @_ or return};
        return unless $arg == $value;
        
        [ $arg, $state ]
    }
}


sub int16 {
    my $arg = shift;
    die 'Argument must be a number -32768-32767: ' . $arg
        unless looks_like_number($arg) && $arg < 1<<15 && $arg >= -(1<<15);
    
    sub {
        my ($value, $state) = @{any_int16 @_ or return};
        return unless $arg == $value;
        
        [ $arg, $state ]
    }
}


sub int24 {
    my $arg = shift;
    die 'Argument must be a number 0-16777215: ' . $arg
        unless looks_like_number($arg) && $arg < 1<<23 && $arg >= -(1<<23);
    
    sub {
        my ($value, $state) = @{any_int24 @_ or return};
        return unless $arg == $value;
        
        [ $arg, $state ]
    }
}


sub int32 {
    my $arg = shift;
    die 'Argument must be a number -2147483648-2147483647: ' . $arg
        unless looks_like_number($arg) && $arg < 1<<31 && $arg >= -(1<<31);
    
    sub {
        my ($value, $state) = @{any_int32 @_ or return};
        return unless $arg == $value;
        
        [ $arg, $state ]
    }
}


sub any_real32 {
    my ($value, $state) = @{count(4, \&any_uint8)->(@_) or return};
    
    [ unpack("f" . endianness, pack 'C4' => @{$value}),
      $state ]
}


sub any_real64 {
    my ($value, $state) = @{count(8, \&any_uint8)->(@_) or return};
    
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


sub mreturn {
    my $arg = shift;
    sub {
        [ $arg, shift ]
    }
}


sub error {
    my $message = shift;
    sub {
        my $state = shift;
        croak $message . " (at " . $state->position . ")";
    }
}


sub add_singleton {
    my $singleton = shift;
    sub {
        [ $singleton, shift->add_singleton($singleton) ]
    }
}


sub get_singleton {
    my $ref_id = shift;
    sub {
        my $state = shift;
        [ $state->get_singleton($ref_id), $state ]
    }
}


## Preallocates a space for a singleton before running a given parser,
## and then assigns the parser's value to the singleton.
sub reserve_singleton {

    my $p = shift;
    &bind(
        seq(
            sub {
                my $state = shift;
                my $ref_id = scalar(@{$state->singletons});
                my $new_state = $state->add_singleton(undef);
                [ $ref_id, $new_state ]
            },
            $p),
        sub {
            my ($ref_id, $value) = @{shift()};
            sub {
                my $state = shift;
                $state->singletons->[$ref_id] = $value;
                [ $value, $state ]
            }
        })
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


sub with_count {
    die "'bind' expects one or two arguments"
        unless @_ and scalar(@_) <= 2;

    unshift(@_, \&any_uint32) if (scalar(@_) == 1);
    my ($counter, $content) = (shift, shift);

    &bind($counter,
          sub {
              my $n = shift;
              count($n, $content)
          })
}


1;
