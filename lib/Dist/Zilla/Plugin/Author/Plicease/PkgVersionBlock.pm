package Dist::Zilla::Plugin::Author::Plicease::PkgVersionBlock {

  use Moose;
  extends 'Dist::Zilla::Plugin::PkgVersion::Block';
  use experimental qw( signatures );

=head1 SYNOPSIS

 [Author::Plicease::PkgVersionBlock]

=head1 DESCRIPTION

This is a subclass of L<Dist::Zilla::Plugin::PkgVersion::Block> that allows underscores
in versions.  You probably shouldn't use this.

=head1 SEE ALSO

L<Dist::Zilla::PluginBundle::Author::Plicease>

=cut

  sub munge_files ($self)
  {
    my $old = $self->zilla->version;
    my $new = $old;
    $new =~ s/_//g;
    $self->zilla->version($new);
    if($new ne $old)
    {
      $self->log("Using $new instead of $old in Perl source for version");
    }

    local $@ = '';
    eval { $self->SUPER::munge_files };
    my $error = $@;

    $self->zilla->version($old);

    die $error if $error;
  }

}

1;
