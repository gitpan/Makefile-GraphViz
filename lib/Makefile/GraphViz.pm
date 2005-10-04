#: Makefile/GraphViz.pm
#: Plot the detailed structure of Makefiles
#:   using GraphViz
#: v0.02
#: Copyright (c) 2005 Agent Zhang
#: 2005-09-30 2005-10-04

package Makefile::GraphViz;

use strict;
use warnings;

use GraphViz;
use base 'Makefile::Parser';

our $VERSION = '0.02';

our $IDCounter = 0;

my %VirNodeStyle =
(
    shape => 'box',
    style => 'dotted',
    fillcolor => 'yellow',
);

my %NormalNodeStyle =
(
    shape => 'box',
    style => 'filled',
    fillcolor => 'yellow',
);

my %EdgeStyle =
(
    color => 'red',
);

my %CmdStyle =
(
    shape => 'ellipse',
    style => 'filled',
    fillcolor => 'gray',
);

my %InitArgs = (
    layout => 'dot',
    ratio => 'auto',
    node => \%NormalNodeStyle,
    edge => \%EdgeStyle,
);

our %Nodes;

sub plot {
    my $self = shift;
    my $root_name = shift;
    my %opts = @_;
    #warn "@_\n";

    # process the ``gv'' option:
    my $gv = $opts{gv};

    # process the ``vir_tars'' option:
    my $val = $opts{vir_tars};
    my %vir_tars = %$val if $val and ref $val;

    # process the ``init_args'' option:
    $val = $opts{init_args};
    my %init_args = ($val and ref $val) ? %$val : %InitArgs;

    # process the ``edge_style'' option:
    $val = $opts{edge_style};
    my %edge_style = ($val and ref $val) ? %$val : %EdgeStyle;
    $init_args{edge} = \%edge_style;

    # process the ``normal_node_style'' option:
    $val = $opts{normal_node_style};
    my %normal_node_style = ($val and ref $val) ? %$val : %NormalNodeStyle;
    $init_args{node} = \%normal_node_style;

    # process the ``vir_node_style'' option:
    $val = $opts{vir_node_style};
    my %vir_node_style = ($val and ref $val) ? %$val : %VirNodeStyle;

    # process the ``cmd_style'' option:
    $val = $opts{cmd_style};
    my %cmd_style = ($val and ref $val) ? %$val : %CmdStyle;

    # process the ``trim_mode'' option:
    my $trim_mode = $opts{trim_mode};
    #warn "TRIM MODE: $trim_mode\n";

    my $root = ($root_name and ref $root_name) ? $root_name : ($self->target($root_name));

    if (!$gv) {
        $gv = GraphViz->new(%init_args);
        %Nodes = ();
    }
    #warn $gv;
    if (!$Nodes{$root_name}) {
        my $short_name = trim_path($root_name);
        #$short_name =~ s/\\/\//g;
        #warn $short_name, "\n";
        $gv->add_node($root_name, label => $short_name);
        $Nodes{$root_name} = 1;
    } else {
        return $gv;
    }
    #warn "GraphViz: $gv\n";
    return $gv if !$root;

    my $lower_node;
    my @cmds = $root->commands;
    if (!$trim_mode and @cmds) {
        $lower_node = gen_id();
        my $cmds = join("\n", map { trim_cmd($_); } @cmds);
        $gv->add_node($lower_node, label => $cmds, %cmd_style);
        $gv->add_edge($lower_node => $root_name);
    } else {
        $lower_node = $root_name;
    }

    my @depends = $root->depends;
    foreach (@depends) {
        #warn "$_\n";
        $gv->add_edge($_ => $lower_node);
        $self->plot($_, gv => $gv, @_);
    }
    #warn "END\n";
    #warn "GraphViz: $gv\n";
    return $gv;
}

sub gen_id {
    return ++$IDCounter;
}

sub trim_path {
    my $s = shift;
    $s =~ s/.+(.{5}[\\\/].*)$/...$1/o;
    $s =~ s/\\/\\\\/g;
    return $s;
}

