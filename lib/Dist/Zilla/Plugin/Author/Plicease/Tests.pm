package Dist::Zilla::Plugin::Author::Plicease::Tests;

use 5.008001;
use Moose;
use File::chdir;
use File::Path qw( make_path );
use Path::Class qw( dir );
use Sub::Exporter::ForMethods qw( method_installer );
use Data::Section { installer => method_installer }, -setup;
use Dist::Zilla::MintingProfile::Author::Plicease;

# ABSTRACT: add author only release tests to xt/release
# VERSION

=head1 SYNOPSIS

 [Author::Plicease::Tests]
 source = foo/bar/baz ; source of tests
 skip = pod_.*
 diag = +Acme::Override::INET
 diag = +IO::Socket::INET
 diag = +IO::SOCKET::IP
 diag = -EV

=cut

with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::BeforeBuild';
with 'Dist::Zilla::Role::InstallTool';
with 'Dist::Zilla::Role::TestRunner';

sub mvp_multivalue_args { qw( diag diag_preamble ) }

has source => (
  is      =>'ro',
  isa     => 'Str',
);

has skip => (
  is      => 'ro',
  isa     => 'Str',
  default => '',
);

has diag => (
  is      => 'ro',
  default => sub { [] },
);

has diag_preamble => (
  is      => 'ro',
  default => sub { [] },
);

has _diag_content => (
  is      => 'rw',
  isa     => 'Str',
  default => '',
);

sub gather_files
{
  my($self) = @_;
  
  require Dist::Zilla::File::InMemory;
  
  $self->add_file(
    Dist::Zilla::File::InMemory->new(
      name    => $_,
      content => ${ $self->section_data($_) },
    )
  ) for qw( xt/author/strict.t
            xt/author/eol.t
            xt/author/pod.t
            xt/author/no_tabs.t );
}

