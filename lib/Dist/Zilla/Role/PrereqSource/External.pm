use 5.006;    # our
use strict;
use warnings;

package Dist::Zilla::Role::PrereqSource::External;

our $VERSION = 'v0.3.0';

# AUTHORITY

# FILENAME: External.pm
# CREATED: 30/10/11 10:56:47 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: A plugin that depends on DarkPAN/External sources

use Moose::Role qw( with requires around );
with 'Dist::Zilla::Role::Plugin';

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::Role::PrereqSource::External",
    "interface":"role",
    "does":"Dist::Zilla::Role::Plugin"
}

=end MetaPOD::JSON

=cut

use namespace::autoclean;

requires 'register_external_prereqs';

around dump_config => sub {
  my ( $orig, $self, @args ) = @_;
  my $config = $self->$orig(@args);
  $config->{ +__PACKAGE__ }->{ q[$] . __PACKAGE__ . q[::VERSION] } = $VERSION;
  return $config;
};

no Moose::Role;
1;

