role IO::CatHandle::AutoLines[Bool:D :$reset = True, :$LN] {
    has Int:D $.ln is rw = 0;
    has &!os-store;

    submethod TWEAK(--> Nil) {
        PROCESS::<$LN> := $!ln if $LN;
        return unless $reset;

        use nqp;

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
          FETCH => { &!os-store },
          STORE => -> $, &code {
            &!os-store := do if &code {
              $_ = &code.count;
              when 2|Inf { -> \a, \b { reset; code a, b } }
              when 1     { -> \a     { reset; code a    } }
              when 0     { ->        { reset; code      } }
              die "Don't know how to handle on-switch of count $_."
                        ~ " Does IO::CatHandle even support that?"
            }
            else { { reset } }
          }
        );
    }
    method get() {
        my \v = callsame;
        v === Nil ?? ($!ln = 0) !! ++$!ln;
        v
    }

    my class LinesIterator does Iterator {
        has $!handle is built;
        has $!ln     is built;

        method pull-one {
            my \v = $!handle.get;
            v =:= Nil ?? IterationEnd !! v
        }
    }
    method lines() {
        Seq.new: LinesIterator.new: :handle(self), :$!ln
    }
}

=begin pod

=head1 NAME

IO::CatHandle::AutoLines - Get IO::CatHandle's current handle's line number

=head1 SYNOPSIS

=begin code :lang<raku>

use IO::CatHandle::AutoLines;

'some'   .IO.spurt: "a\nb\nc";
'files'  .IO.spurt: "d\ne\nf";
'to-read'.IO.spurt: "g\nh";

my $kitty = IO::CatHandle.new(<some files to-read>, :on-switch{
    say "Meow!"
}) does IO::CatHandle::AutoLines;

say "$kitty.ln(): $_" for $kitty.lines;

# OUTPUT:
# Meow!
# 1: a
# 2: b
# 3: c
# Meow!
# 1: d
# 2: e
# 3: f
# Meow!
# 1: g
# 2: h
# Meow!

=end code

=head1 DESCRIPTION

A role that adds an <C.ln> method to the
L<C<IO::CatHandle>|https://docs.raku.org/type/IO::CatHandle> type that
will contain the current line number. Optionally, the lines counter can
be reset when next source handle get switched into.

B<Note:> only the
L<C<.lines>|https://docs.raku.org/type/IO::CatHandle#method_lines> and
L<C<.get>|https://docs.raku.org/type/IO::CatHandle#method_get> methods
are overriden to increment the line counter. Using any other methods to
read data will B<not> increment the line counter.

=head1 EXPORTED TYPES

=head2 role IO::CatHandle::AutoLines

Defined as:

=begin code :lang<raku>

role IO::CatHandle::AutoLines[Bool:D :$reset = True]

=end code

Provides an C<.ln> method containing C<Int:D> of the current line number.
If C<:$reset> parameter is set to C<True> (default), then on source
handle switch, the line number will be reset back to zero.

=begin code :lang<raku>

# Reset on-switch enabled
my $cat1 = IO::CatHandle.new(…) does role IO::CatHandle::AutoLines;

# Reset on-switch disabled
my $cat2 = IO::CatHandle.new(…) does role IO::CatHandle::AutoLines[:!reset];

=end code

=head1 AUTHOR

Zoffix Znet

=head1 COPYRIGHT AND LICENSE

Copyright 2017 - 2018 Zoffix Znet

Copyright 2019 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
