use Test::More tests => 8;
use Makefile::GraphViz;
use File::Compare;

my $parser = Makefile::GraphViz->new;
ok $parser;
isa_ok $parser, 'Makefile::GraphViz';
ok $parser->parse('Makefile');
ok $parser->{_file};

# plot the tree rooted at the install target in Makefile:
my $gv = $parser->plot('install');
ok $gv;
isa_ok $gv, 'GraphViz';
my $png = 't/install.png';
ok $gv->as_png($png);
is File::Compare::compare($png, "$png~"), 0;
unlink $png;
