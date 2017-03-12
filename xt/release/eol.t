use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::EOLTests 0.19

use Test::More 0.88;
use Test::EOL;

my @files = (
    'lib/Dist/Zilla/App/Command/listdeps_darkpan.pm',
    'lib/Dist/Zilla/ExternalPrereq.pm',
    'lib/Dist/Zilla/Plugin/Prereqs/DarkPAN.pm',
    'lib/Dist/Zilla/Role/PrereqSource/External.pm',
    'lib/Dist/Zilla/Role/xPANResolver.pm',
    't/00-compile/lib_Dist_Zilla_App_Command_listdeps_darkpan_pm.t',
    't/00-compile/lib_Dist_Zilla_ExternalPrereq_pm.t',
    't/00-compile/lib_Dist_Zilla_Plugin_Prereqs_DarkPAN_pm.t',
    't/00-compile/lib_Dist_Zilla_Role_PrereqSource_External_pm.t',
    't/00-compile/lib_Dist_Zilla_Role_xPANResolver_pm.t',
    't/000-report-versions-tiny.t'
);

eol_unix_ok($_, { trailing_whitespace => 1 }) foreach @files;
done_testing;
