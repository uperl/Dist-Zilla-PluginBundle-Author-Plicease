package Dist::Zilla::Plugin::Author::Plicease {

  use strict;
  use warnings;
  use Path::Tiny ();
  use File::ShareDir::Dist ();

  # ABSTRACT: Dist::Zilla plugins used by Plicease

=head1 DESCRIPTION

The modules in this namespace contain some miscellaneous L<Dist::Zilla>
plugins that I use to customize my personal L<Dist::Zilla> experience.
Most likely you don't want or need to use them.  If you do run into
one of my distributions my L<Dist::Zilla> bundle includes documentation 
that may be able to help:

L<Dist::Zilla::PluginBundle::Author::Plicease>

=head1 METHODS

=head2 dist_dir

 my $dir = Dist::Zilla::Plugin::Author::Plicease->dist_dir;

Returns this distributions share directory.

=cut

  sub dist_dir
  {
    my $file = Path::Tiny->new(__FILE__);
    if($file->is_absolute)
    {
      return Path::Tiny->new(
        File::ShareDir::Dist::dist_share('Dist-Zilla-PluginBundle-Author-Plicease')
      );
    }
    else
    {
      my $share = $file
        ->absolute
        ->parent
        ->parent
        ->parent
        ->parent
        ->parent
        ->parent
        ->child('share');
      die "no share $share" unless -d $share;
      return $share;
    }
  }
}

1;
