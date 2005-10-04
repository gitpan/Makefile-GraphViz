#: Makefile-GraphViz.t
#: Test Makefile::GraphViz
#: Copyright (c) 2005 Agent Zhang
#: v0.02
#: 2005-09-30 2005-10-04

use Test::More tests => 14;
use Makefile::GraphViz;
use File::Compare;

my $parser = Makefile::GraphViz->new;
ok $parser;
isa_ok $parser, 'Makefile::GraphViz';
ok $parser->parse("t/Makefile");
is $parser->{_file}, 't/Makefile';

# plot the tree rooted at the install target in Makefile:
#warn "Target: ", $parser->target('t\pat_cover.ast.asm');
my $gv = $parser->plot('t\\pat_cover.ast.asm');
ok $gv;
isa_ok $gv, 'GraphViz';
my $png = 't/doc.png';
ok $gv->as_png($png);
is File::Compare::compare($png, "$png.png"), 0;
unlink $png;

ok $parser->parse("t/Makefile2");
is $parser->{_file}, 't/Makefile2';

# plot the tree rooted at the install target in Makefile:
$gv = $parser->plot('install', trim_mode => 1);
ok $gv;
isa_ok $gv, 'GraphViz';
$png = 't/install.png';
ok $gv->as_png($png);
is File::Compare::compare($png, "$png.png"), 0;
unlink $png;
