#: Makefile-GraphViz.t
#: Test Makefile::GraphViz
#: Copyright (c) 2005 Agent Zhang
#: v0.06
#: 2005-09-30 2005-10-05

use Test::More tests => 34;
use Makefile::GraphViz;
use File::Compare;

my $debug = 0;

my $parser = Makefile::GraphViz->new;
ok $parser;
isa_ok $parser, 'Makefile::GraphViz';
ok $parser->parse("t/Makefile");
is $parser->{_file}, 't/Makefile';

# plot the tree rooted at the install target in Makefile:
#warn "Target: ", $parser->target('t\pat_cover.ast.asm');
my $gv = $parser->plot(
    't\\pat_cover.ast.asm',
    vir_nodes    => ['pat_cover'],
    normal_nodes => [qw(pat_cover.ast C\\idu.lib)],
);
ok $gv;
isa_ok $gv, 'GraphViz';
my $outfile = 't/doc.dot';
ok $gv->as_canon($outfile);
#$gv->as_plain('t/tmp.dot');
is File::Compare::compare_text($outfile, "$outfile~"), 0;
unlink $outfile if !$debug;

$gv = $parser->plot(
    'cmintester',
    exclude  => [qw(
        all hex2bin.exe exe2hex.pl bin2asm.pl
        asm2ast.pl ast2hex.pl cod2ast.pl
    )],
    end_with => [qw(pat_cover.ast pat_cover)],
    normal_nodes => ['pat_cover.ast'],
    vir_nodes => ['pat_cover'],
    trim_mode => 0,
);
ok $gv;
isa_ok $gv, 'GraphViz';
my $tar = $parser->target('types.cod');
ok $tar;
is join("\n", $tar->commands), "cl /nologo /c /FAsc types.c\ndel types.obj";
is Makefile::GraphViz::trim_cmd('del types.obj'), 'del types.obj';
is Makefile::GraphViz::trim_cmd("del t\\tmp"), "del t\\\\tmp";

$outfile = 't/cmintest.dot';
ok $gv->as_canon($outfile);
#$gv->as_png('t/cmintest.png');
is File::Compare::compare_text($outfile, "$outfile~"), 0;
unlink $outfile if !$debug;

ok $parser->parse("t/Makefile2");
is $parser->{_file}, 't/Makefile2';

# plot the tree rooted at the install target in Makefile:
$gv = $parser->plot('install', trim_mode => 1);
ok $gv;
isa_ok $gv, 'GraphViz';
$outfile = 't/install.dot';
ok $gv->as_canon($outfile);
is File::Compare::compare_text($outfile, "$outfile~"), 0;
unlink $outfile if !$debug;

$gv = $parser->plot(
    'install',
    trim_mode => 1,
    edge_style => {
        style => 'dashed',
        color => 'seagreen',
    },
    normal_node_style => {
       shape => 'circle',
       style => 'filled',
       fillcolor => 'red',
    },
    vir_nodes => ['config', 'pure_all'],
    vir_node_style => {
       shape => 'diamond',
       style => 'filled',
       fillcolor => 'yellow',
    },
);
ok $gv;
isa_ok $gv, 'GraphViz';
$outfile = 't/install2.dot';
ok $gv->as_canon($outfile);
is File::Compare::compare_text($outfile, "$outfile~"), 0;
unlink $outfile if !$debug;

$parser->parse('t/Makefile3');
$gv = $parser->plot(
    'all',
);
ok $gv;
isa_ok $gv, 'GraphViz';
$outfile = 't/sum.dot';
ok $gv->as_canon($outfile);
is File::Compare::compare_text($outfile, "t/~sum.dot"), 0;
unlink $outfile if !$debug;

$parser->parse('t/Makefile4');
$gv = $parser->plot(
    'all',
);
ok $gv;
isa_ok $gv, 'GraphViz';
$outfile = 't/bench.dot';
ok $gv->as_canon($outfile);
is File::Compare::compare_text($outfile, "t/~bench.dot"), 0;
unlink $outfile if !$debug;
