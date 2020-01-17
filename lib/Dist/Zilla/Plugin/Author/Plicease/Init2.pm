package Dist::Zilla::Plugin::Author::Plicease::Init2 {

  use 5.014;
  use Moose;
  use Dist::Zilla::File::InMemory;
  use Dist::Zilla::File::FromCode;
  use Sub::Exporter::ForMethods qw( method_installer );
  use Data::Section { installer => method_installer }, -setup;
  use Dist::Zilla::MintingProfile::Author::Plicease;
  use JSON::PP qw( encode_json );
  use Encode qw( encode_utf8 );

  # ABSTRACT: Dist::Zilla initialization tasks for Plicease

=head1 DESCRIPTION

Create a dist in plicease style.

=cut

  with 'Dist::Zilla::Role::AfterMint';
  with 'Dist::Zilla::Role::ModuleMaker';
  with 'Dist::Zilla::Role::FileGatherer';

  our $chrome;

  sub chrome
  {
    return $chrome if defined $chrome;
    shift->zilla->chrome;
  }

  has abstract => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
      my($self) = @_;
      $self->chrome->prompt_str("abstract");
    },
  );

  has include_tests => (
    is      => 'ro',
    isa     => 'Int',
    lazy    => 1,
    default => sub {
      1,
    },
  );

  has type_dzil => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
      my $name = shift->zilla->name;
      $name =~ /^Dist-Zilla/ ? 1 : 0;
    },
  );

  has type_alien => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
      my $name = shift->zilla->name;
      $name =~ /^Alien-[A-Za-z0-9]+$/ ? 1 : 0;
    },
  );

  has perl_version => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
      my($self) = @_;
      if(defined $ENV{V} && $ENV{V} =~ /^5\.([0-9]+)$/)
      {
        return sprintf '5.%03d', $1;
      }
      elsif(defined $ENV{V} && $ENV{V} =~ /^5\.([0-9]+)\.([0-9]+)$/)
      {
        return sprintf '5.%03d%03d', $1, $2;
      }
      else
      {
        if($self->type_dzil)
        {
          return '5.014';
        }
        else
        {
          return '5.008001';
        }
      }
    },
  );

  sub make_module
  {
    my($self, $arg) = @_;
    (my $filename = $arg->{name}) =~ s{::}{/}g;

    my $name = $arg->{name};
    my $content;

    if($self->type_dzil)
    {
      $content = join("\n", qq{use strict;} ,
                            qq{use warnings;} ,
                            qq{use @{[ $self->perl_version ]};} ,
                            qq{},
                            qq(package $name {),
                            qq{} ,
                            qq{  use Moose;},
                            qq{  use namespace::autoclean;},
                            qq{},
                            qq{  # ABSTRACT: @{[ $self->abstract ]}} ,
                            qq{} ,
                            qq{  __PACKAGE__->meta->make_immutable;},
                            qq(}),
                            qq{},
                            qq{1;},
      );
    }
    elsif($self->type_alien)
    {
      $content = join("\n", qq{package $name;} ,
                            qq{} ,
                            qq{use strict;} ,
                            qq{use warnings;} ,
                            qq{use @{[ $self->perl_version ]};} ,
                            qq{use base qw( Alien::Base );},
                            qq{} ,
                            qq{# ABSTRACT: @{[ $self->abstract ]}} ,
                            qq{# VERSION} ,
                            qq{} ,
                            qq{1;},
      );
    }
    elsif($self->perl_version >= 5.020)
    {
      $content = join("\n", qq{use strict;} ,
                            qq{use warnings;} ,
                            qq{use @{[ $self->perl_version ]};} ,
                            qq{use experimental qw( postderef signatures );},
                            qq{},
                            qq(package $name {),
                            qq{} ,
                            qq{  # ABSTRACT: @{[ $self->abstract ]}} ,
                            qq{} ,
                            qq(}),
                            qq{},
                            qq{1;},
      );
    }
    elsif($self->perl_version >= 5.014)
    {
      $content = join("\n", qq{use strict;} ,
                            qq{use warnings;} ,
                            qq{use @{[ $self->perl_version ]};} ,
                            qq{},
                            qq(package $name {),
                            qq{} ,
                            qq{  # ABSTRACT: @{[ $self->abstract ]}} ,
                            qq{} ,
                            qq(}),
                            qq{},
                            qq{1;},
      );
    }
    else
    {
      $content = join("\n", qq{package $name;} ,
                            qq{} ,
                            qq{use strict;} ,
                            qq{use warnings;} ,
                            qq{use @{[ $self->perl_version ]};} ,
                            qq{} ,
                            qq{# ABSTRACT: @{[ $self->abstract ]}} ,
                            qq{# VERSION} ,
                            qq{} ,
                            qq{1;},
      );
    }

    my $file = Dist::Zilla::File::InMemory->new({
      name    => "lib/$filename.pm",
      content => $content,
    });

    $self->add_file($file);
  }

  sub gather_files
  {
    my($self, $arg) = @_;

    $self->gather_file_dist_ini($arg);
    $self->gather_files_tests($arg);
    $self->gather_file_gitignore($arg);

    $self->gather_file_simple('.appveyor.yml');
    $self->gather_file_simple('.gitattributes');
    $self->gather_file_simple('.travis.yml');
    $self->gather_file_simple('alienfile') if $self->type_alien;
    $self->gather_file_simple('author.yml');
    $self->gather_file_simple('Changes');
    $self->gather_file_simple('perlcriticrc');
    $self->gather_file_simple('xt/author/critic.t');
  }

  sub gather_file_simple
  {
    my($self, $filename) = @_;
    my $file = Dist::Zilla::File::InMemory->new({
      name    => $filename,
      content => ${ $self->section_data("dist/$filename") },
    });
    $self->add_file($file);
  }

  sub gather_file_appveyor_yml
  {
    my($self, $arg)  =@_;

    my $file = Dist::Zilla::File::InMemory->new({
      name    => '.appveyor.yml',
      content => join("\n",
      ),
    });

    $self->add_file($file);
  }

  sub gather_file_dist_ini
  {
    my($self, $arg) = @_;

    my $zilla = $self->zilla;

    my $code = sub {
      my $content = '';

      $content .= sprintf "name             = %s\n", $zilla->name;
      $content .= sprintf "author           = Graham Ollis <plicease\@cpan.org>\n";
      $content .= sprintf "license          = Perl_5\n";
      $content .= sprintf "copyright_holder = Graham Ollis\n";
      $content .= sprintf "copyright_year   = %s\n", (localtime)[5]+1900;
      $content .= sprintf "version          = 0.01\n";
      $content .= "\n";

      $content .= "[\@Author::Plicease]\n"
               .  (__PACKAGE__->VERSION ? ":version       = @{[ __PACKAGE__->VERSION ]}\n" : '')
               .  "travis_status  = 1\n"
               .  "release_tests  = @{[ $self->include_tests ]}\n"
               .  "installer      = Author::Plicease::MakeMaker\n"
               .  "github_user    = @{[ $self->github_user ]}\n"
               .  "test2_v0       = 1\n";

      $content .= "version_plugin = PkgVersion::Block\n" if $self->perl_version >= 5.014;

      $content .= "\n";

      $content .= "[Author::Plicease::Core]\n";

      $content .= "[Author::Plicease::Upload]\n"
               .  "cpan = 0\n"
               .  "\n";

      $content;
    };

    my $file = Dist::Zilla::File::FromCode->new({
      name => 'dist.ini',
      code => $code,
    });

    $self->add_file($file);
  }

  sub gather_files_tests
  {
    my($self, $arg) = @_;

    my $name = $self->zilla->name;
    $name =~ s{-}{::}g;

    my $test_name = lc $name;
    $test_name =~ s{::}{_}g;
    $test_name = "t/$test_name.t";

    my $main_test = Dist::Zilla::File::InMemory->new({
      name => $test_name,
      content => join("\n", q{use Test2::V0 -no_srand => 1;},
                            q{use } . $name . q{;},
                            q{},
                            q{ok 1, 'todo';},
                            q{},
                            q{done_testing},
      ),
    });

    $self->add_file($main_test);
  }

  sub gather_file_gitignore
  {
    my($self, $arg) = @_;

    my $name = $self->zilla->name;

    my $file = Dist::Zilla::File::InMemory->new({
      name    => '.gitignore',
      content => "/$name-*\n/.build\n",
    });

    $self->add_file($file);
  }

  has github => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
      my($self) = @_;
      $self->chrome->prompt_yn("create github repo", { default => 1 });
    },
  );

  has github_login => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
      my($self) = @_;
      $self->chrome->prompt_str("github login", { default => 'plicease' });
    },
  );

  has github_user => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
      my($self) = @_;
      $self->chrome->prompt_str("github user/org", { default => 'plicease' });
    },
  );

  has github_private => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
      my($self) = @_;
      $self->chrome->prompt_yn("github private", { default => 0 });
    },
  );

  has github_pass => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
      my($self) = @_;
      $self->chrome->prompt_str("github pass", { noecho => 1 });
    },
  );

  has github_auth_token => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
      $ENV{DIST_ZILLA_PLUGIN_AUTHOR_PLICEASE_INIT2_GITHUB_OAUTH_TOKEN} // $ENV{GITHUB_OAUTH_TOKEN};
    },
  );

  sub after_mint
  {
    my($self, $opts) = @_;

    unless(eval { require Git::Wrapper })
    {
      $self->zilla->log("no Git::Wrapper, can't create repository");
      return;
    }

    my $git = Git::Wrapper->new($opts->{mint_root});
    $git->init;
    $git->commit({ 'allow-empty' => 1, message => "Start with a blank" });
    $git->add($opts->{mint_root});
    $git->commit({ message => "Initial structure" });

    unless(eval { require LWP::UserAgent; require HTTP::Request })
    {
      $self->zilla->log("no LWP, can't create github repo");
    }

    my $no_github = 1;

    if($self->github && !$ENV{DIST_ZILLA_PLUGIN_AUTHOR_PLICEASE_INIT2_NO_GITHUB})
    {
      my $ua = LWP::UserAgent->new;
      my $org = $self->github_user ne $self->github_login
        ? $self->github_user
        : undef;
      my $url = $org ? "https://api.github.com/orgs/$org/repos" : 'https://api.github.com/user/repos';
      my $request = HTTP::Request->new(
        POST => $url,
      );

      my $data = encode_json({
        name               => $self->zilla->name,
        description        => $self->abstract,
        private            => (!$org && $self->github_private) ? JSON::PP::true : JSON::PP::false,
        has_projects       => JSON::PP::false,
        has_wiki           => JSON::PP::false,
        allow_squash_merge => JSON::PP::false,
      });
      $request->content($data);
      $request->header( 'Content-Length' => length encode_utf8 $data );
      if($self->github_auth_token)
      {
        $request->header( 'Authorization' => "token @{[ $self->github_auth_token ]}" );
      }
      else
      {
        $request->authorization_basic($self->github_login, $self->github_pass);
      }
      my $response = $ua->request($request);
      if($response->is_success)
      {
        $self->zilla->log("created repo at https://github.com/@{[ $self->github_user ]}/@{[ $self->zilla->name ]}");
        $no_github = 0;
      }
      else
      {
        $self->zilla->log("$url");
        $self->zilla->log("$data");
        $self->zilla->log("@{[ $response->code ]} @{[ $response->status_line ]}");
        $self->zilla->log("could not create a github repo!");
      }
    }

    $git->remote('add', 'origin', "git\@github.com:" . $self->github_user . '/' . $self->zilla->name . '.git');
    $git->push('origin', 'master') unless $no_github;

    return;
  }

  __PACKAGE__->meta->make_immutable;
}

