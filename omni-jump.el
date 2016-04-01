;;; omni-jump.el --- Use the right 'jump to source' command for the current mode

;; Copyright (C) 2016 Rich Loveland <r@rmloveland.com>.

;; This file is NOT part of GNU Emacs.

;; This is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2, or (at your option) any later
;; version.

;; This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Emacs; see the file COPYING, or type `C-h C-c'. If not,
;; write to the Free Software Foundation at this address:

;;   Free Software Foundation
;;   51 Franklin Street, Fifth Floor
;;   Boston, MA 02110-1301
;;   USA

;;; Commentary:

;; This package tries to unite the various 'jump to definition'
;; commands you use so they all use the same keybinding, regardless of
;; language or mode.

;; It exports one function, `omni-jump', and requires you to fill in
;; an alist, `*omni-jump-xref-functions*', which will look something
;; like this (here's mine).

;;        (setq *omni-jump-xref-functions*
;;              '((confluence-markup-mode . (confluence-markup-visit-wiki-word-file-at-point))
;;                (c-mode . (xref-find-definitions symbol))
;;                (c-mode . (ggtags-find-tag-dwim symbol))
;;                (c-mode . (semantic-ia-fast-jump point))
;;                (cperl-mode . (cperl-view-module-source))
;;                (scheme-mode . (xref-find-definitions symbol))
;;                (emacs-lisp-mode . (elisp-slime-nav-find-elisp-thing-at-point symbol))
;;                (lisp-interaction-mode . (elisp-slime-nav-find-elisp-thing-at-point symbol))))

;; Since it's an alist, you can override mode settings by just pushing
;; new settings pairs onto it.

;; This mode doesn't bind any keys to `omni-jump'; you can do that
;; yourself.  I like M-RET:

;;        (define-key global-map (kbd "M-RET") #'omni-jump)

;; It uses the built-in marker stack used by Emacs' xref facility so
;; you can jump back using the familiar `M-,' command
;; (`xref-pop-marker-stack').

;; Usage
;; -----

;; For each mode you want this to work with, add a "mode-function"
;; pair like this to the `*omni-jump-xref-functions*' dispatch table
;; (just an alist):

;;     (c-mode . (ggtags-find-tag-dwim symbol))

;; The "symbol" part of the alist value is required since the
;; `ggtags-find-tag-dwim` function takes one argument, the symbol at
;; point.  (This is not ideal; see the TODO section below.)

;; If the mode's jump function doesn't take a symbol argument, then
;; just omit it from the "mode-function" pair, e.g.,

;;     (cperl-mode . (cperl-view-module-source))

;; Once you've populated the dispatch table, just call `omni-jump'
;; interactively wherever you would normally use something like
;; `xref-find-definitions'.

;; Design
;; ------

;; The `omni-jump' function is really dumb.  It just checks a
;; dispatch table to use the jump function you specified for that
;; mode.  If you don't have anything in the dispatch table for the
;; mode, it doesn't try to do anything smart; it just barfs.

;; TODO
;; ----

;; + This should really be rewritten to use the `xref' API and be more
;; magical.  As it stands, it's about 40 lines of code, though, so
;; it's probably fine for now.

;; + The "symbol" argument required by the dispatch table values is
;; kind of ugly.  It should probably be replaced by a `T` or `NIL`
;; value that determines whether the jump function takes the symbol at
;; point as an argument.  Even better, we could require no argument;
;; whether the function needs an argument could just be figured out
;; automagically.

;;; Code:

;; `buffer-mode' is a convenience function taken from:
;; http://stackoverflow.com/questions/2238418/emacs-lisp-how-to-get-buffer-major-mode

(defun buffer-mode (buffer-or-string)
  "Given the buffer BUFFER-OR-STRING, return that buffer's major mode."
  (with-current-buffer buffer-or-string
    major-mode))

(defvar *omni-jump-xref-functions* nil
  "Dispatch table used by `omni-jump' to decide which jump function to use for a given mode.")

(defun omni-jump--get-xref-function (mode)
  "Given the name of a MODE, return the jump function to call."
  (let* ((val (assoc mode *omni-jump-xref-functions*))
	 (definitely (when val (cdr val))))
    (multiple-value-bind (proc arg-type)
	(values (first definitely) (second definitely))
      (values proc arg-type))))

(defun omni-jump ()
  "Call the 'jump to source' function defined for the current mode.
Which function to use is determined by the contents of the
dispatch table `omni-jump--get-xref-mode-function'."
  (interactive)
  (let ((current-symbol (thing-at-point 'symbol t))
	(current-point (point))
	(mode (buffer-mode (current-buffer))))
    (multiple-value-bind (proc arg-type)
	(omni-jump--get-xref-function mode)
      (if (null proc)
	  (error
	   "No handler for `%s' defined in `*omni-jump-xref-functions*'"
	   mode)
	(progn
	  (xref-push-marker-stack)
	  (if arg-type
	      (cond
	       ((equalp arg-type 'symbol)
		(funcall proc current-symbol))
	       ((equalp arg-type 'point)
		(funcall proc current-point)))
	    (funcall proc)))))))

(provide 'omni-jump)

;;; omni-jump.el ends here