sub before_build
{
  my($self) = @_;
  
  my $skip = eval 'qr{^' . $self->skip . '$}';
  
  unless(-d dir($self->zilla->root)->subdir(qw( xt release )))
  {
    $self->log("creating " . dir($self->zilla->root)->subdir(qw( xt release )));
    make_path(dir($self->zilla->root)->subdir(qw( xt release ))->stringify);
  }
  
  my $source = defined $self->source
  ? dir($self->zilla->root)->subdir($self->source)
  : Dist::Zilla::MintingProfile::Author::Plicease->profile_dir->subdir(qw( default skel xt release ));

  foreach my $t_file (grep { $_->basename =~ /\.t$/ || $_->basename eq 'release.yml' } $source->children(no_hidden => 1))
  {
    next if $t_file->basename =~ /^(strict|eol|pod|no_tabs)\.t$/;
    next if $t_file->basename =~ $skip;
    my $new  = $t_file->slurp;
    my $file = dir($self->zilla->root)->file(qw( xt release ), $t_file->basename);
    if(-e $file)
    {
      next if $t_file->basename eq 'release.yml';
      my $old  = $file->slurp;
      if($new ne $old)
      {
        $self->log("replacing " . $file->stringify);
        $file->openw->print($t_file->slurp);
      }
    }
    else
    {
      $self->log("creating " . $file->stringify); 
      $file->openw->print($t_file->slurp);
    }
  }
  
  my $diag = dir($self->zilla->root)->file(qw( t 00_diag.t ));
  my $content = $source->parent->parent->file('t', '00_diag.t')->absolute->slurp;
  $content =~ s{## PREAMBLE ##}{join "\n", map { s/^\| //; $_ } @{ $self->diag_preamble }}e;
  $self->_diag_content($content);
}

# not really an installer, but we have to create a list
# of the prereqs / suggested modules after the prereqs
# have been calculated
sub setup_installer
{
  my($self) = @_;
  
  my %list;
  my $prereqs = $self->zilla->prereqs->as_string_hash;
  foreach my $phase (keys %$prereqs)
  {
    next if $phase eq 'develop';
    foreach my $type (keys %{ $prereqs->{$phase} })
    {
      foreach my $module (keys %{ $prereqs->{$phase}->{$type} })
      {
        next if $module =~ /^(perl|strict|warnings|base)$/;
        $list{$module}++;
      }
    }
  }
  
  if($list{'JSON::MaybeXS'})
  {
    $list{'JSON::PP'}++;
    $list{'JSON::XS'}++;
  }
  
  if(my($alien) = grep { $_->isa('Dist::Zilla::Plugin::Alien') } @{ $self->zilla->plugins })
  {
    $list{$_}++ foreach keys %{ $alien->module_build_args->{alien_bin_requires} };
  }
  
  foreach my $lib (@{ $self->diag })
  {
    if($lib =~ /^-(.*)$/)
    {
      delete $list{$1};
    }
    elsif($lib =~ /^\+(.*)$/)
    {
      $list{$1}++;
    }
    else
    {
      $self->log_fatal('diagnostic override must be prefixed with + or -');
    }
  }
  
  my $code = '';
  
  $code = "BEGIN { eval q{ use EV; } }\n" if $list{EV};
  $code .= '$modules{$_} = $_ for qw(' . "\n";
  $code .= join "\n", map { "  $_" } sort keys %list;
  $code .= "\n);\n";
  
  my($file) = grep { $_->name eq 't/00_diag.t' } @{ $self->zilla->files };

  my $content = $self->_diag_content;
  $content =~ s{## GENERATE ##}{$code};

  if($file)
  {
    $file->content($content);
  }
  else
  {
    $file = Dist::Zilla::File::InMemory->new({
      name => 't/00_diag.t',
      content => $content
    });
    $self->add_file($file);
  }

  my $diag = dir($self->zilla->root)->file(qw( t 00_diag.t ));
  $diag->spew($content);
}

sub test
{
  my($self, $target) = @_;
  system 'prove', '-br', 'xt';
  $self->log_fatal('release test failure') unless $? == 0;
}

__PACKAGE__->meta->make_immutable;

1;

=head1 SEE ALSO

=over 4

=item L<Dist::Zilla>

=item L<Dist::Zilla::PluginBundle::Author::Plicease>

=back

=cut

__DATA__

__[ xt/author/strict.t ]__
use strict;
use warnings;
use Test::More;
BEGIN { 
  plan skip_all => 'test requires Test::Strict' 
    unless eval q{ use Test::Strict; 1 };
};
use Test::Strict;
use FindBin;
use File::Spec;

chdir(File::Spec->catdir($FindBin::Bin, File::Spec->updir, File::Spec->updir));

unshift @Test::Strict::MODULES_ENABLING_STRICT, 'Test2::Bundle::SIPS';
note "enabling strict = $_" for @Test::Strict::MODULES_ENABLING_STRICT;

all_perl_files_ok( grep { -e $_ } qw( bin lib t Makefile.PL ));


__[ xt/author/eol.t ]__
use strict;
use warnings;
use Test::More;
BEGIN { 
  plan skip_all => 'test requires Test::EOL' 
    unless eval q{ use Test::EOL; 1 };
};
use Test::EOL;
use FindBin;
use File::Spec;

chdir(File::Spec->catdir($FindBin::Bin, File::Spec->updir, File::Spec->updir));

all_perl_files_ok(grep { -e $_ } qw( bin lib t Makefile.PL ));


__[ xt/author/no_tabs.t ]__
use strict;
use warnings;
use Test::More;
BEGIN { 
  plan skip_all => 'test requires Test::NoTabs' 
    unless eval q{ use Test::NoTabs; 1 };
};
use Test::NoTabs;
use FindBin;
use File::Spec;

chdir(File::Spec->catdir($FindBin::Bin, File::Spec->updir, File::Spec->updir));

all_perl_files_ok( grep { -e $_ } qw( bin lib t Makefile.PL ));


__[ xt/author/pod.t ]__
use strict;
use warnings;
use Test::More;
BEGIN { 
  plan skip_all => 'test requires Test::Pod' 
    unless eval q{ use Test::Pod; 1 };
};
use Test::Pod;
use FindBin;
use File::Spec;

chdir(File::Spec->catdir($FindBin::Bin, File::Spec->updir, File::Spec->updir));

all_pod_files_ok( grep { -e $_ } qw( bin lib ));

