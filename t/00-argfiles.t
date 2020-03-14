use IO::CatHandle::AutoLines; # -*- mode:perl6 -*-
use Test;

eval-lives-ok '$*ARGFILES does IO::CatHandle::AutoLines', "Can recast \$*ARGFILES";

is $*ARGFILES.ln, 0, "Initialized line counter";

done-testing;
