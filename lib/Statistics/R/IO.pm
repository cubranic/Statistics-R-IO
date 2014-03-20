package Statistics::R::IO;

use 5.012;
use strict;
use warnings FATAL => 'all';

use Exporter 'import';

our @EXPORT = qw( );
our @EXPORT_OK = qw( readRDS readRData );

our %EXPORT_TAGS = ( all => [ @EXPORT_OK ], );

use Statistics::R::IO::REXPFactory;
use IO::Uncompress::Gunzip ();
use IO::Uncompress::Bunzip2 ();
use Carp;

our $VERSION = '0.02';


sub readRDS {
    open (my $f, shift) or croak $!;
    my $data;
    sysread($f, $data, 1<<30);
    if (substr($data, 0, 2) eq "\x1f\x8b") {
        ## gzip-compressed file
        sysseek($f, 0, 0);
        IO::Uncompress::Gunzip::gunzip $f, \$data;
    }
    elsif (substr($data, 0, 3) eq 'BZh') {
        ## bzip2-compressed file
        sysseek($f, 0, 0);
        IO::Uncompress::Bunzip2::bunzip2 $f, \$data;
    }
    elsif (substr($data, 0, 6) eq "\xfd7zXZ\0") {
        croak "xz-compressed RDS files are not supported";
    }
    
    my ($value, $state) = @{Statistics::R::IO::REXPFactory::unserialize($data)};
    croak 'Could not parse RDS file' unless $state;
    croak 'Unread data remaining in the RDS file' unless $state->eof;
    $value
}


sub readRData {
    open (my $f, shift) or croak $!;
    my $data;
    sysread($f, $data, 1<<30);
    if (substr($data, 0, 2) eq "\x1f\x8b") {
        ## gzip-compressed file
        sysseek($f, 0, 0);
        IO::Uncompress::Gunzip::gunzip $f, \$data;
    }
    elsif (substr($data, 0, 3) eq 'BZh') {
        ## bzip2-compressed file
        sysseek($f, 0, 0);
        IO::Uncompress::Bunzip2::bunzip2 $f, \$data;
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

1; # End of Statistics::R::IO

__END__


=head1 NAME

Statistics::R::IO - Perl interface to serialized R data


=head1 VERSION

This documentation refers to version 0.02 of the module.


=head1 SYNOPSIS

    use Statistics::R::IO;
    
    my $var = Statistics::R::IO::readRDS('file.rds');
    print $var->to_pl;
    
    my %r_workspace = Statistics::R::IO::readRData('.RData');
    while (my ($var_name, $value) = each %r_workspace) {
        print $var_name, $value;
    }


=head1 DESCRIPTION

This module is a pure-Perl implementation for reading native data
files produced by the L<R statistical computing
environmnent|http://www.r-project.org>)

It provides routines for reading files in the two primary file
formats used in R for serializing native objects:

=over

=item RDS

RDS files store a serialization of a single R object (and, if the
object contains references to other objects, such as environments, all
the referenced objects as well). These files are created in R using
the C<readRDS> function and are typically named with the C<.rds> file
extension.

=item RData

RData files store a serialization of a collection of I<named> objects,
typically a workspace. These files are created in R using the C<save>
function and are typically named with the C<.RData> file extension.
(Contents of the R workspace can also be saved automatically on exit
to the file named F<.RData>, which is by default automatically read in
on startup.)

=back

See L</SUBROUTINES> for invocation and usage information on individual
subroutines, and the L<R Internals
manual|http://cran.r-project.org/doc/manuals/R-ints.html> for the
specification of the file formats.


=head1 EXPORT

Nothing by default. Optionally, subroutines C<readRDS> and
C<readRData>, or C<:all> for both.


=head1 SUBROUTINES

=over 4

=item readRDS EXPR

Reads a file in RDS format whose filename is given by EXPR and returns
a L<Statistics::R::REXP> object.

=item readRData EXPR

Reads a file in RData format whose filename is given by EXPR and
returns a hash whose keys are the names of objects stored in the file
with corresponding values as L<Statistics::R::REXP> instances.

=back


=head1 DEPENDENCIES

Requires perl 5.012 or newer.

=head2 Core modules

=over

=item * strict

=item * warnings

=item * overload

=item * Carp

=item * Exporter

=item * Module::Build

=item * Scalar::Util

=item * Test::More

=back

=head2 Additional CPAN modules

=over

=item * Moo

=item * namespace::clean

=item * Test::Fatal

=back


=head1 BUGS AND LIMITATIONS

The module currently handles the 'version 2' serialization format,
used since R 1.4.0 (released in December 2001). Only XDR and
native-order binary is implemented, and since the R documentation
describes the ASCII save format as "now mainly of historical
interest", this is unlikely to change soon. No check is performed that
a file stored in native-order binary was created on a platform that
used the same order, and it is up to the caller to ensure
compatibility. (Given that the default save format is XDR, and the
prevalence of Intel platforms, this is unlikely to be a problem for
either publicly-distributed or internal data files.)

Data files compressed with 'gzip' and 'bzip2' are supported, but not
'xz' ones. Again, given the R defaults ('gzip') and the fact that
C<IO::Uncompress::UnXz> is not production-ready, this is unlikely to
change soon.

There are some R types that are not (yet) implemented, although all
typical "user-facing" types -- such as vectors, lists, and
environments -- are. The remaining R types will be implemented
as-needed; in other words, if you come across one that you need to
read a particular file, please send me the type (the id will included
in the "unimplemented SEXPTYPE" error message) and, if possible, how
it was generated.

There are no known bugs in this module. Please report any bugs or
feature requests to C<bug-statistics-r-io at rt.cpan.org>, or through
the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Statistics-R-IO>. I
will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Statistics::R::IO


You can also look for information at:

=over

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Statistics-R-IO>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Statistics-R-IO>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Statistics-R-IO>

=item * Search CPAN

L<http://search.cpan.org/dist/Statistics-R-IO/>

=back


=head1 AUTHOR

Davor Cubranic, C<< <cubranic at stat.ubc.ca> >>


=head1 LICENSE AND COPYRIGHT

Copyright 2014 University of British Columbia.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.


=cut
