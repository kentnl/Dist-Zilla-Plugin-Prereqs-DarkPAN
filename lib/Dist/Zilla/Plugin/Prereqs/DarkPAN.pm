use strict;
use warnings;

package Dist::Zilla::Plugin::Prereqs::DarkPAN;

# ABSTRACT: Depend on things from arbitrary places-not-CPAN

use Moose;

=head1 SYNOPSIS

From time to time, people find themselves in want to depending on something that
isn't from CPAN, but their team/in-house crew want a painless way to depend on
it anyway.

  [Prereqs::DarkPAN]
  DDG = http://some.example.org/path/to/DDG.tar.gz
  ; optional
  DDG.minversion = 0.4.0

This would provide to various user commands the knowledge that DDG.tar.gz was
wanted to provide the package DDG.

Our hope is one day you can just do

  # Doesn't work yet :(
  $ cpanm $( dzil listdeps )

  or

  $ cpanm $( dzil listdeps --missing )

and have it do the right things.

In the interim, you can do

    $ cpanm $( dzil listdeps )  \
      && cpanm $( dzil listdeps_darkpan )

or

    $ cpanm $( dzil listdeps --missing ) \
      && cpanm $( dzil listdeps_darkpan --missing )

and have it work.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;

1;
