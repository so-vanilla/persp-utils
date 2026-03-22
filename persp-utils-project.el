;;; persp-utils-project.el --- Project-based perspective creation -*- lexical-binding: t; -*-

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

;; persp-utils-project provides commands to create perspectives from project
;; directories.  Select a project via ghq or projectile, then open it in a
;; new perspective with dired.

;;; Code:

(require 'perspective)

(defun persp-utils-project--open (dir)
  "Create a perspective named after DIR's basename and open dired there.
If a perspective with the same name already exists, just switch to it."
  (let* ((expanded (expand-file-name dir))
         (name (file-name-nondirectory (directory-file-name expanded))))
    (if (member name (persp-names))
        (persp-switch name)
      (persp-switch name)
      (delete-other-windows)
      (cd expanded)
      (dired expanded))))

;;;###autoload
(defun persp-utils-project-ghq ()
  "Select a project from ghq and open it in a perspective."
  (interactive)
  (let* ((root (string-trim (shell-command-to-string "ghq root")))
         (projects (split-string (shell-command-to-string "ghq list") "\n" t))
         (chosen (completing-read "ghq project: " projects nil t))
         (dir (expand-file-name chosen root)))
    (persp-utils-project--open dir)))

;;;###autoload
(defun persp-utils-project-projectile ()
  "Select a project from projectile and open it in a perspective."
  (interactive)
  (let* ((projects (bound-and-true-p projectile-known-projects))
         (chosen (completing-read "Projectile project: " projects nil t)))
    (persp-utils-project--open chosen)))

(provide 'persp-utils-project)
;;; persp-utils-project.el ends here
