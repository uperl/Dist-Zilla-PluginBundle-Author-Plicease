use strict;
use warnings;
use Config;
use Test::More tests => 1;

# This .t file is generated.
# make changes instead to dist.ini

my %modules;
my $post_diag;

$modules{$_} = $_ for qw(
  Capture::Tiny
  Dist::Zilla::App
  Dist::Zilla::MintingProfile::Author::Plicease
  Dist::Zilla::Plugin::MakeMaker
  Dist::Zilla::Plugin::UploadToCPAN
  Dist::Zilla::Role::AfterBuild
  Dist::Zilla::Role::BeforeBuild
  Dist::Zilla::Role::BeforeRelease
  Dist::Zilla::Role::FileFinderUser
  Dist::Zilla::Role::FileGatherer
  Dist::Zilla::Role::FileMunger
  Dist::Zilla::Role::InstallTool
  Dist::Zilla::Role::PrereqSource
  Dist::Zilla::Role::TestRunner
  ExtUtils::MakeMaker
  File::Path
  File::ShareDir
  File::ShareDir::Install
  File::Temp
  File::chdir
  Moose
  Path::Class
  Test::DZil
  Test::Dir
  Test::File
  Test::File::ShareDir
  Test::More
  YAML
  YAML::XS
  autodie
  namespace::autoclean
);



my @modules = sort keys %modules;

sub spacer ()
{
  diag '';
  diag '';
  diag '';
}

pass 'okay';

my $max = 1;
$max = $_ > $max ? $_ : $max for map { length $_ } @modules;
our $format = "%-${max}s %s"; 

spacer;

my @keys = sort grep /(MOJO|PERL|\A(LC|HARNESS)_|\A(SHELL|LANG)\Z)/i, keys %ENV;

if(@keys > 0)
{
  diag "$_=$ENV{$_}" for @keys;
  
  if($ENV{PERL5LIB})
  {
    spacer;
    diag "PERL5LIB path";
    diag $_ for split $Config{path_sep}, $ENV{PERL5LIB};
    
  }
  elsif($ENV{PERLLIB})
  {
    spacer;
    diag "PERLLIB path";
    diag $_ for split $Config{path_sep}, $ENV{PERLLIB};
  }
  
  spacer;
}

diag sprintf $format, 'perl ', $];

foreach my $module (@modules)
{
  if(eval qq{ require $module; 1 })
  {
    my $ver = eval qq{ \$$module\::VERSION };
    $ver = 'undef' unless defined $ver;
    diag sprintf $format, $module, $ver;
  }
  else
  {
    diag sprintf $format, $module, '-';
  }
}

if($post_diag)
{
  spacer;
  $post_diag->();
}

spacer;