1;

package Dist::Zilla::Plugin::Author::Plicease::Init2;

__DATA__


__[ dist/alienfile ]__
use alienfile;
plugin 'PkgConfig' => 'libfoo';
share {
  plugin Download => (
    url => 'http://...',
    filter => qr/*\.tar\.gz$/,
    version => qr/([0-9\.]+)/,
  );
  plugin Extract => 'tar.gz';
  plugin 'Build::Autoconf';
};


__[ dist/author.yml ]__
---
pod_spelling_system:
  skip: 0
  # list of words that are spelled correctly
  # (regardless of what spell check thinks)
  # or stuff that I like to spell incorrectly
  # intentionally
  stopwords: []

pod_coverage:
  skip: 0
  # format is "Class#method" or "Class",regex allowed
  # for either Class or method.
  private: []


__[ dist/.travis.yml ]__
language: minimal
dist: xenial
services:
  - docker
before_install:
  - curl https://raw.githubusercontent.com/plicease/cip/master/bin/travis-bootstrap | bash
  - cip before-install
install:
  - cip diag
  - cip install
script:
  - cip script
jobs:
  include:
    - env: CIP_TAG=5.31
    - env: CIP_TAG=5.30
    - env: CIP_TAG=5.28
    - env: CIP_TAG=5.26
    - env: CIP_TAG=5.24
    - env: CIP_TAG=5.22
    - env: CIP_TAG=5.20
    - env: CIP_TAG=5.18
    - env: CIP_TAG=5.16
    - env: CIP_TAG=5.14
    - env: CIP_TAG=5.12
    - env: CIP_TAG=5.10
    - env: CIP_TAG=5.8
cache:
  directories:
    - "$HOME/.cip"


__[ dist/.appveyor.yml ]__
---

install:
  - choco install strawberryperl
  - SET PATH=C:\Perl5\bin;C:\strawberry\c\bin;C:\strawberry\perl\site\bin;C:\strawberry\perl\bin;%PATH%
  - perl -v
  - if not exist C:\\Perl5 mkdir C:\\Perl5
  - SET PERL5LIB=C:/Perl5/lib/perl5
  - SET PERL_LOCAL_LIB_ROOT=C:/Perl5
  - SET PERL_MB_OPT=--install_base C:/Perl5
  - SET PERL_MM_OPT=INSTALL_BASE=C:/Perl5
  - cpanm -n Dist::Zilla
  - dzil authordeps --missing | cpanm -n
  - dzil listdeps --missing | cpanm -n

build: off

test_script:
  - dzil test -v

cache:
  - C:\\Perl5

shallow_clone: true


__[ dist/perlcriticrc ]__
severity = 1
only = 1

[Freenode::ArrayAssignAref]
[Freenode::BarewordFilehandles]
[Freenode::ConditionalDeclarations]
[Freenode::ConditionalImplicitReturn]
[Freenode::DeprecatedFeatures]
[Freenode::DiscouragedModules]
[Freenode::DollarAB]
[Freenode::Each]
[Freenode::EmptyReturn]
[Freenode::IndirectObjectNotation]
[Freenode::LexicalForeachIterator]
[Freenode::LoopOnHash]
[Freenode::ModPerl]
[Freenode::OpenArgs]
[Freenode::OverloadOptions]
[Freenode::POSIXImports]
[Freenode::PackageMatchesFilename]
[Freenode::PreferredAlternatives]
[Freenode::StrictWarnings]
extra_importers = Test2::V0
[Freenode::Threads]
[Freenode::Wantarray]
[Freenode::WarningsSwitch]
[Freenode::WhileDiamondDefaultAssignment]

[BuiltinFunctions::ProhibitBooleanGrep]
[BuiltinFunctions::ProhibitStringyEval]
[BuiltinFunctions::ProhibitStringySplit]
[BuiltinFunctions::ProhibitVoidGrep]
[BuiltinFunctions::ProhibitVoidMap]
[ClassHierarchies::ProhibitExplicitISA]
[ClassHierarchies::ProhibitOneArgBless]
[CodeLayout::ProhibitHardTabs]
allow_leading_tabs = 0
[CodeLayout::ProhibitTrailingWhitespace]
[CodeLayout::RequireConsistentNewlines]
[ControlStructures::ProhibitLabelsWithSpecialBlockNames]
[ControlStructures::ProhibitMutatingListFunctions]
[ControlStructures::ProhibitUnreachableCode]
[InputOutput::ProhibitBarewordFileHandles]
[InputOutput::ProhibitJoinedReadline]
[InputOutput::ProhibitTwoArgOpen]
[Miscellanea::ProhibitFormats]
[Miscellanea::ProhibitUselessNoCritic]
[Modules::ProhibitConditionalUseStatements]
;[Modules::RequireEndWithOne]
[Modules::RequireNoMatchVarsWithUseEnglish]
[Objects::ProhibitIndirectSyntax]
[RegularExpressions::ProhibitUselessTopic]
[Subroutines::ProhibitNestedSubs]
[ValuesAndExpressions::ProhibitLeadingZeros]
[ValuesAndExpressions::ProhibitMixedBooleanOperators]
[ValuesAndExpressions::ProhibitSpecialLiteralHeredocTerminator]
[ValuesAndExpressions::RequireUpperCaseHeredocTerminator]
[Variables::ProhibitPerl4PackageNames]
[Variables::ProhibitUnusedVariables]


__[ dist/xt/author/critic.t ]__
use Test2::Require::Module 'Test2::Tools::PerlCritic';
use Test2::Require::Module 'Perl::Critic';
use Test2::Require::Module 'Perl::Critic::Freenode';
use Test2::V0;
use Perl::Critic;
use Test2::Tools::PerlCritic;

my $critic = Perl::Critic->new(
  -profile => 'perlcriticrc',
);

perl_critic_ok ['lib','t'], $critic;

done_testing;


__[ dist/.gitattributes ]__
*.pm linguist-language=Perl
*.t linguist-language=Perl
*.h linguist-language=C


__[ dist/Changes ]__
Revision history for {{$dist->name}}},

{{$NEXT}}
  - initial version


