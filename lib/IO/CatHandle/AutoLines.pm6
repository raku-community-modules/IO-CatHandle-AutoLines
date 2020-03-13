use MONKEY-GUTS;

role IO::CatHandle::AutoLines[Bool:D :$reset = True, :$LN] {
    has Int:D $.ln is rw = 0;
    has &!os-store;

    submethod TWEAK {
        PROCESS::<$LN> := $!ln if $LN;
        return unless $reset;

        if self ~~ IO::Handle {
            return unless self ~~ IO::CatHandle;
        }
        else {
            die 'The '
              ~ $?ROLE.^name
              ~ ' role can only be mixed into an IO::CatHandle, not a '
              ~ self.^name;
        }

        sub reset { $!ln = 0 }
        with nqp::getattr(self, IO::CatHandle, '&!on-switch') -> $os {
            &!os-store := { reset; $os() }
        }
        else {
            &!os-store := &reset
        }

        nqp::bindattr(self, IO::CatHandle, '&!on-switch', Proxy.new:
          :FETCH{ &!os-store },
          :STORE(-> $, &code {
            &!os-store := do if &code {
              $_ = &code.count;
              when 2|Inf { -> \a, \b { reset; code a, b } }
              when 1     { -> \a     { reset; code a    } }
              when 0     { ->        { reset; code      } }
              die "Don't know how to handle on-switch of count $_."
                        ~ " Does IO::CatHandle even support that?"
            }
            else { { reset } }
          }));
    }
    method get {
        my \v = callsame;
        v === Nil ?? ($!ln = 0) !! ++$!ln;
        v
    }
    method lines {
        Seq.new: my class :: does Iterator {
            has $!handle;
            has $!ln;
            method !SET-SELF(\handle, \ln) {
                $!handle := handle;
                $!ln     := ln;
                self
            }
            method new(\handle, \ln) { self.CREATE!SET-SELF(handle, ln) }
            method pull-one {
                my \v = $!handle.get;
                v =:= Nil ?? IterationEnd !! v
            }
        }.new: self, $!ln
    }
}
