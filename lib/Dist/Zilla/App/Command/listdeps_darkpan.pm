use 5.010000;
use strict;
use warnings;

package Dist::Zilla::App::Command::listdeps_darkpan;

# FILENAME: listdeps_darkpan.pm
# CREATED: 30/10/11 11:07:09 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: List DarkPAN dependencies

use Dist::Zilla::App -command;
use Moose::Autobox;

=head1 SYNOPSIS

This code is mostly borged from the C<listdeps> command as a temporary measure till upstream
add native support.

=cut

sub abstract { return 'list your distributions prerequisites from darkpans' }

sub opt_spec {
  return [ 'missing', 'list only the missing dependencies' ],;
}

sub _extract_dependencies {
  my ( $self, $zilla, $missing ) = @_;
  $_->before_build     for $zilla->plugins_with( -BeforeBuild )->flatten;
  $_->gather_files     for $zilla->plugins_with( -FileGatherer )->flatten;
  $_->prune_files      for $zilla->plugins_with( -FilePruner )->flatten;
  $_->munge_files      for $zilla->plugins_with( -FileMunger )->flatten;
  $_->register_prereqs for $zilla->plugins_with( -PrereqSource )->flatten;
  my @dark;
  my $callback = sub {
    shift @_ if ref $_[0] eq 'HASH';
    push @dark, @_;
  };

  $_->register_external_prereqs($callback)
    for $zilla->plugins_with('-PrereqSource::External')->flatten;

  if ($missing) {
    @dark = grep { not $_->is_satisfied } @dark;
  }
  @dark = sort { lc $a->url cmp lc $b->url } @dark;
  return @dark;
}

sub execute {
  my ( $self, $opt, $arg ) = @_;
  my $logger = $self->app->chrome->logger;
  $logger->mute;
  for ( $self->_extract_dependencies( $self->zilla, $opt->missing, ) ) {
    say $_->uri or do {
      $logger->unmute;
      $logger->log_fatal('Error writing to output');
    };
  }
  return 1;
}
1;

