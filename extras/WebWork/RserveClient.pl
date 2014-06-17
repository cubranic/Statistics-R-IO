=head1 NAME

RserveClient.pl - Macros for evaluating R code on an Rserve server

=head1 SYNPOSIS

=head1 SYNOPSIS

    loadMacros('RserveClient.pl');
    
    rserve_start();
    my @rnorm = rserve_eval("rnorm(15, mean=$m, sd=$sd)");
    rserve_eval(data(stackloss));
    my @coeff = rserve_eval('lm(stack.loss ~ stack.x, stackloss)$coeff');
    rserve_finish();


=head1 DESCRIPTION

The macros in this file provide access to facilities of L<R
statistical computing environment|http://www.r-project.org>,
optionally located on another server, by using the
L<Rserve|http://www.rforge.net/Rserve/> protocol.


=head1 MACROS

The macros in this file set up a connection to the R server and
pass a string parameter to R for evaluation.  The resulting
vector is returned as a perl array object.

=over 4

=item rserve_eval REXPR

Evaluates an R expression, given as text string in REXPR, on the
L<Rserve|http://www.rforge.net/Rserve/> server and returns its result
as a Perl representation of the L<Statistics::R::REXP> object.
Multiple calls within the same problem share the R session and the
object workspace.

=item rserve_query

Evaluates an R expression, given as text string in REXPR, in a
single-use session on the L<Rserve|http://www.rforge.net/Rserve/>
server and returns its result as a Perl representation of the
L<Statistics::R::REXP> object.

This function is different from C<rserve_eval> in that each call is
completely self-enclosed and its R session is discarded after it
returns.

=item rserve_start, rserve_finish

Start up and close the current connection to the Rserve server. In
normal use, these functions are completely optional because the first
call to C<rserve_eval> will call start the session if one is not
already open. Similarly, the current session will be closed in its
destructor when the current question goes out of scope.

Other than backward compatibility, the only reason for using these
functions is to start a new clean session within a single problem,
which shouldn't be a common occurrence.

=item rserve_start_plot [IMG_TYPE]

Opens a new R graphics device to capture subsequent graphics output in
a temporary file on the R server. IMG_TYPE can be 'png', 'jpg', or
'pdf', with 'png' as the default. Returns the name of the remote file.


=item rserve_finish_plot REMOTE_NAME

Closes the R graphics capture to file REMOTE_NAME, transfers the file
to WebWork's temporary file area, and returns the name of the local
file that can then be used by the image macro.

=back


=head1 DEPENDENCIES

Requires perl 5.012 or newer and CPAN module Statistics::R::IO, which
has to be loaded in WebWork's Safe compartment by adding it to
${pg}{modules}.


=cut

## TODO: allow configuration
my $Rserve_server  = 'localhost';

my $rserve;                     # Statistics::R::IO::Rserve instance

sub rserve_start {
    $rserve = Statistics::R::IO::Rserve->new(server => $Rserve_server, _usesocket => 1);

    # Keep R's RNG reproducible for this problem
    $rserve->eval("set.seed($problemSeed)")
}


sub rserve_finish {
    $rserve->close() if $rserve;
    undef $rserve
}


sub rserve_eval {
    my $query = shift;
    
    rserve_start unless $rserve;
    
    my $result = $rserve->eval($query);
    _unref_rexp($result)
}


sub rserve_query {
    my $query = shift;
    $query = "set.seed($problemSeed)\n" . $query;
    my $rserve_client = Statistics::R::IO::Rserve->new(server => $Rserve_server, _usesocket => 1);
    my $result = $rserve_client->eval($query);
    $rserve_client->close;
    _unref_rexp($result)
}


## Returns a REXP's Perl representation, dereferencing it if it's an
## array reference
##
## `REXP::to_pl` returns a string scalar for Symbol, undef for Null,
## and an array reference to contents for all vector types. This
## function is a utility wrapper to make it easy to assign a Vector's
## representation to an array variable, while still working sensibly
## for non-arrays.
sub _unref_rexp {
    my $rexp = shift;
    
    my $value = $rexp->to_pl;
    if (ref($value) eq ref([])) {
        @{$value}
    } else {
        $value
    }
}

sub rserve_start_plot {
    my $device = shift // 'png';

    die "Unsupported image type $device" unless $device =~ /^(png|pdf|jpg)$/;
    my $remote_image = (rserve_eval("tempfile(fileext='.$device')"))[0];
    
    $device =~ s/jpg/jpeg/;
    rserve_eval("$device('$remote_image')");

    $remote_image
}


sub rserve_finish_plot {
    my $remote_image = shift or die "Missing remote image name";

    my $img_file = $PG->fileFromPath($remote_image);

    my $local_image = $PG->surePathToTmpFile($img_file);

    rserve_eval("dev.off()");

    $rserve->get_file($remote_image, $local_image);
    
    $local_image
}


1;
