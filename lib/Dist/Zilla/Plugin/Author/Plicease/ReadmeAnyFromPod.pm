package Dist::Zilla::Plugin::Author::Plicease::ReadmeAnyFromPod {

  use 5.014;
  use Moose;
  use URI::Escape ();

=head1 SYNOPSIS

 [Author::Plicease::ReadmeAnyFromPod]

=cut

  extends 'Dist::Zilla::Plugin::ReadmeAnyFromPod';

  has travis_status => (
    is => 'ro',
  );

  has travis_user => (
    is      => 'ro',
    default => 'plicease',
  );

  has cirrus_user => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
      my($self) = @_;
      $self->travis_user;
    },
  );

  has appveyor_user => (
    is      => 'ro',
    default => 'plicease',
  );

  has appveyor => (
    is  => 'ro',
    isa => 'Str',
  );

  has github_user => (
    is      => 'ro',
    default => 'plicease',
  );

  has workflow => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
  );

  sub mvp_multivalue_args { qw( workflow ) }

  around get_readme_content => sub {
    my $orig = shift;
    my $self = shift;

    my $content = do {
      no warnings 'redefine';
      local *URI::Escape::uri_escape = sub {
        my($uri) = @_;
        $uri;
      };

      $self->$orig(@_);
    };

    return $content unless $self->type eq 'gfm';

    my $status = do {
      my $name = $self->zilla->name;

      my $cirrus_status = -f $self->zilla->root->child('.cirrus.yml');

      my $status = '';
      $status .= " [![Build Status](https://api.cirrus-ci.com/github/@{[ $self->cirrus_user ]}/$name.svg)](https://cirrus-ci.com/github/@{[ $self->cirrus_user ]}/$name)" if $cirrus_status;
      $status .= " [![Build Status](https://secure.travis-ci.org/@{[ $self->travis_user ]}/$name.png)](http://travis-ci.org/@{[ $self->travis_user ]}/$name)" if $self->travis_status;
      $status .= " [![Build status](https://ci.appveyor.com/api/projects/status/@{[ $self->appveyor ]}/branch/master?svg=true)](https://ci.appveyor.com/project/@{[ $self->appveyor_user ]}/$name/branch/master)" if $self->appveyor;

      foreach my $workflow (@{ $self->workflow })
      {
        $status .= " ![$workflow](https://github.com/@{[ $self->github_user ]}/$name/workflows/$workflow/badge.svg)";
      }
      $status;
    };

    $content =~ s{# NAME\s+(.*?) - (.*?#)}{# $1$status\n\n$2}s;
    $content =~ s{# VERSION\s+version (\d+\.|)\d+\.\d+(\\_\d+|)\s+#}{#};
    return $content;
  };

  __PACKAGE__->meta->make_immutable;
}

1;

=head1 SEE ALSO

=over 4

=item L<Dist::Zilla>

=item L<Dist::Zilla::PluginBundle::Author::Plicease>

=back
