;;; persp-utils-workspace.el --- Template-based workspace setup for perspective.el -*- lexical-binding: t; -*-

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

;; persp-utils-workspace provides template-based workspace auto-setup for
;; perspective.el.  Define workspace templates with conditions, directories,
;; and setup functions, then apply them on startup or interactively.

;;; Code:

(require 'perspective)

(defcustom persp-utils-workspace-templates nil
  "List of workspace template plists.
Each plist has the following keys:
  :name      - Perspective name (string, required)
  :condition - Sexp evaluated to determine if workspace should be created (default t)
  :dir       - Working directory for the workspace (string, required)
  :setup     - Function called with optional DIR argument to set up the workspace"
  :type '(repeat plist)
  :group 'persp-utils)

(defcustom persp-utils-workspace-auto-setup-on-startup nil
  "Whether to automatically set up workspaces on Emacs startup."
  :type 'boolean
  :group 'persp-utils)

(defcustom persp-utils-workspace-startup-delay 0.5
  "Idle time in seconds before auto-setup runs on startup."
  :type 'number
  :group 'persp-utils)

(defcustom persp-utils-workspace-default-perspective nil
  "Name of the perspective to switch to after setup completes."
  :type '(choice (const nil) string)
  :group 'persp-utils)

(defcustom persp-utils-workspace-kill-initial-perspective nil
  "Name of the initial perspective to kill after setup (e.g. \"main\")."
  :type '(choice (const nil) string)
  :group 'persp-utils)

(defvar persp-utils-workspace-post-setup-hook nil
  "Hook run after all workspace templates have been applied.")

(defun persp-utils-setup-workspaces ()
  "Set up all workspaces defined in `persp-utils-workspace-templates'."
  (interactive)
  (dolist (template persp-utils-workspace-templates)
    (let ((name (plist-get template :name))
          (condition (plist-get template :condition))
          (dir (plist-get template :dir))
          (setup-fn (plist-get template :setup)))
      (when (eval (or condition t))
        (persp-switch name)
        (delete-other-windows)
        (let ((default-directory (expand-file-name (or dir "~/"))))
          (cd default-directory)
          (when setup-fn
            (funcall setup-fn default-directory))))))
  (when persp-utils-workspace-default-perspective
    (persp-switch persp-utils-workspace-default-perspective))
  (when persp-utils-workspace-kill-initial-perspective
    (persp-kill persp-utils-workspace-kill-initial-perspective))
  (run-hooks 'persp-utils-workspace-post-setup-hook))

(defun persp-utils-add-workspace ()
  "Interactively add a workspace from templates."
  (interactive)
  (let* ((names (mapcar (lambda (tmpl) (plist-get tmpl :name))
                        persp-utils-workspace-templates))
         (chosen (completing-read "Workspace template: " names nil t))
         (template (seq-find (lambda (tmpl) (string= (plist-get tmpl :name) chosen))
                             persp-utils-workspace-templates)))
    (when template
      (let* ((name (plist-get template :name))
             (dir (plist-get template :dir))
             (setup-fn (plist-get template :setup))
             (final-name (if (member name (persp-names))
                             (format "%s<2>" name)
                           name)))
        (persp-switch final-name)
        (delete-other-windows)
        (let ((default-directory (expand-file-name (or dir "~/"))))
          (cd default-directory)
          (when setup-fn
            (funcall setup-fn default-directory)))))))

(defun persp-utils-workspace--maybe-auto-setup ()
  "Run workspace auto-setup if enabled."
  (when persp-utils-workspace-auto-setup-on-startup
    (run-with-idle-timer persp-utils-workspace-startup-delay nil
                         #'persp-utils-setup-workspaces)))

(add-hook 'emacs-startup-hook #'persp-utils-workspace--maybe-auto-setup)

(provide 'persp-utils-workspace)
;;; persp-utils-workspace.el ends here
