use lib <lib>;
use Testo;
use Temp::Path;

plan 3;

my @FILES = make-temp-path :content("a\nb\n"    ),
            make-temp-path :content("c\nd\ne\nf"),
            make-temp-path :content("g\nh\ni"   );

is-run $*EXECUTABLE, :args[
    '-Ilib', '-e', ｢
        use LN;
        for lines() {
            .say;
            $*ARGFILES.ln.say;
        }
        $*ARGFILES.ln.say;
        $*LN.say;
        42 does IO::CatHandle::AutoLines;
    ｣, |@FILES
], :out("a\n1\nb\n2\nc\n3\nd\n4\ne\n5\nf\n6\ng\n7\nh\n8\ni\n9\n0\n0\n"),
   'no args on use line';

is-run $*EXECUTABLE, :args[
    '-Ilib', '-e', ｢
        use LN 'reset';
        for lines() {
            .say;
            $*ARGFILES.ln.say;
        }
        $*ARGFILES.ln.say;
        $*LN.say;
        42 does IO::CatHandle::AutoLines;
    ｣, |@FILES
], :out("a\n1\nb\n2\nc\n1\nd\n2\ne\n3\nf\n4\ng\n1\nh\n2\ni\n3\n0\n0\n"),
   'reset on use line';

is-run $*EXECUTABLE, :args[
    '-Ilib', '-e', ｢
        use LN <reset role-only>;
    ｣, |@FILES
], :in("foo\nbar"), :err(/"It doesn't make sense"/), 'both reset and role-only';

is-run $*EXECUTABLE, :args[
    '-Ilib', '-e', ｢
        use LN <role-only>;
        42 does IO::CatHandle::AutoLines;
        say $*LN // 'good';
        say $*ARGFILES.nl
    ｣, |@FILES
], :in("foo\nbar"), :err(/"It doesn't make sense"/), 'both reset and role-only';
