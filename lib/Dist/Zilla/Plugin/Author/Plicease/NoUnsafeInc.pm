package Dist::Zilla::Plugin::Author::Plicease::NoUnsafeInc {

  use 5.014;
  use Moose;

  # ABSTRACT: Set x_use_unsafe_inc = 0

=head1 SYNOPSIS

 [Author::Plicease::NoUnsafeInc]

=head1 DESCRIPTION

Use C<[UseUnsafeInc]> with dot_in_INC set to 0 instead.

=cut

  # Similar to [UseUnsafeInc], except, we don't require a recent Perl
  # for releases without a environment variable.  Risky!  By not at
  # least not annoying.  We also don't provide an interface to setting
  # to 1.  Code should instead be fixed.

  with 'Dist::Zilla::Role::MetaProvider',
       'Dist::Zilla::Role::AfterBuild';

  sub metadata
  {
    my($self) = @_;
    return { x_use_unsafe_inc => 0 };
  }
  
  sub after_build
  {
    my($self) = @_;
    $ENV{PERL_USE_UNSAFE_INC} = 0;
  }

};

1;
