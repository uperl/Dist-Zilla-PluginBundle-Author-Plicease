package Dist::Zilla::Plugin::Author::Plicease {

  use strict;
  use warnings;
  use Path::Tiny ();
  use File::ShareDir::Dist ();

  # ABSTRACT: Dist::Zilla plugins used by Plicease

=head1 DESCRIPTION

This distribution contains some miscellaneous plugins that I use
that should probably not be of any use to anyone else.  Historically
they were used and included by my bundle C<[@Author::Plicease]>, but
I've separated them into their own distribution so they can be
installed without the the full set of prereqs required by the bundle.

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
