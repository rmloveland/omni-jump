omni-jump.el – Use the right 'jump to source' command for the current mode
==========================================================================

You should be able to use one "jump to source" command (and
keybinding) across all of your various projects, languages, etc.
This package looks at your current buffer's mode and uses the
"jump" function you've specified for that mode to jump to the
source of the thing at point.  It uses the built-in marker stack
used by Emacs' xref facility so you can jump back using the
familiar `M-,` command (`xref-pop-marker-stack`).

Usage
-----

For each mode you want this to work with, add a "mode-function"
pair like this to the `*omni-jump-xref-functions` dispatch table
(just an alist):

    (c-mode . (ggtags-find-tag-dwim symbol))

The "symbol" part of the alist value is required since the
    ggtags-find-tag-dwim
point.  (This is not ideal; see the TODO section below.)

If the mode's jump function doesn't take a symbol argument, then
just omit it from the "mode-function" pair, e.g.,

    (cperl-mode . (cperl-view-module-source))

Once you've populated the dispatch table, just call `omni-jump`
interactively wherever you would normally use something like
    xref-find-definitions

Design
------

The `omni-jump` function is really dumb.  It just checks a
dispatch table to use the jump function you specified for that
mode.  If you don't have anything in the dispatch table for the
mode, it doesn't try to do anything smart; it just barfs.

TODO
----

The "symbol" argument required by the dispatch table values is
ugly.  It should probably be replaced by a `T` or `NIL` value that
determines whether the jump function takes the symbol at point as
an argument.  Even better, no argument should be required; whether
the function needs an argument could be figured out automagically.

Function Documentation
----------------------

### `(buffer-mode BUFFER-OR-STRING)`

Given the buffer BUFFER-OR-STRING, return that buffer's major mode.

### `(omni-jump)`

Call the 'jump to source' function defined for the current mode.
Which function to use is determined by the contents of the
dispatch table ‘omni-jump--get-xref-mode-function’.

-----
<div style="padding-top:15px;color: #d0d0d0;">
Markdown README file generated by
<a href="https://github.com/mgalgs/make-readme-markdown">make-readme-markdown.el</a>
</div>