sub trim_cmd {
    my $s = shift;
    $s =~ s/((?:\S+\s*){1,2}).+/$1/o;
    $s =~ s/\\/\\\\/g;
    return $s;
}

1;
__END__

=head1 NAME

Makefile::GraphViz - Plot the Detailed Structure of Makefiles Using GraphViz                        

=head1 SYNOPSIS

  use Makefile::GraphViz;

  $parser = Makefile::GraphViz->new;
  $parser->parse('Makefile');

  # plot the tree rooted at the install target in Makefile:
  $gv = $parser->plot('install');  # A GraphViz object returned.
  $gv->as_png('install.png');

  # plot the tree rooted at the default target in Makefile:
  $gv = $parser->plot;
  $gv->as_png('default.png');

  # plot the forest consists of all the targets in Makefile:
  $gv = $parser->plot_all;
  $gv->as_png('default.png');

  # you can also invoke all the methods inherited from the Makefile::Parser class:
  @targets = $parser->targets;

=head1 DESCRIPTION

This module uses L<Makefile::Parser> to render user's Makefiles via the amazing
L<GraphViz> module. Before I decided to write this thing, there had been already a
CPAN module named L<GraphViz::Makefile> which did the same thing. However, the
pictures generated by L<GraphViz::Makefile> is oversimplified in my opinion, So
a much complex one is still needed.

B<IMPORTANT!>
This stuff is highly experimental and is currently at B<ALPHA> stage, so
production use is strongly discouraged. Anyway, I have the plan to 
improve this stuff unfailingly.

=head1 SAMPLES

Given the following Makefile definition:

    BASE = pat_cover
    EXE = $(BASE).ast

    t\$(EXE).asm : bin2asm.pl t\$(EXE).bin
        perl bin2asm.pl t\$(EXE).bin > $@

    t\$(EXE).bin : hex2bin.exe t\$(EXE).hex
        hex2bin.exe t\$(EXE).hex $@

    t\$(EXE).hex : ast2hex.pl $(BASE).ast
        perl ast2hex.pl $(BASE).ast > $@

    $(BASE).ast : pat_cover

    pat_cover :
        perl $(BASE).pl $(RAW_AST) $(GLOB_AST) > $(BASE).ast

    hex2bin.exe : hex2bin.c
        cl /nologo /O2 hex2bin.c

We can get the following PNG output (You won't see the picture unless you
used HTML to render this POD doc):

=begin html

<center>
    <img src="doc.png" alt="Stub Picture for the PNG output"/>
</center>

=end html

=head1 The Makefile::GraphViz Class

This class is a subclass inherited from L<Makefile::Parser>. So all the methods (and
hence all the functionalities) provided by L<Makefile::Parser> are accessable here.
Additionally this class also provides some more methods on its own right.

=head1 METHODS

=over

=item plot($target_name)

This method is essential to the class. Users invoke this method to plot the specified
Makefile target. If the argument is absent, the default target in the Makefile will
be used. It will return a L<GraphViz> object, on which you can later call the
-E<gt>as_png or -E<gt>as_text method to obtain the final graphical output.

The argument can both be the target's name and a Makefile::Target object. If the
given target can't be found in Makefile, the target will be plotted separately.

=back

=head2 EXPORT

None by default.

=head2 INTERNAL FUNCTIONS

Internal functions should not be used directly.

=over

=item gen_id

Generate a unique id for command node.

=item trim_path

Trim the path to a more readable form.

=item trim_cmd

Trim the shell command to a more friendly size.

=back

=head1 CODE COVERAGE

I use L<Devel::Cover> to test the code coverage of my tests, below is the 
L<Devel::Cover> report on this module test suite.

    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    File                           stmt   bran   cond    sub    pod   time  total
    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    .../lib/Makefile/GraphViz.pm  100.0   68.2   41.7  100.0  100.0  100.0   82.8
    Total                         100.0   68.2   41.7  100.0  100.0  100.0   82.8
    ---------------------------- ------ ------ ------ ------ ------ ------ ------

=head1 SEE ALSO

L<Makefile::Parser>, L<GraphViz::Makefile>.

=head1 AUTHOR

Agent Zhang, E<lt>agent2002@126.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 Agent Zhang.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
