use strict;
use warnings;
use Test::More tests => 8;

use_ok 'Dist::Zilla::Plugin::Author::Plicease';
use_ok 'Dist::Zilla::Plugin::Author::Plicease::MakeMaker';
use_ok 'Dist::Zilla::Plugin::Author::Plicease::Tests';
use_ok 'Dist::Zilla::Plugin::Author::Plicease::MarkDownCleanup';
use_ok 'Dist::Zilla::Plugin::Author::Plicease::DevShare';
use_ok 'Dist::Zilla::Plugin::Author::Plicease::SpecialPrereqs';
use_ok 'Dist::Zilla::Plugin::Author::Plicease::Upload';
use_ok 'Dist::Zilla::Plugin::Author::Plicease::Thanks';
