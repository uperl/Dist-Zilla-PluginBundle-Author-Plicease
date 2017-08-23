package Dist::Zilla::MintingProfile::Author::Plicease {

  use 5.014;
  use Moose;
  with qw( Dist::Zilla::Role::MintingProfile );
  use namespace::autoclean;
  use File::ShareDir::Dist ();
  use Path::Tiny ();
  use Carp ();

  # ABSTRACT: Minting profile for Plicease

=head1 SYNOPSIS

 dzil new -P Author::Plicease Module::Name

=head1 DESCRIPTION

This is the normal minting profile used by Plicease.

=cut

  sub profile_dir
  {
    my($self, $profile_name) = @_;
  
    # use a dist share instead of a class share
  
    my $profile_dir = Path::Tiny->new( File::ShareDir::Dist::dist_share( 'Dist-Zilla-Plugin-Author-Plicease' ) )
      ->child( "profiles/$profile_name" );
  
    return $profile_dir if -d $profile_dir;
  
    Carp::confess "Can't find profile $profile_name via $self";
  }

  __PACKAGE__->meta->make_immutable;
}

1;

