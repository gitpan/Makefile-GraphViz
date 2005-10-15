use strict;
use inc::Module::Install;

my $gvmake = "script/gvmake.pl";

name            ('Makefile-GraphViz');
version_from    ('lib/Makefile/GraphViz.pm');
abstract       ( 'Plot the Detailed Structure of Makefiles Using GraphViz' );
author          ('Agent Zhang <agent2002@126.com>');
license         ('perl');

install_script  ($gvmake);

requires        ('GraphViz');
requires        ('Makefile::Parser' => 0.08);

build_requires  ('Test::More');
build_requires  ('File::Compare');

&WriteAll;
