use IO::CatHandle::AutoLines; # -*- mode:perl6 -*-
use Test;

$*ARGFILES = IO::CatHandle.new( $*ARGFILES );
$*ARGFILES does IO::CatHandle::AutoLines;
eval-lives-ok "$*ARGFILES does IO::CatHandle::AutoLines", "Can recast \$*ARGFILES";


done-testing;
