package Dist::Zilla::Plugin::Author::Plicease::SpecialPrereqs {

  use 5.020;
  use Moose;
  use experimental qw( postderef );
  use Dist::Zilla::Plugin::Author::Plicease;
  use Config::INI::Reader;

  # ABSTRACT: Special prereq handling

=head1 SYNOPSIS

 [Author::Plicease::SpecialPrereqs]

=head1 DESCRIPTION

Some older versions of modules have problematic for various
reasons (at least in the context of how I use them).  This
plugin will upgrade those prereqs to appropriate version
if they are C<0>, meaning any version.

Some modules are recommended if certain modules are already
prerequisites.  For example, XS modules may be recommended if
otherwise pure perl modules will optionally use them.

This plugin also enforces that releases are done on MSWin32
for pure-C<Win32::> type modules and on a Unixy platform
if they are not.

This plugin also adds a preface to your C<Makefile.PL> or C<Build.PL> to
test the Perl version in a way that will not throw an exception,
instead calling exit, so that they will not be reported on
cpantesters as failures.  This plugin should be the last
L<Dist::Zilla::Role::InstallTool> plugin in your C<dist.ini>.

=over 4

=item Moo

Require 2.x as this fixes the bug where fatal warnings was
enabled.

=item PerlX::Maybe

Require 0.003

=item AnyEvent::Open3::Simple

Require 0.76 for new stdin style
Require 0.83 for deprecation removals

=item Path::Class

Require 0.26 for spew

=item Mojolicious

Require 4.31

=item Role::Tiny

Require 1.003001.  See rt#83248

=item JSON::XS

Recommended if JSON is required.

=item PerlX::Maybe::XS

Recommended if PerlX::Maybe is required.

=item EV

Recommended if Mojolicious or AnyEvent modules are required.

=item Test::Exit

Require 0.11 for dealing with C<exit> inside and C<eval>.

=back

=head1 OPTIONS

=head2 preamble

...

=head2 upgrade

Upgrade additional prereqs.  This takes a key=value pair, so something like

 [Author::Plicease::SpecialPrereqs]
 upgrade = Foo::Bar = 0.02

=head2 win32

If set to true, then the dist MUST be released on MSWin32.  This is
useful for C<Win32::> type dists that aren't testable on Unixy platforms.

If set to false, then the dist MUST NOT be released on MSWin32.  This
is a personal preference; I prefer not to release on non-Unixy platforms.

=cut

  with 'Dist::Zilla::Role::BeforeRelease';
  with 'Dist::Zilla::Role::PrereqSource';
  with 'Dist::Zilla::Role::InstallTool';

  sub mvp_multivalue_args { qw( upgrade preamble ) }

  has preamble => (
    is      => 'ro',
    default => sub { [] },
  );

  has upgrade => (
    is      => 'ro',
    default => sub { [] },
  );

  has win32 => (
    is      => 'ro',
    default => 0,
  );

  has git => (
    is      => 'ro',
    default => 0,
  );

  sub register_prereqs
  {
    my($self) = @_;

    my $prereqs = $self->zilla->prereqs->as_string_hash;

    my %upgrades = qw(
      Moo                                   2.0
      PerlX::Maybe                          0.003
      AnyEvent::Open3::Simple               0.83
      Path::Class                           0.26
      Mojolicious                           4.31
      Role::Tiny                            1.003001
      Test::More                            0.98
      Test::Exit                            0.11
      Clustericious                         1.20
      Test::Clustericious::Cluster          0.31
      ExtUtils::ParseXS                     3.30
    );

    $upgrades{$_} = '1.302015' for (
        (map { "Test2::$_" } qw( API Event Formatter Formatter::TAP Hub IPC Util )),
        (map { "Test2::API::$_" } qw( Breakage Context Instance Stack )),
        (map { "Test2::Event::$_" } qw( Bail Diag Exception Note Ok Plan Skp Subtest Waiting )),
        (map { "Test2::Hub::$_" } qw( Interceptor Interceptor::Terminator Subtest )),
        (map { "Test2::IPC::$_" } qw( Driver Driver::Files )),
        (map { "Test2::Util::$_" } qw( ExternalMeta HashBase Trace )),
        'Test2',
    );

    $upgrades{$_} = '0.000121' for qw(
        Test2::V0
        Test2::Bundle
        Test2::Bundle::Extended
        Test2::Bundle::More
        Test2::Bundle::Simple
        Test2::Compare
        Test2::Compare::Array
        Test2::Compare::Base
        Test2::Compare::Custom
        Test2::Compare::Delta
        Test2::Compare::Event
        Test2::Compare::EventMeta
        Test2::Compare::Hash
        Test2::Compare::Meta
        Test2::Compare::Number
        Test2::Compare::Object
        Test2::Compare::OrderedSubset
        Test2::Compare::Pattern
        Test2::Compare::Ref
        Test2::Compare::Regex
        Test2::Compare::Scalar
        Test2::Compare::Set
        Test2::Compare::String
        Test2::Compare::Undef
        Test2::Compare::Wildcard
        Test2::Mock
        Test2::Plugin
        Test2::Plugin::BailOnFail
        Test2::Plugin::DieOnFail
        Test2::Plugin::ExitSummary
        Test2::Plugin::SRand
        Test2::Plugin::UTF8
        Test2::Require
        Test2::Require::AuthorTesting
        Test2::Require::EnvVar
        Test2::Require::Fork
        Test2::Require::Module
        Test2::Require::Perl
        Test2::Require::RealFork
        Test2::Require::Threads
        Test2::Suite
        Test2::Todo
        Test2::Tools
        Test2::Tools::Basic
        Test2::Tools::Class
        Test2::Tools::ClassicCompare
        Test2::Tools::Compare
        Test2::Tools::Defer
        Test2::Tools::Encoding
        Test2::Tools::Event
        Test2::Tools::Exception
        Test2::Tools::Exports
        Test2::Tools::Grab
        Test2::Tools::Mock
        Test2::Tools::Ref
        Test2::Tools::Subtest
        Test2::Tools::Target
        Test2::Tools::Warnings
        Test2::Util::Grabber
        Test2::Util::Ref
        Test2::Util::Stash
        Test2::Util::Sub
        Test2::Util::Table
        Test2::Util::Table::LineBreak
    );

    foreach my $upgrade ($self->upgrade->@*)
    {
      if($upgrade =~ /^\s*(\S+)\s*=\s*(\S+)\s*$/)
      {
        $upgrades{$1} = $2;
      }
      else
      {
        $self->log_fatal("upgrade failed: $upgrade");
      }
    }

    foreach my $phase (keys %$prereqs)
    {
      foreach my $type (keys $prereqs->{$phase}->%*)
      {
        foreach my $module (sort keys $prereqs->{$phase}->{$type}->%*)
        {
          my $value = $prereqs->{$phase}->{$type}->{$module};
          next unless $value == 0;
          if($upgrades{$module})
          {
            $self->zilla->register_prereqs({
              type  => $type,
              phase => $phase,
            }, $module => $upgrades{$module} );
          }
        }
      }
    }

    foreach my $phase (keys %$prereqs)
    {
      foreach my $type (keys $prereqs->{$phase}->%*)
      {
        foreach my $module (keys $prereqs->{$phase}->{$type}->%*)
        {
          if($module =~ /^(JSON|PerlX::Maybe)$/)
          {
            $self->zilla->register_prereqs({
              type  => 'recommends',
              phase => $phase,
            }, join('::', $module, 'XS') => 0 );
          }
          if($module eq 'JSON::MaybeXS')
          {
            $self->zilla->register_prereqs({
              type => 'recommends',
              phase => $phase,
            }, "Cpanel::JSON::XS" => 0);
          }
          my($first) = split /::/, $module;
          if($first =~ /^(AnyEvent|Mojo|Mojolicious)$/)
          {
            $self->zilla->register_prereqs({
              type  => 'recommends',
              phase => $phase,
            }, EV => 0);
          }
        }
      }
    }

    if(my($perlcritic_file) = grep { $_->name eq 'perlcriticrc' } $self->zilla->files->@*)
    {
      foreach my $policy (grep { $_ ne '_' } sort keys Config::INI::Reader->read_string($perlcritic_file->content)->%*)
      {
        $self->zilla->register_prereqs({
          type  => 'recommends',
          phase => 'develop',
        }, "Perl::Critic::Policy::$policy" => 0);
      }
    }

  }

  sub before_release
  {
    my $self = shift;

    if($self->win32)
    {
      if($^O ne 'MSWin32')
      {
        $self->log_fatal("This dist must be released on MSWin32");
      }
    }
    else
    {
      if($^O eq 'MSWin32')
      {
        $self->log_fatal("This dist is not releasable on MSWin32");
      }
    }

    unless(Dist::Zilla::Plugin::Author::Plicease->git)
    {
      $self->log_fatal("release requires git and Dist::Zilla::Plugin::Git to be installed");
    }

    $self->log("Okay to release this dist on $^O");
  }

  sub setup_installer
  {
    my($self) = @_;

    my $prereqs = $self->zilla->prereqs->as_string_hash;

    my $perl_version = $prereqs->{runtime}->{requires}->{perl};

    $self->log("perl version required = $perl_version");

    foreach my $file (grep { $_->name =~ /^(Makefile\.PL|Build\.PL)$/ } $self->zilla->files->@*)
    {
      my $content = $file->content;
      $content = join "\n",
        "BEGIN {",
        "  use strict; use warnings;",
        (map { s/^\| /  /r } $self->preamble->@*),
        "  unless(eval q{ use $perl_version; 1}) {",
        "    print \"Perl $perl_version or better required\\n\";",
        "    exit;",
        "  }",
        "}",
        $content;
      $file->content($content);
    }
  }

  __PACKAGE__->meta->make_immutable;
}

1;

=head1 SEE ALSO

=over 4

=item L<Dist::Zilla>

=item L<Dist::Zilla::PluginBundle::Author::Plicease>

=back
