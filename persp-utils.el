;;; persp-utils.el --- Utilities for perspective.el -*- lexical-binding: t; -*-

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

;; persp-utils provides utility packages for perspective.el:
;; - Sidebar: Display and navigate perspectives in a side window
;; - Workspace: Template-based workspace auto-setup
;; - Terminal: Per-perspective terminal management

;;; Code:

(defgroup persp-utils nil
  "Utilities for perspective.el."
  :group 'perspective
  :prefix "persp-utils-")

(require 'persp-utils-sidebar)
(require 'persp-utils-workspace)
(require 'persp-utils-terminal)
(require 'persp-utils-project)

(provide 'persp-utils)
;;; persp-utils.el ends here
