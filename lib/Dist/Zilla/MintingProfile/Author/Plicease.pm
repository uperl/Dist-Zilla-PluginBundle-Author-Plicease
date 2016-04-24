package Dist::Zilla::MintingProfile::Author::Plicease;

use 5.008001;
use Moose;
with qw( Dist::Zilla::Role::MintingProfile );
use namespace::autoclean;
use File::ShareDir ();
use Path::Class    qw( dir );
use Carp           qw( confess );

# ABSTRACT: Minting profile for Plicease
# VERSION

=head1 SYNOPSIS

 dzil new -P Author::Plicease Module::Name

=head1 DESCRIPTION

This is the normal minting profile used by Plicease.

=cut

# this is basically the 5.x version of profile_dir from
# Dist::Zilla::Role::MintingProfile::ShareDir.
# for 5.x / 6.x compatability

sub profile_dir
{
  my($self, $profile_name) = @_;
  
  my $profile_dir = dir( File::ShareDir::module_dir( $self->meta->name ) )
    ->subdir( $profile_name );
  
  return $profile_dir if -d $profile_dir;
  
  confess "Can't find profile $profile_name via $self";
}

__PACKAGE__->meta->make_immutable;

1;

