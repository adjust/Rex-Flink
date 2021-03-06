# This file was automatically generated by Dist::Zilla::Plugin::MakeMaker v6.009.
use strict;
use warnings;



use ExtUtils::MakeMaker;

use File::ShareDir::Install;
$File::ShareDir::Install::INCLUDE_DOTFILES = 1;
$File::ShareDir::Install::INCLUDE_DOTDIRS = 1;
install_share dist => "share";


my %WriteMakefileArgs = (
  "ABSTRACT" => "automate Flink tasks with Rex",
  "AUTHOR" => "Ferenc Erki <ferki\@adjust.com>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0,
    "File::ShareDir::Install" => "0.06"
  },
  "DISTNAME" => "Rex-Flink",
  "LICENSE" => "perl",
  "NAME" => "Rex::Flink",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Const::Fast" => 0,
    "File::ShareDir" => 0,
    "Rex" => 0,
    "Rex::CMDB" => 0,
    "Rex::Commands::MD5" => 0,
    "Rex::Commands::Upload" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "v0.5.0",
  "test" => {
    "TESTS" => ""
  }
);


my %FallbackPrereqs = (
  "Carp" => 0,
  "Const::Fast" => 0,
  "File::ShareDir" => 0,
  "Rex" => 0,
  "Rex::CMDB" => 0,
  "Rex::Commands::MD5" => 0,
  "Rex::Commands::Upload" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);

{
package
MY;
use File::ShareDir::Install qw(postamble);
}
