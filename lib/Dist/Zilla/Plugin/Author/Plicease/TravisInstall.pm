package Dist::Zilla::Plugin::Author::Plicease::TravisInstall;

use 5.014;
use Moose;

# ABSTRACT: Generate travis install script
# VERSION

with 'Dist::Zilla::Role::BeforeBuild';

sub mvp_multivalue_args { qw( repo ) }

has repo => (
  is => 'ro',
  default => sub { ['Perl5-Alien/Alien-Build'] },
);

sub before_build
{
  my($self) = @_;
  my $file = $self->zilla->root->child('maint/travis-install-mods');
  $file->parent->mkpath;
  my $fh = $file->openw;
  
  print $fh "#!/bin/bash -x\n";
  print $fh "\n";
  print $fh "set -euo pipefail\n";
  print $fh "IFS=\$'\\n\\t'\n";
  print $fh "\n";
  
  print $fh "rm -rf";
  foreach my $repo (@{ $self->repo })
  {
    my(undef, $name) = split /\//, $repo;
    print $fh " /tmp/$name";
  }
  print $fh "\n";

  print $fh "\n";
  print $fh "cpanm -n Dist::Zilla\n";
  print $fh "\n";
  
  foreach my $repo (@{ $self->repo })
  {
    my(undef, $name) = split /\//, $repo;
    print $fh "\n";
    print $fh "git clone --depth 2 https://github.com/$repo.git /tmp/$name\n";
    print $fh "cd /tmp/$name\n";
    print $fh "dzil authordeps --missing | cpanm -n\n";
    print $fh "dzil listdeps   --missing | cpanm -n\n";
    print $fh "dzil install --install-command 'cpanm -n .'\n";
  } 
  close $fh; 
  
  $file->chmod('0755');
}

__PACKAGE__->meta->make_immutable;

1;

