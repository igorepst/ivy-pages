;;; counsel-pages.el --- Complete current buffer's pages with Ivy -*- lexical-binding: t -*-

;; Copyright (C) 2016 Igor Epstein

;; Author: Igor Epstein <igorepst@gmail.com>
;; URL: https://github.com/igorepst/counsel-pages
;; Created: 07/24/2016
;; Package-Version: 20160724.001
;; Version: 0.1
;; Package-Requires: ((emacs "24.1") (ivy "0.8.0"))
;; Keywords: convenience, matching

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Call `counsel-pages' to jump between pages in a document using Ivy.
;;
;; Based on built-in `page-ext.el' and inspired by `helm-pages.el' from
;; https://github.com/david-christiansen/helm-pages/blob/master/helm-pages.el

;;; Code:

(require 'ivy)

(defvar counsel-pages--page-delimiter "^\014"
  "Regexp describing line-beginnings that separate pages.")

(defvar counsel-pages-history nil
  "History for the counsel pages.")

(defun counsel-pages-function ()
  "Build list of pages and their positions."
  (let ((counsel-pages-list ()))
    (save-excursion
      (goto-char (point-min))
      (save-restriction
	(if (and (save-excursion
		   (re-search-forward counsel-pages--page-delimiter nil t))
		 (= 1 (match-beginning 0)))
	    (goto-char (match-end 0)))
	(push (counsel-pages-get-header-and-position) counsel-pages-list)

	(while (re-search-forward counsel-pages--page-delimiter nil t)
	  (push (counsel-pages-get-header-and-position) counsel-pages-list))))
    (nreverse counsel-pages-list)))

(defun counsel-pages-get-header-and-position ()
  "Get page header and its position."
  (skip-chars-forward " \t\n")
  (let* ((start (point))
	 ;; Append start point as ivy doesn't support duplicate strings
	 ;; See https://github.com/abo-abo/swiper/issues/501
	 (substr (concat (buffer-substring start (line-end-position)) ":"
			 (number-to-string start))))
    (cons substr start)))

(defun counsel-pages-transformer (header)
  "Return HEADER without start point."
  (replace-regexp-in-string ":[0-9]+$" "" header))

(ivy-set-display-transformer
 'counsel-pages
 'counsel-pages-transformer)

(defun counsel-pages ()
  "Select buffer's pages via `counsel'."
  (interactive)
  (ivy-read "Pages: "
	    (counsel-pages-function)
	    :action (lambda (x)
		      (goto-char (cdr x))
		      (recenter-top-bottom 0))
	    :history counsel-pages-history
	    :require-match t
	    :caller 'counsel-pages))

(provide 'counsel-pages)

;;; counsel-pages.el ends here
