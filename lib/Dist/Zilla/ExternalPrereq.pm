use 5.006;    # our
use strict;
use warnings;

package Dist::Zilla::ExternalPrereq;

# AUTHORITY

# FILENAME: ExternalPrereq.pm
# CREATED: 30/10/11 10:07:40 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: A representation of an externalised prerequisite

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::ExternalPrereq",
    "interface":"class",
    "inherits":"Moose::Object",
    "does":["Dist::Zilla::Role::Plugin","Dist::Zilla::Role::xPANResolver"]
}

=end MetaPOD::JSON

=cut

use Moose qw( with has );
with 'Dist::Zilla::Role::Plugin', 'Dist::Zilla::Role::xPANResolver';
use Class::Load;
use Try::Tiny qw( try catch );

has 'name'    => ( isa => 'Str', required => 1, is => 'rw' );
has 'baseurl' => ( isa => 'Str', required => 1, is => 'rw' );
has '_uri'    => (
  isa       => 'Str',
  required  => 0,
  is        => 'rw',
  predicate => '_has_uri',
  init_arg  => 'uri',
);
has 'uri' => (
  isa        => 'Str',
  required   => 1,
  is         => 'rw',
  lazy_build => 1,
  init_arg   => undef,
);

has 'minversion' => (
  isa       => 'Str',
  required  => undef,
  is        => 'rw',
  predicate => 'has_minversion',
);

=method is_satisfied

  $dep->is_satisfied

Reports if the dependency looks like its installed.

=cut

sub is_satisfied {
  my ($self) = shift;
  return   unless Class::Load::load_optional_class( $self->name, );
  return 1 unless $self->has_minversion;
  my $satisfied = 1;
  try {
    $self->name->VERSION( $self->minversion );
    1;
  }
  catch {
    ## no critic (RegularExpressions)
    if ( $_ !~ /^.*version.*required.*this is only version.*$/m ) {
      ## no critic ( RequireCarping )
      die $_;
    }
    $satisfied = undef;
  };
  return 1 if $satisfied;
  return;
}

sub _build_uri {
  my ($self) = @_;
  if ( $self->_has_uri ) {
    require URI;
    my $baseuri = URI->new( $self->baseurl );
    return URI->new( $self->_uri )->abs($baseuri)->as_string;
  }
  return $self->resolve_module( $self->baseurl, $self->name );

}
no Moose;
__PACKAGE__->meta->make_immutable;
1;

