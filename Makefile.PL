use strict;
use inc::Module::Install;

my $viz_make = "script/viz-make";

name            ('Makefile-GraphViz');
version_from    ('lib/Makefile/GraphViz.pm');
abstract       ( 'Plot the Detailed Structure of Makefiles Using GraphViz' );
author          ('Agent Zhang <agent2002@126.com>');
license         ('perl');

#install_script  ($viz_make);

requires        ('GraphViz');
requires        ('Makefile::Parser');

build_requires  ('Test::More');
build_requires  ('File::Compare');

&WriteAll;
