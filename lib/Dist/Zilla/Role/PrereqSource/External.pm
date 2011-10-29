use strict;
use warnings;

package Dist::Zilla::Role::PrereqSource::External;

# FILENAME: External.pm
# CREATED: 30/10/11 10:56:47 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: A plugin that depends on DarkPAN/External sources

use Moose::Role;
with 'Dist::Zilla::Role::Plugin';

use namespace::autoclean;

requires 'register_external_prereqs';

no Moose::Role;
1;

