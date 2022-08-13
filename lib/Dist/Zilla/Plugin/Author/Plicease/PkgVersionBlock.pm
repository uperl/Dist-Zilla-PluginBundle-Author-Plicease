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

  sub munge_files ($self) {
    my $old = $self->zilla->version;
    my $new = $old;
    $new =~ s/_//g;
    $self->log("NEW = $new");
    $self->zilla->version($new);
    $self->log("\$self->zilla->version = @{[ $self->zilla->version ]}");

    local $@ = '';
    eval { $self->SUPER::munge_files };
    my $error = $@;

    $self->zilla->version($old);
    $self->log("\$self->zilla->version = @{[ $self->zilla->version ]}");

    die $error if $error;
  }

}

1;
