package Dist::Zilla::Plugin::Author::Plicease::Cleaner {

  use 5.020;
  use Moose;
  use Path::Tiny qw( path );
  use Scalar::Util qw( refaddr );
  use Class::Method::Modifiers qw( install_modifier );
  use experimental qw( signatures postderef );

  with 'Dist::Zilla::Role::Plugin';

  # ABSTRACT: Clean things up

=head1 SYNOPSIS

 [Author::Plicease::Cleaner]
 clean = *.o

=cut

  has clean => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
  );

  sub mvp_multivalue_args { qw( clean ) }

  sub BUILD ($self, $) {

    my @clean_list = ('ffi/_build', 't/ffi/_build', '.tmp', '_alien');
    push @clean_list, $self->clean->@*;

    install_modifier 'Dist::Zilla::Dist::Builder', 'after', 'clean' => sub ($bld, $dry) {

      return unless refaddr($self->zilla) == refaddr($bld);

      foreach my $rule (@clean_list)
      {
        if($rule =~ m!/!)
        {
          foreach my $path (glob $rule =~ s!^/!!r)
          {
            next unless -e $path;
            $self->remove_file_or_dir($path, $dry);
          }
        }
        else
        {
          foreach my $path (glob "$rule")
          {
            next unless -e $path;
            $self->remove_file_or_dir($path, $dry);
          }
          Path::Tiny->new('.')->visit(sub {
            my $dir = shift;
            return unless -d $dir;
            foreach my $path (glob "$dir/$rule")
            {
              next unless -e $path;
              $self->remove_file_or_dir($path, $dry);
            }
          }, { recurse => 1 });
        }
      }

    };

    sub remove_file_or_dir ($self, $path, $dry)
    {
      if($dry)
      {
        $self->log("clean: would remove $path");
      }
      else
      {
        $self->log("clean: removing $path");
        if(-d $path)
        {
          Path::Tiny->new($path)->remove_tree;
        }
        elsif(-e $path)
        {
          Path::Tiny->new($path)->remove;
        }
        else
        {
          $self->log("clean: is neither a file nor directory? $path");
        }
      }
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
