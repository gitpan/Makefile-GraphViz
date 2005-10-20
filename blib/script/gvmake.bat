@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!perl
#line 15
#: gvmake
#: Command-line driver for Makefile::GraphViz
#: v0.08
#: Copyright (c) 2005 Agent Zhang
#: 2005-10-05 2005-10-17

use strict;
use warnings;

use Getopt::Std;
use Makefile::GraphViz;

our $VERSION = '0.08';

my %opts;
getopts('hf:o:', \%opts);

if ($opts{h}) {
    print <<_EOC_;
GVMAKE Version $VERSION
Copyright (c) 2005 Agent Zhang

Usage: gvmake [-h] [-f makefile] [-o pngfile] [target]

Report bugs to <agent2002\@126.com>.
_EOC_
    exit(0);
}

my $parser = Makefile::GraphViz->new;

my $makefile = $opts{f} || 'Makefile';
warn "parsing $makefile...\n";
$parser->parse($makefile) or die $parser->error;

my $tar = shift @ARGV || $parser->target;
warn "plotting target $tar...\n";
my $gv = $parser->plot($tar);

my $outfile = $opts{o} || "$tar.png";
$gv->as_png($outfile);
warn "$outfile generated.\n";

__END__

=head1 NAME

gvmake - A make tool that generates pretty graphs from Makefile

=head1 SYNOPSIS

    # print usage info to stdout:
    gvmake -h

    # if the default target is 'all', the following
    # command will generate all.png
    gvmake

    # this command will generate 'test.png' where
    # 'test' is a target defined in the Makefile:
    gvmake test

    # override the default output file name:
    gvmake -o make.png test

    # specify the Makefile name explicitly:
    gvmake -f t/Makefile.old install

=head1 DESCRIPTION

This is a make tool that generates pretty graphs for the building
process according to user's Makefile instead of actually building
something. It is a simple command-line frontend for the
L<Makefile::GraphViz> module.

Currently only PNG format and the default settings for the graph
style are used. This inflexible design will be changed soon.

=head1 TODO

=over

=item Add more command-line options to control the graph appearance

=item To support more output file format

=back

=head1 BUGS

Please report bugs or send wish-list to
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Makefile-GraphViz>.

=head1 SEE ALSO

L<Makefile::GraphViz>, L<Makefile::Parser>.

=head1 AUTHOR

Agent Zhang, E<lt>agent2002@126.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 Agent Zhang.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__END__
:endofperl