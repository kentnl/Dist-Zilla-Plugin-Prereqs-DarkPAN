use strict;
use warnings;

package Dist::Zilla::ExternalPrereq;

# FILENAME: ExternalPrereq.pm
# CREATED: 30/10/11 10:07:40 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: A representation of an externalised prerequisite

use Moose;
with 'Dist::Zilla::Role::Plugin';
use Class::Load;
use Try::Tiny;

has 'name'       => ( isa => 'Str', required => 1,     is => 'rw' );
has 'url'        => ( isa => 'Str', required => 1,     is => 'rw' );
has 'minversion' => ( isa => 'Str', required => undef, is => 'rw', predicate => 'has_minversion' );

sub is_satisfied {
  my ($self) = shift;
  my $opts = {};
  return   unless Class::Load::load_optional_class( $self->name, );
  return 1 unless $self->has_minversion;
  my $satisfied = 1;
  try {
    $self->name->VERSION( $self->minversion );
    1;
  }
  catch {
    if ( $_ !~ /^.*version.*required.*this is only version.*$/m ) {
      die $_;
    }
    $satisfied = undef;
  };
  return 1 if $satisfied;
  return;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

