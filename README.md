[![Actions Status](https://github.com/raku-community-modules/IO-CatHandle-AutoLines/actions/workflows/test.yml/badge.svg)](https://github.com/raku-community-modules/IO-CatHandle-AutoLines/actions)

NAME
====

IO::CatHandle::AutoLines - Get IO::CatHandle's current handle's line number

SYNOPSIS
========

```raku
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
```

DESCRIPTION
===========

A role that adds an <C.ln> method to the [`IO::CatHandle`](https://docs.raku.org/type/IO::CatHandle) type that will contain the current line number. Optionally, the lines counter can be reset when next source handle get switched into.

**Note:** only the [`.lines`](https://docs.raku.org/type/IO::CatHandle#method_lines) and [`.get`](https://docs.raku.org/type/IO::CatHandle#method_get) methods are overriden to increment the line counter. Using any other methods to read data will **not** increment the line counter.

EXPORTED TYPES
==============

role IO::CatHandle::AutoLines
-----------------------------

Defined as:

```raku
role IO::CatHandle::AutoLines[Bool:D :$reset = True]
```

Provides an `.ln` method containing `Int:D` of the current line number. If `:$reset` parameter is set to `True` (default), then on source handle switch, the line number will be reset back to zero.

```raku
# Reset on-switch enabled
my $cat1 = IO::CatHandle.new(…) does role IO::CatHandle::AutoLines;

# Reset on-switch disabled
my $cat2 = IO::CatHandle.new(…) does role IO::CatHandle::AutoLines[:!reset];
```

AUTHOR
======

Zoffix Znet

COPYRIGHT AND LICENSE
=====================

Copyright 2017 - 2018 Zoffix Znet

Copyright 2019 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

