;;; persp-utils-sidebar.el --- Sidebar for perspective.el -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Shuto Omura

;; Author: Shuto Omura <somura-vanilla@so-icecream.com>
;; Maintainer: Shuto Omura <somura-vanilla@so-icecream.com>
;; URL: https://github.com/so-vanilla/persp-utils
;; Version: 0.1.0
;; Package-Requires: ((emacs "25.1") (perspective "2.0"))
;; Keywords: convenience, frames

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

;; persp-utils-sidebar provides a sidebar window that displays all perspectives
;; registered in perspective.el.  The current perspective is highlighted,
;; and you can switch perspectives by clicking or pressing RET on the name.
;;
;; Features:
;; - Display all perspectives in a side window
;; - Highlight the current perspective
;; - Quick navigation between perspectives
;; - Auto-refresh when perspectives change
;; - Optional auto-show when creating new perspective
;; - Pluggable session status display via `persp-utils-sidebar-session-status-function'
;;
;; Usage:
;;   M-x persp-utils-sidebar-show    - Show the sidebar
;;   M-x persp-utils-sidebar-toggle  - Toggle the sidebar
;;   M-x persp-utils-sidebar-close   - Close the sidebar
;;   M-x persp-utils-sidebar-focus   - Focus on the sidebar
;;
;; Keybindings in the sidebar:
;;   n, j  - Next perspective
;;   p, k  - Previous perspective
;;   RET   - Switch to perspective at point
;;   SPC   - Switch to perspective at point
;;   g     - Refresh sidebar
;;   r     - Reset sidebar width
;;   q     - Close sidebar

;;; Code:

(require 'perspective)

;; Variables
(defvar persp-utils-sidebar-buffer-name "*Persp Utils Sidebar*"
  "Name of the perspective sidebar buffer.")

(defvar persp-utils-sidebar-window nil
  "Window displaying the perspective sidebar buffer.")

(defcustom persp-utils-sidebar-auto-show-on-new t
  "Whether to automatically show sidebar when creating new perspective."
  :type 'boolean
  :group 'persp-utils)

(defcustom persp-utils-sidebar-session-status-function nil
  "Function to format session status for a perspective name.
Called with perspective name (string), returns propertized string or nil."
  :type '(choice (const nil) function)
  :group 'persp-utils)

(defvar persp-utils-sidebar-refresh-hook nil
  "Hook run when sidebar is interactively refreshed.
External status providers can add scan functions here.")

;; Core functions
(defun persp-utils-sidebar--ensure-displayed ()
  "Ensure sidebar window exists and is rendered.  Does not change focus."
  (let ((buffer (get-buffer-create persp-utils-sidebar-buffer-name)))
    (with-current-buffer buffer
      (persp-utils-sidebar--render-buffer))
    (setq persp-utils-sidebar-window
          (display-buffer buffer '((display-buffer-in-side-window)
                                   (side . left)
                                   (slot . 0)
                                   (window-width . 30)
                                   (no-other-window . t))))
    persp-utils-sidebar-window))

(defun persp-utils-sidebar-show ()
  "Show perspective sidebar and focus on it."
  (interactive)
  (persp-utils-sidebar--ensure-displayed)
  (select-window persp-utils-sidebar-window))

(defun persp-utils-sidebar-toggle ()
  "Toggle perspective sidebar."
  (interactive)
  (let ((buffer (get-buffer persp-utils-sidebar-buffer-name)))
    (if (and buffer (get-buffer-window buffer))
        (persp-utils-sidebar-close)
      (persp-utils-sidebar-show))))

(defun persp-utils-sidebar-close ()
  "Close perspective sidebar."
  (interactive)
  (let ((buffer (get-buffer persp-utils-sidebar-buffer-name)))
    (when buffer
      (let ((window (get-buffer-window buffer)))
        (when window
          (delete-window window)
          (setq persp-utils-sidebar-window nil))))))

(defun persp-utils-sidebar-focus ()
  "Focus on perspective sidebar."
  (interactive)
  (let ((buffer (get-buffer persp-utils-sidebar-buffer-name)))
    (if (and buffer (get-buffer-window buffer))
        (select-window (get-buffer-window buffer))
      (persp-utils-sidebar-show))))

(defun persp-utils-sidebar-resize ()
  "Reset perspective sidebar size."
  (interactive)
  (let ((buffer (get-buffer persp-utils-sidebar-buffer-name)))
    (when buffer
      (let ((window (get-buffer-window buffer)))
        (when window
          (with-selected-window window
            (window-resize window (- 30 (window-width)) t)))))))

;; Internal functions
(defun persp-utils-sidebar--render-buffer ()
  "Render the perspective list in sidebar buffer."
  (let ((inhibit-read-only t)
        (keymap (persp-utils-sidebar--create-keymap))
        (current-persp (persp-current-name))
        (all-persps (persp-names)))
    (erase-buffer)
    (insert "persp-utils sidebar\n")
    (insert "===================\n\n")
    (if all-persps
        (dolist (persp all-persps)
          (if (string= persp current-persp)
              ;; Highlight current perspective
              (insert (propertize (format "► %s\n" persp)
                                  'face 'highlight))
            (insert-button persp
                           'action `(lambda (button)
                                      (persp-switch ,persp))
                           'follow-link t)
            (insert "\n"))
          ;; Session status line
          (let ((status-str (and persp-utils-sidebar-session-status-function
                                 (funcall persp-utils-sidebar-session-status-function persp))))
            (insert (if status-str
                        (format "    %s\n" status-str)
                      "\n"))))
      (insert "No perspectives\n"))
    (goto-char (point-min))
    (setq buffer-read-only t)
    (use-local-map keymap)))

