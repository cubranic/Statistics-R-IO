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

=head1 NAME

Statistics::R::IO - The great new Statistics::R::IO!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Statistics::R::IO;

    my $foo = Statistics::R::IO->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 readRDS

=cut

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
    
    if (substr($data, 0, 5) ne "RDX2\n") {
        croak 'File does not start with the RData magic number: ' .
            unpack('H*', substr($data, 0, 5));
    }

    my ($value, $state) = @{Statistics::R::IO::REXPFactory::unserialize(substr($data, 5))};
    croak 'Could not parse RData file' unless $state;
    croak 'Unread data remaining in the RData file' unless $state->eof;
    Statistics::R::IO::REXPFactory::tagged_pairlist_to_rexp_hash $value;
}


=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Davor Cubranic, C<< <cubranic at stat.ubc.ca> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-statistics-r-io at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Statistics-R-IO>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Statistics::R::IO


You can also look for information at:

=over 4

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

1; # End of Statistics::R::IO
