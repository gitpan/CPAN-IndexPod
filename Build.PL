use Module::Build;
use strict;

my $build = Module::Build->new(
  create_makefile_pl => 'traditional',
  license     => 'perl',
  module_name => 'CPAN::IndexPod',
  requires    => {
    'Class::Accessor::Chained' => 0,
    'File::Find::Rule' => 0,
    'Plucene::Simple' => 0,
    'Pod::Simple' => 0,
    'Test::More'         => 0,
},
);
$build->create_build_script;
