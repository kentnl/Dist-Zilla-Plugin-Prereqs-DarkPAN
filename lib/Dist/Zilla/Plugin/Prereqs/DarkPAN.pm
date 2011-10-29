use 5.010000;
use strict;
use warnings;

package Dist::Zilla::Plugin::Prereqs::DarkPAN;
BEGIN {
  $Dist::Zilla::Plugin::Prereqs::DarkPAN::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::Plugin::Prereqs::DarkPAN::VERSION = '0.1.0';
}

# ABSTRACT: Depend on things from arbitrary places-not-CPAN

use Moose;
with 'Dist::Zilla::Role::PrereqSource::External';

use namespace::autoclean;


has prereq_phase => (
  is       => 'ro',
  isa      => 'Str',
  lazy     => 1,
  init_arg => undef,
  default  => 'runtime',
);

# init_arg => 'phase',
# default  => sub {
#    my ($self) = @_;
#    my ($phase, $type) = $self->__from_name;
#    $phase ||= 'runtime';
#    $phase = lc $phase;
#    return $phase;
# },

has prereq_type => (
  is       => 'ro',
  isa      => 'Str',
  lazy     => 1,
  init_arg => undef,
  default  => 'requires',
);

# For full phase control, use above commented code.

has _deps => ( is => 'ro', isa => 'HashRef', default => sub { {} }, );

sub _add_dep {
  my ( $class, $stash, $args ) = @_;
  my $ds = ( $stash->{deps} //= {} );
  my $logger = $stash->{logger};

  my $key   = $args->{key};
  my $value = $args->{value};

  # TODO perhaps have support for multiple URLs with either some
  # fallback strategy or round-robbin or random-source support.
  # Not a priority atm.
  return $logger->log_fatal(
    [ 'tried to define source url for \'%s\' more than once.', $key ] )
    if exists $ds->{$key};

  return ( $ds->{$key} = $value );

}

sub _add_attribute {
  my ( $class, $stash, $args ) = @_;

  my $attributes = ( $stash->{attributes} //= {} );
  my $logger = $stash->{logger};

  my $key       = $args->{key};
  my $attribute = $args->{attribute};
  my $value     = $args->{value};

  my $supported_attrs = { map { $_ => 1 } qw( minversion ) };

  return $logger->log_fatal(
    [ 'Attribute \'%s\' for key \'%s\' not supported.', $attribute, $key, ],
  ) if not exists $supported_attrs->{$attribute};

  $attributes->{$key} //= {};

  return $logger->log_fatal(
    [
      'tried to set attribute \'%s\' for %s more than once.', $attribute,
      $key,
    ]
  ) if exists $attributes->{$key}->{$attribute};

  return ( $attributes->{$key}->{$attribute} = $value );

}

sub _collect_data {
  my ( $class, $stash, $key, $value ) = @_;

  my $logger = $stash->{logger};

  # Parameters
  # -phase
  # -type
  # as supported by Prereqs are not supported here ( at least, not yet )
  return $logger->log_fatal(
    'dash ( - ) prefixed parameters are presently not supported.')
    if $key =~ /\A-/msx;

  if ( $key =~ /\A([^.]+)[.](.*\z)/msx ) {

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

  my $zilla_logger = $zilla->chrome->logger;
  my $logger = $zilla_logger->proxy( { proxy_prefix => '[' . $name . ']', } );

  my $deps       = {};
  my $attributes = {};

  for my $key ( keys %config ) {
    $class->_collect_data(
      { logger => $logger, deps => $deps, attributes => $attributes, },
      $key, $config{$key} );
  }
  for my $dep ( keys %{$attributes} ) {
    $logger->log_fatal(
      [
        '[%s] Attributes specified for dependency \'%s\', which is not defined',
        $name,
        $dep
      ]
    ) unless exists $deps->{$dep};
  }
  for my $dep ( keys %{$deps} ) {
    require Dist::Zilla::ExternalPrereq;
    my $instance = Dist::Zilla::ExternalPrereq->new(
      name        => $dep,
      plugin_name => $name . '{ExternalPrereq: dep on=\'' . $dep . '\'}',
      zilla       => $zilla,
      url         => $deps->{$dep},
      %{ $attributes->{$dep} // {} }
    );
    $_deps->{$dep} = $instance;
  }
  return {
    zilla       => $zilla,
    plugin_name => $name,
    _deps       => $_deps,
    logger      => $logger
  };

}


sub register_external_prereqs {
  my ( $self, $registersub ) = @_;

  for my $dep ( keys %{ $self->_deps } ) {
    $registersub->(
      {
        type  => $self->prereq_type,
        phase => $self->prereq_phase
      },
      $self->_deps->{$dep},
    );
  }
  return;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__
=pod

=head1 NAME

Dist::Zilla::Plugin::Prereqs::DarkPAN - Depend on things from arbitrary places-not-CPAN

=head1 VERSION

version 0.1.0

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

=for Pod::Coverage   register_external_prereqs

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