(defun persp-utils-sidebar--create-keymap ()
  "Create keymap for perspective sidebar."
  (let ((keymap (make-sparse-keymap)))
    (define-key keymap "n" 'persp-next)
    (define-key keymap "j" 'persp-next)
    (define-key keymap "p" 'persp-prev)
    (define-key keymap "k" 'persp-prev)
    (define-key keymap (kbd "RET") 'persp-utils-sidebar-select-current)
    (define-key keymap (kbd "SPC") 'persp-utils-sidebar-select-current)
    (define-key keymap "q" 'persp-utils-sidebar-close)
    (define-key keymap "r" 'persp-utils-sidebar-resize)
    (define-key keymap "g" 'persp-utils-sidebar-refresh)
    keymap))

(defun persp-utils-sidebar-select-current ()
  "Select perspective at current line in sidebar buffer."
  (interactive)
  (let ((persp-name (thing-at-point 'symbol)))
    (when (and persp-name (member persp-name (persp-names)))
      (persp-switch persp-name))))

(defun persp-utils-sidebar-refresh ()
  "Refresh the sidebar content and update highlight.
When called interactively, also run `persp-utils-sidebar-refresh-hook'."
  (interactive)
  (when (called-interactively-p 'any)
    (run-hooks 'persp-utils-sidebar-refresh-hook))
  (let ((buffer (get-buffer persp-utils-sidebar-buffer-name)))
    (when (and buffer
               persp-utils-sidebar-window
               (window-live-p persp-utils-sidebar-window))
      (save-selected-window
        (with-current-buffer buffer
          (persp-utils-sidebar--render-buffer))))))

(defun persp-utils-sidebar-on-new-perspective ()
  "Handle new perspective creation - show sidebar if enabled."
  (run-with-idle-timer 0.01 nil
                       (lambda ()
                         (if persp-utils-sidebar-auto-show-on-new
                             (persp-utils-sidebar--ensure-displayed)
                           (persp-utils-sidebar-refresh)))))

;; Auto-refresh when perspective changes
(advice-add 'persp-switch :after
            (lambda (&rest _) (persp-utils-sidebar-refresh)))

(advice-add 'persp-new :after
            (lambda (&rest _) (persp-utils-sidebar-on-new-perspective)))

(advice-add 'persp-kill :after
            (lambda (&rest _) (persp-utils-sidebar-refresh)))

(advice-add 'persp-rename :after
            (lambda (&rest _) (persp-utils-sidebar-refresh)))

(advice-add 'persp-next :after
            (lambda (&rest _) (persp-utils-sidebar-refresh)))

(advice-add 'persp-prev :after
            (lambda (&rest _) (persp-utils-sidebar-refresh)))

(advice-add 'persp-switch-last :after
            (lambda (&rest _) (persp-utils-sidebar-refresh)))

(advice-add 'persp-kill-others :after
            (lambda (&rest _) (persp-utils-sidebar-refresh)))

(advice-add 'persp-state-load :after
            (lambda (&rest _) (persp-utils-sidebar-refresh)))

(advice-add 'persp-state-restore :after
            (lambda (&rest _) (persp-utils-sidebar-refresh)))

(provide 'persp-utils-sidebar)
;;; persp-utils-sidebar.el ends here
