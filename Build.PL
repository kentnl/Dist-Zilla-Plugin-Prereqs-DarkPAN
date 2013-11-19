
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.4201"
  },
  "configure_requires" => {
    "Module::Build" => "0.4201"
  },
  "dist_abstract" => "Depend on things from arbitrary places-not-CPAN",
  "dist_author" => [
    "Kent Fredric <kentnl\@cpan.org>"
  ],
  "dist_name" => "Dist-Zilla-Plugin-Prereqs-DarkPAN",
  "dist_version" => "0.2.3",
  "license" => "perl",
  "module_name" => "Dist::Zilla::Plugin::Prereqs::DarkPAN",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "App::Cache" => 0,
    "Class::Load" => 0,
    "Dist::Zilla::App" => 0,
    "Dist::Zilla::Role::Plugin" => 0,
    "Moose" => 0,
    "Moose::Autobox" => 0,
    "Moose::Role" => 0,
    "Parse::CPAN::Packages" => 0,
    "Try::Tiny" => 0,
    "URI" => 0,
    "namespace::autoclean" => 0,
    "perl" => "v5.10.0",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "test_requires" => {
    "Test::More" => "1.001002"
  }
);


my %fallback_build_requires = (
  "Module::Build" => "0.4201",
  "Test::More" => "1.001002"
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  delete $module_build_args{test_requires};
  $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
