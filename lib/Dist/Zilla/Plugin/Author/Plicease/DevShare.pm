package Dist::Zilla::Plugin::Author::Plicease::DevShare {

  use 5.014;
  use Moose;
  use Path::Tiny ();
  use namespace::autoclean;

  # ABSTRACT: Plugin to deal with dev/project share directory

  with 'Dist::Zilla::Role::FileGatherer';

  sub gather_files
  {
    my($self) = @_;

    my $filename = $self->zilla->main_module->name;
    $filename =~ s{^(.*)/(.*?)\.pm$}{$1/.$2.devshare};
  
    my $count = $filename;
    $count =~ s/[^\/]//g;
    $count = length $count;
    my $content = ('../' x $count) . 'share';
  
    my $file = Dist::Zilla::File::InMemory->new({
      name    => $filename,
      content => $content,
    });
  
    $self->add_file($file);
    
    $self->log("DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED");
    $self->log("DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED");
    $self->log("DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED");
    $self->log("DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED");
    $self->log("DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED");
    $self->log("DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED");
    $self->log("DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED");
    $self->log("DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED");
    $self->log("Please use File::ShareDir::Dist instead");
  
    Path::Tiny->($filename)->spew($content);
  }

  __PACKAGE__->meta->make_immutable;
}

1;
