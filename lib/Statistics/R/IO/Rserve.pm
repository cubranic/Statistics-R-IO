package Statistics::R::IO::Rserve;
# ABSTRACT: Supply object methods for Rserve communication
$Statistics::R::IO::Rserve::VERSION = '0.06';
use 5.012;

use Moo;

use Statistics::R::IO::REXPFactory;
use Statistics::R::IO::QapEncoding;
use IO::Socket::INET ();
use Scalar::Util qw(blessed looks_like_number);
use Carp;

use namespace::clean;


has fh => (
    is => 'ro',
    default => sub {
        my $self = shift;
        my $fh = IO::Socket::INET->new(PeerAddr => $self->server,
                                       PeerPort => $self->port) or
                                  croak $!;
        $fh->sysread(my $response, 32);
        croak "Unrecognized server ID" unless
            substr($response, 0, 12) eq 'Rsrv0103QAP1';
        $fh
    },
    isa => sub {
        my $obj = shift;
        die "'fh' must be a file handle"
            unless blessed($obj) && $obj->isa('IO::Handle')
    }
);

has server => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        $self->fh ? $self->fh->peerhost : 'localhost'
    },
);

has port => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        $self->fh ? $self->fh->peerport : 6311
    },
    isa => sub {
        die "'port' must be a number"
            unless looks_like_number($_[0])
    },
);


has _autoclose => (
    is => 'ro',
    default => 0
);


sub BUILDARGS {
    my $class = shift;
    
    if ( scalar @_ == 0 ) {
        return { server => 'localhost',
                 port => 6311,
                 _autoclose => 1 }
    } elsif ( scalar @_ == 1 ) {
        if ( defined $_[0] ) {
            if ( ref $_[0] eq 'HASH' ) {
                return { %{ $_[0] } }
            } elsif (ref $_[0] eq '') {
                my $server = shift;
                return { server => $server,
                         port => 6311,
                         _autoclose => 1  }
            } elsif (UNIVERSAL::isa($_[0], 'IO::Handle')) {
                my $fh = shift;
                return { fh => $fh,
                         _autoclose => 0  }
            }
        }
        die "Single parameters to new() must be a HASH ref, an IO::Handle of the server connection, or server name scalar"
    }
    elsif ( @_ % 2 ) {
        die "The new() method for $class expects a hash reference or a key/value list."
                . " You passed an odd number of arguments\n";
    }
    else {
        return {@_}
    }
}


sub eval {
    my ($self, $expr) = (shift, shift);

    # Encode $expr as DT_STRING
    my $parameter = pack('VZ*',
                         ((length($expr)+1) << 8) + 4,
                         $expr);

    ## CMD_eval is 0x03
    my $data = $self->_send_command(0x03, $parameter);

    my ($value, $state) = @{Statistics::R::IO::QapEncoding::decode($data)};
    croak 'Could not parse Rserve value' unless $state;
    croak 'Unread data remaining in the Rserve response' unless $state->eof;
    $value
}


sub ser_eval {
    my ($self, $rexp) = (shift, shift);
    
    ## simulate the request parameter as constructed by:
    ## > serialize(quote(parse(text="{$rexp}")[[1]]), NULL)
    my $parameter =
        "\x58\x0a\0\0\0\2\0\3\0\3\0\2\3\0\0\0\0\6\0\0\0\1\0\4\0" .
        "\x09\0\0\0\2\x5b\x5b\0\0\0\2\0\0\0\6\0\0\0\1\0\4\0\x09\0\0" .
        "\0\5\x70\x61\x72\x73\x65\0\0\4\2\0\0\0\1\0\4\0\x09\0\0\0\4\x74\x65" .
        "\x78\x74\0\0\0\x10\0\0\0\1\0\4\0\x09" .
        pack('N', length($rexp)+2) .
        "\x7b" . $rexp . "\x7d" .
        "\0\0\0\xfe\0\0\0\2\0\0\0\x0e\0\0\0\1\x3f\xf0\0\0\0\0\0\0" .
        "\0\0\0\xfe";
    ## request is:
    ## - command (0xf5, CMD_serEval,
    ##       means raw serialized data without data header)
    my $data = $self->_send_command(0xf5, $parameter);
    
    my ($value, $state) = @{Statistics::R::IO::REXPFactory::unserialize($data)};
    croak 'Could not parse Rserve value' unless $state;
    croak 'Unread data remaining in the Rserve response' unless $state->eof;
    $value
}


