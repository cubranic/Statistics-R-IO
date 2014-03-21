package Statistics::R::IO::RData;

use 5.012;

use Moo;

use Statistics::R::IO::REXPFactory;
use IO::Handle;
use IO::Uncompress::Gunzip ();
use IO::Uncompress::Bunzip2 ();
use Carp;

use namespace::clean;


has fh => (
    is => 'ro',
    required => 1,
    isa => sub {
        die "RData 'fh' must be a file handle"
            unless UNIVERSAL::isa($_[0], 'IO::Handle') ||
            UNIVERSAL::isa($_[0], 'GLOB')
    }
);


sub BUILDARGS {
    my $class = shift;
    if ( scalar @_ == 1 ) {
        if ( defined $_[0] ) {
            if ( ref $_[0] eq 'HASH' ) {
                return { %{ $_[0] } }
            } elsif (ref $_[0] eq '') {
                my $name = shift;
                die "No such file '$name'" unless -r $name;
                my $fh = IO::File->new($name);
                return { fh => $fh }
            }
        }
        die "Single parameters to new() must be a HASH ref or filename scalar"
    }
    elsif ( @_ % 2 ) {
        die "The new() method for $class expects a hash reference or a key/value list."
                . " You passed an odd number of arguments\n";
    }
    else {
        return {@_}
    }
}


sub read {
    my $self = shift;
    
    my $data;
    $self->fh->sysread($data, 1<<30);
    if (substr($data, 0, 2) eq "\x1f\x8b") {
        ## gzip-compressed file
        $self->fh->sysseek(0, 0);
        IO::Uncompress::Gunzip::gunzip $self->fh, \$data;
    }
    elsif (substr($data, 0, 3) eq 'BZh') {
        ## bzip2-compressed file
        $self->fh->sysseek(0, 0);
        IO::Uncompress::Bunzip2::bunzip2 $self->fh, \$data;
    }
    elsif (substr($data, 0, 6) eq "\xfd7zXZ\0") {
        croak "xz-compressed RData files are not supported";
    }
    
    if (substr($data, 0, 5) ne "RDX2\n") {
        croak 'File does not start with the RData magic number: ' .
            unpack('H*', substr($data, 0, 5));
    }

    my ($value, $state) = @{Statistics::R::IO::REXPFactory::unserialize(substr($data, 5))};
    croak 'Could not parse RData file' unless $state;
    croak 'Unread data remaining in the RData file' unless $state->eof;
    Statistics::R::IO::REXPFactory::tagged_pairlist_to_rexp_hash $value;
}


sub close {
    my $self = shift;
    $self->fh->close
}


sub DEMOLISH {
    my $self = shift;
    ## TODO: should only close if given a filename (OR autoclose, if I
    ## choose to implement it)
    $self->close if $self->fh
}


# sub eof {
#     my $self = shift;
#     $self->position >= scalar @{$self->data};
# }

    
1;

__END__


=head1 NAME

Statistics::R::IO::RData - Supply object methods for RData files


=head1 VERSION

This documentation refers to version 0.03 of the module.


=head1 SYNOPSIS

    use Statistics::R::IO::RData;
    
    my $rdata = Statistics::R::IO::RData->new('.RData');
    my %r_workspace = $rdata->read;
    while (my ($var_name, $value) = each %r_workspace) {
        print $var_name, $value;
    }
    $rdata->close;

=head1 DESCRIPTION

C<Statistics::R::IO::RData> provides an object-oriented interface to
parsing RData files. RData files store a serialization of a collection
of I<named> objects, typically a workspace. These files are created in
R using the C<save> function and are typically named with the
C<.RData> file extension. (Contents of the R workspace can also be
saved automatically on exit to the file named F<.RData>, which is by
default automatically read in on startup.)


=head1 METHODS

=head2 CONSTRUCTOR

=over

=item new $filename

The single-argument constructor can be invoked with a scalar
containing the name of the RData file. This file will be immediately
opened for reading using L<IO::File>. The method will raise an
exception if the file is not readable.

=item new ATTRIBUTE_HASH_OR_HASH_REF

The constructor's arguments can also be given as a hash or hash
reference, specifying values of the object attributes (in this case,
'fh', for which any subclass of L<IO::Handle> can be used).

=back


=head2 ACCESSORS

=over

=item fh

A file handle (stored as a reference to the L<IO::Handle>) to the data
being parsed.

=back


=head2 METHODS

=over

=item read

Reads a contents of the filehandle and returns a hash whose keys are
the names of objects stored in the file with corresponding values as
L<Statistics::R::REXP> instances.

=item close

Closes the object's filehandle. This method is automatically invoked
when the object is destroyed.

=back


=head1 BUGS AND LIMITATIONS

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.


=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.


=head1 AUTHOR

Davor Cubranic, C<< <cubranic at stat.ubc.ca> >>


=head1 LICENSE AND COPYRIGHT

Copyright 2014 University of British Columbia.

See L<Statistics::R::IO> for the license.

=cut
