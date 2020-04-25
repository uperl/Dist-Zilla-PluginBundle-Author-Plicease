package Dist::Zilla::Plugin::Author::Plicease::ReadmeAnyFromPod {

  use 5.014;
  use Moose;
  use URI::Escape ();

=head1 SYNOPSIS

 [Author::Plicease::ReadmeAnyFromPod]

=cut

  extends 'Dist::Zilla::Plugin::ReadmeAnyFromPod';

  around get_readme_content => sub {
    my $orig = shift;
    my $self = shift;


    local *URI::Escape::uri_escape = sub {
      my($uri) = @_;
      $uri;
    };

    $self->$orig(@_);
  };

  __PACKAGE__->meta->make_immutable;
}

1;

=head1 SEE ALSO

=over 4

=item L<Dist::Zilla>

=item L<Dist::Zilla::PluginBundle::Author::Plicease>

=back
