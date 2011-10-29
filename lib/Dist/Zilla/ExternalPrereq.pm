use strict;
use warnings;

package Dist::Zilla::ExternalPrereq;
BEGIN {
  $Dist::Zilla::ExternalPrereq::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::ExternalPrereq::VERSION = '0.1.0';
}

# FILENAME: ExternalPrereq.pm
# CREATED: 30/10/11 10:07:40 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: A representation of an externalised prerequisite

use Moose;
with 'Dist::Zilla::Role::Plugin';
use Class::Load;
use Try::Tiny;

has 'name' => ( isa => 'Str', required => 1, is => 'rw' );
has 'url'  => ( isa => 'Str', required => 1, is => 'rw' );
has 'minversion' => (
  isa       => 'Str',
  required  => undef,
  is        => 'rw',
  predicate => 'has_minversion',
);


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

no Moose;
__PACKAGE__->meta->make_immutable;
1;


__END__
=pod

=head1 NAME

Dist::Zilla::ExternalPrereq - A representation of an externalised prerequisite

=head1 VERSION

version 0.1.0

=head1 METHODS

=head2 is_satisfied

  $dep->is_satisfied

Reports if the dependency looks like its installed.

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

