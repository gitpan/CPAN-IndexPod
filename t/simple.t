use strict;
use warnings;
use Cwd;
use File::Path;
use Test::More tests => 12;
use_ok("CPAN::IndexPod");

my $unpacked = cwd . "/t/unpacked";
my $plucene = cwd . "/t/plucy";

rmtree($plucene);
ok(!-d $plucene, "No t/plucy at the start");

my $i = CPAN::IndexPod->new;
$i->unpacked($unpacked);
$i->plucene($plucene);
$i->index;

ok(-d $plucene, "t/plucy created");

is_deeply([$i->search("orange")], [], "orange");

is_deeply([$i->search("xml")], [
  'GraphViz/lib/GraphViz/XML.pm',
  'GraphViz/examples/redcarpet.pl',
  'GraphViz/examples/ppmgraph.pl'
], "xml");

is_deeply([$i->search("vampire")], [
  'Acme-Buffy/lib/Acme/Buffy.pm'
], "vampire");

is_deeply([$i->search("encoding")], [
  'Acme-Buffy/lib/Acme/Buffy.pm'
], "encoding");

is_deeply([$i->search("unsightly")], [
  'Acme-Buffy/lib/Acme/Buffy.pm'
], "unsightly");

is_deeply([$i->search("first time")], [
  'Acme-Buffy/lib/Acme/Buffy.pm',
  'GraphViz/examples/redcarpet.pl'
], "first time");

is_deeply([$i->search("xml ximian")], [
  'GraphViz/examples/redcarpet.pl',
  'GraphViz/lib/GraphViz/XML.pm',
  'GraphViz/examples/ppmgraph.pl'
], "xml ximian");

is_deeply([$i->search("xml and ximian")], [
  'GraphViz/examples/redcarpet.pl',
], "xml and ximian");


is_deeply([$i->search("redcarpet.png")], [
  'GraphViz/examples/redcarpet.pl',
], "xml and ximian");
