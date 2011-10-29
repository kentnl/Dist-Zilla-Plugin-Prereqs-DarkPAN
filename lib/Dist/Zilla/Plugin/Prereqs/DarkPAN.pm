use 5.10.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::Prereqs::DarkPAN;

# ABSTRACT: Depend on things from arbitrary places-not-CPAN

use Moose;
with 'Dist::Zilla::Role::PrereqSource::External';

use namespace::autoclean;

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

has prereq_phase => ( is => 'ro', isa => 'Str', lazy => 1, init_arg => undef, default => 'runtime' );

# init_arg => 'phase',
# default  => sub {
#    my ($self) = @_;
#    my ($phase, $type) = $self->__from_name;
#    $phase ||= 'runtime';
#    $phase = lc $phase;
#    return $phase;
# },

has prereq_type => ( is => 'ro', isa => 'Str', lazy => 1, init_arg => undef, default => 'requires' );

# For full phase control, use above commented code.

has _deps => ( is => 'ro', isa => 'HashRef', default => sub { {} }, );

sub _add_dep {
  my ( $class, $stash, $key, $value ) = @_;
  my $ds = ( $stash->{deps} //= {} );

  # TODO perhaps have support for multiple URLs with either some
  # fallback strategy or round-robbin or random-source support.
  # Not a priority atm.
  return $class->log_fatal( [ 'tried to define source url for %s more than once.', $key ] )
    if exists $ds->{$key};

  return ( $ds->{$key} = $value );

}

sub _add_attribute {
  my ( $class, $stash, $key, $attribute, $value ) = @_;
  my $as = ( $stash->{attributes} //= {} );

  return $class->log_fatal( [ 'Attribute %s not supported.', $attribute ] )
    if $attribute !~ /^(minversion)$/;

  $as->{$key} //= {};

  return $class->log_fatal( [ 'tried to set attribute %s for %s more than once.', $attribute, $key ] )
    if exists $as->{$key}->{$attribute};

  return ( $as->{$key}->{$attribute} = $value );

}

sub _collect_data {
  my ( $class, $stash, $key, $value ) = @_;

  # Parameters
  # -phase
  # -type
  # as supported by Prereqs are not supported here ( at least, not yet )
  return $class->log_fatal('dash ( - ) prefixed parameters are presently not supported.')
    if $key =~ /^-/;

  if ( $key =~ /^([^.]+)\.(.*$)/ ) {

    # Foo::Bar.minversion
    my $key_name      = "$1";
    my $key_attribute = "$2";
    return $class->_add_attribute( $stash, $key_name, $key_attribute, $value );
  }

  return $class->_add_dep( $stash, $key, $value );
}

sub BUILDARGS {
  my ( $class, @args ) = @_;
  my %config;
  if ( ref $args[0] ) {
    %config = %{ $args[0] };
    shift @args;
  }
  else {
    %config = @args;
  }

  my $zilla = delete $config{zilla};
  my $name  = delete $config{plugin_name};
  my $_deps = {};

  my $deps       = {};
  my $attributes = {};

  for my $key ( keys %config ) {
    $class->_collect_data( { deps => $deps, attributes => $attributes, }, $key, $config{$key} );
  }
  for my $dep ( keys %$attributes ) {
    $class->log_fatal( [ 'Attributes specified for dependency %s, which is not defined', $dep ] )
      unless exists $deps->{$dep};
  }
  for my $dep ( keys %$deps ) {
    my $instance = Dist::Zilla::ExternalPrereq->new(
      name        => $dep,
      plugin_name => $name . '{ExternalPrereq: dep on=' . $dep . '}',
      zilla       => $zilla,
      url         => $deps->{$dep},
      %{ $attributes->{$dep} // {} }
    );
    $_deps->{$dep} = $instance;
  }
  return { zilla => $zilla, plugin_name => $name, _deps => $_deps };

}

sub register_external_prereqs {
  my ( $self, $registersub ) = @_;

  for my $dep ( @{ $self->_deps } ) {
    $registersub->(
      {
        type  => $self->prereq_type,
        phase => $self->prereq_phase
      },
      $dep,
    );
  }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
