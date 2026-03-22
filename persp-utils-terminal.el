;;; persp-utils-terminal.el --- Per-perspective terminal for perspective.el -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Shuto Omura

;; Author: Shuto Omura <somura-vanilla@so-icecream.com>
;; Maintainer: Shuto Omura <somura-vanilla@so-icecream.com>
;; URL: https://github.com/so-vanilla/persp-utils
;; Version: 0.1.0
;; Package-Requires: ((emacs "25.1") (perspective "2.0"))
;; Keywords: convenience, terminals

;; This file is NOT part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; persp-utils-terminal provides a command to switch to or create a terminal
;; buffer within the current perspective.  If an existing terminal buffer
;; is found in the perspective, it is reused; otherwise a new one is created.

;;; Code:

(require 'perspective)

(defcustom persp-utils-terminal-function 'eshell
  "Function to create a new terminal buffer."
  :type 'symbol
  :group 'persp-utils)

(defcustom persp-utils-terminal-mode-alist
  '((eshell . eshell-mode)
    (eat . eat-mode)
    (vterm . vterm-mode)
    (term . term-mode)
    (shell . shell-mode)
    (ansi-term . term-mode))
  "Alist mapping terminal functions to their major modes."
  :type '(alist :key-type symbol :value-type symbol)
  :group 'persp-utils)

(defun persp-utils-terminal ()
  "Switch to or create a terminal in the current perspective.
If an existing terminal buffer matching `persp-utils-terminal-function'
is found in the current perspective, switch to it.
Otherwise, create a new terminal."
  (interactive)
  (let* ((target-mode (alist-get persp-utils-terminal-function
                                 persp-utils-terminal-mode-alist))
         (existing (and target-mode
                        (seq-find (lambda (buf)
                                    (and (buffer-live-p buf)
                                         (with-current-buffer buf
                                           (derived-mode-p target-mode))))
                                  (persp-current-buffers)))))
    (if existing
        (switch-to-buffer existing)
      (funcall persp-utils-terminal-function))))

(provide 'persp-utils-terminal)
;;; persp-utils-terminal.el ends here
