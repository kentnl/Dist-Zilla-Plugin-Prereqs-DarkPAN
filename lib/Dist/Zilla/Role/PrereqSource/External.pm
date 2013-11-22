use strict;
use warnings;

package Dist::Zilla::Role::PrereqSource::External;
BEGIN {
  $Dist::Zilla::Role::PrereqSource::External::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::Role::PrereqSource::External::VERSION = '0.2.4';
}

# FILENAME: External.pm
# CREATED: 30/10/11 10:56:47 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: A plugin that depends on DarkPAN/External sources

use Moose::Role;
with 'Dist::Zilla::Role::Plugin';


use namespace::autoclean;

requires 'register_external_prereqs';

no Moose::Role;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Role::PrereqSource::External - A plugin that depends on DarkPAN/External sources

=head1 VERSION

version 0.2.4

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::Role::PrereqSource::External",
    "interface":"role",
    "does":"Dist::Zilla::Role::Plugin"
}


=end MetaPOD::JSON

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
