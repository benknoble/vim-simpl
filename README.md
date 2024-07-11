# vim-simpl

(Yet another) REPL/interpreter plugin for vim

[![This project is considered experimental](https://img.shields.io/badge/status-experimental-critical.svg)](https://benknoble.github.io/status/experimental/)

## Goals

vim-simpl aims to be the simplest functional REPL/interpreter plugin for vim.

It prefers customization over sane defaults, and doesn't attempt to work
out-of-the-box for everyone, everywhere. (Many languages have different
REPL/interpreters to choose from; vim-simpl does not attempt to force the
creator's preferences on others.)

It prefers library-style functions and a map-it-yourself attitude, so *you* are
in control of how you interact with your REPL/interpreter. (Prefer commands to
maps? Great!  You're in control, so setup whatever you like!)

It provides (at time of writing) two core features. Namely:

1. the ability to quickly start a filetype-relevant REPL/interpreter, or a shell
   if none exists; and
2. the ability to "load" a file/module into an existing REPL/interpreter
   (creating a new one if one does not yet exist)

(2) differs in terminology and semantics for many languages. Examples would be
the `source` command in bash, the `(load)` function in lisp, and the `use`
function in SML. vim-simpl *does* attempt to provide sane defaults here, because
they are mostly affected by *language* and not by *tool*.

This fits the author's needs, and prevents him from having to write a lot of
extra code to support everyone's favorite mapping or REPL/interpreter.

## Interface

1. Loading a REPL/interpreter

Set `b:interpreter` to a program you would like to run. In most cases, this is a
one-word string such as `'python'` or `'clj'`. It can, however, be a more
complex value, such as the author's odd java variant `'bash -c "make jdb ||
jdb"`.

**Note** that this program is not executed by `'shell'`, so using shell features
requires a level of "wrapping."

With `b:interpreter` set, use the following ex command:

```vim
call simpl#repl()
```

See the docs for more on this function's arguments.

If `b:interpreter` is not set, the default is your shell.

2. Loading a file/module into an existing REPL/interpreter

If the appropriate callbacks have been registered for the filetype, you need to
know about the following functions.

The first loads the current buffer:

```vim
call simpl#load()
```

See the docs for more on this function's arguments.

The second prompts for a buffer to load:

```vim
call simpl#prompt_and_load()
```

If the filetype is not registered, these will be no-ops, making them safe for
global mapping.

As always, see the docs for more information, including how to register new
filetypes.