## Sends a request to Rserve and receives the response, checking for
## any errors.
## 
## Returns the data portion of the server response
sub _send_command {
    my ($self, $command, $parameters) = (shift, shift, shift || '');
    
    ## request is (byte order is low-endian):
    ## - command (4 bytes)
    ## - length of the message (low 32 bits)
    ## - offset of the data part (normally 0)
    ## - high 32 bits of the length of the message (0 if < 4GB)
    $self->fh->syswrite(pack('V4', $command, length($parameters), 0, 0) .
                        $parameters);
    
    $self->fh->sysread(my $response, 16);
    ## Of the next four long-ints:
    ## - the first one is status and should be 65537 (bytes \1, \0, \1, \0)
    ## - the second one is length
    ## - the third and fourth are ??
    my ($status, $length) = unpack VV => substr($response, 0, 8);
    unless ($status == 65537) {
        croak 'Server returned an error: ' . $status;
    }
    
    $self->fh->sysread(my $data, $length);
    
    $data
}


sub close {
    my $self = shift;
    $self->fh->close
}


sub DEMOLISH {
    my $self = shift;
    $self->close if $self->_autoclose
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Statistics::R::IO::Rserve - Supply object methods for Rserve communication

=head1 VERSION

version 0.06

=head1 SYNOPSIS

    use Statistics::R::IO::Rserve;
    
    my $rserve = Statistics::R::IO::RDS->new('someserver');
    my $var = $rserve->eval('1+1');
    print $var->to_pl;
    $rserve->close;

=head1 DESCRIPTION

C<Statistics::R::IO::Rserve> provides an object-oriented interface to
communicate with the L<Rserve|http://www.rforge.net/Rserve/> binary R
server.

This allows Perl programs to access all facilities of R without the
need to have a local install of R or link to an R library.

=head1 METHODS

=head2 CONSTRUCTOR

=over

=item new $server

The single-argument constructor can be invoked with a scalar
containing the host name of the Rserve server. The method will
immediately open a connection to the server using L<IO::Socket::INET>
and perform the initial steps prescribed by the protocol. The method
will raise an exception if the connection cannot be established or if
the remote host does not appear to run the correct version of Rserve.

=item new $handle

The single-argument constructor can be invoked with an instance of
L<IO::Handle> containing the connection to the Rserve server, which
becomes the 'fh' attribute. The caller is responsible for ensuring
that the connection is established and ready for submitting client
requests.

=item new ATTRIBUTE_HASH_OR_HASH_REF

The constructor's arguments can also be given as a hash or hash
reference, specifying values of the object attributes. The caller
passing the handle is responsible for ensuring that the connection is
established and ready for submitting client requests.

=item new

The no-argument constructor uses the default server name 'localhost'
and port 6311 and immediately opens a connection to the server using
L<IO::Socket::INET>, performing the initial steps prescribed by the
protocol. The method will raise an exception if the connection cannot
be established or if the remote host does not appear to run the
correct version of Rserve.

=back

=head2 ACCESSORS

=over

=item server

Name of the Rserve server.

=item port

Port of the Rserve server.

=item fh

A connection handle (stored as a reference to the L<IO::Handle>) to
the Rserve server.

=back

=head2 METHODS

=over

=item eval EXPR

Evaluates an R expression, given as text string in REXPR, on an
L<Rserve|http://www.rforge.net/Rserve/> server and returns its result
as a L<Statistics::R::REXP> object.

=item ser_eval EXPR

Evaluates an R expression, given as text string in REXPR, on an
L<Rserve|http://www.rforge.net/Rserve/> server and returns its result
as a L<Statistics::R::REXP> object. This method uses the CMD_serEval
Rserve command (code 0xf5), which is designated as "internal/special"
and "should not be used by clients". Consequently, it is not
recommended to use this method in a production environment, but only
to help debug cases where C<eval> isn't working as desired.

=item close

Closes the object's filehandle. This method is automatically invoked
when the object is destroyed if the connection was opened by the
constructor, but not if it was passed in as a pre-opened handle.

=back

=for Pod::Coverage BUILDARGS DEMOLISH

=head1 BUGS AND LIMITATIONS

Instances of this class are intended to be immutable. Please do not
try to change their value or attributes.

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.

=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.

=head1 AUTHOR

Davor Cubranic <cubranic@stat.ubc.ca>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by University of British Columbia.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
