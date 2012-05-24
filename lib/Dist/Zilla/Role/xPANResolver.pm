use 5.010000;
use strict;
use warnings;

package Dist::Zilla::Role::xPANResolver;

# FILENAME: xPANResolver.pm
# CREATED: 30/10/11 14:05:14 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Tools to resolve a package to a URI from a CPAN/DARKPAN mirror.

use Moose::Role;

sub _cache {
  state $c = do {
    require App::Cache;
    ## no critic (ProhibitMagicNumbers)
    App::Cache->new(
      {
        ttl         => 30 * 60,
        application => __PACKAGE__,
      }
    );
  };
  return $c;
}

sub _content_for {
  my ( $self, $url ) = @_;
  return _cache->get_url($url);
}

sub _parse_for {
  my ( $self, $url ) = @_;
  my $cache_url = $url . '#parsed';
  require Parse::CPAN::Packages;
  return _cache->get_code(
    $cache_url,
    sub {
      my $content = $self->_content_for($url);
      return Parse::CPAN::Packages->new($content);
    }
  );
}

sub _resolver_for {
  my ( $self, $baseurl ) = @_;
  require URI;
  my $path    = URI->new('modules/02packages.details.txt.gz');
  my $baseuri = URI->new($baseurl);
  my $absurl  = $path->abs($baseurl)->as_string;
  return $self->_parse_for($absurl);
}

=method resolve_module

  with 'Dist::Zilla::Role::xPANResolver';

  sub foo {
    my $self = @_;
    my $uri = $self->resolve_module(
      'http://some.darkpan.org', 'FizzBuzz::Bazz'
    );
  }

This should resolve the Module to the applicable package, and return the most
recent distribution.

It should then return a fully qualified path to that resource suitable for
passing to C<wget> or C<cpanm>.

=cut

sub resolve_module {
  my ( $self, $baseurl, $module ) = @_;
  my $p = $self->_resolver_for($baseurl)->package($module);
  my $d = $p->distribution();
  require URI;
  my $modroot = URI->new('authors/id/')->abs( URI->new($baseurl) );
  my $modpath = URI->new( $d->prefix )->abs($modroot);
  return $modpath->as_string;
}

no Moose::Role;

1;

