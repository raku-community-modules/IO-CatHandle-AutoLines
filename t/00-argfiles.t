use IO::CatHandle::AutoLines; # -*- mode:perl6 -*-
use Test;

say $*ARGFILES.perl;
$*ARGFILES does IO::CatHandle::AutoLines;


done-testing;
