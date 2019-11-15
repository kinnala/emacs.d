;; install package manager

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; install org-mode

(straight-use-package 'org)

;; install use-package

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; install and configure other packages

(use-package org
  :commands org-babel-do-load-languages
  :config
  (unbind-key "C-," org-mode-map)
  :init
  (add-hook 'org-mode-hook (lambda () (org-babel-do-load-languages
                                       'org-babel-load-languages '((python . t)
                                                                   (shell . t)))))
  (setq org-default-notes-file "~/Dropbox/Notes/gtd/inbox.org"
        org-agenda-files '("~/Dropbox/Notes/gtd/inbox.org"
                           "~/Dropbox/Notes/gtd/tickler.org")
        org-refile-targets '(("~/Dropbox/Notes/gtd/inbox.org" . (:maxlevel . 1))
                             ("~/Dropbox/Notes/gtd/someday.org" . (:maxlevel . 1))
                             ("~/Dropbox/Notes/gtd/tickler.org" . (:maxlevel . 1)))
        org-log-done 'time
        org-tags-column 0
        org-export-babel-evaluate nil
        org-adapt-indentation nil
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-duration-format '(("d" . nil) ("h" . t) (special . 2))
        org-format-latex-options '(:foreground default
                                   :background default
                                   :scale 1.5
                                   :html-foreground "Black"
                                   :html-background "Transparent"
                                   :html-scale 1.0
                                   :matchers
                                   ("begin" "$1" "$" "$$" "\\(" "\\["))
        org-src-preserve-indentation t
        org-confirm-babel-evaluate nil
        python-shell-completion-native-disabled-interpreters '("python")
        org-babel-default-header-args:sh '((:prologue . "exec 2>&1")
                                           (:epilogue . ":"))
        org-capture-templates '(("t" "Todo" entry
                                 (file "~/Dropbox/Notes/gtd/inbox.org")
                                 "* TODO %?\n  %i\n  %a")
                                ("a" "Appointment" entry
                                 (file "~/Dropbox/Notes/gtd/inbox.org")
                                 "* %?\n  %i\n  %a")))
  :bind (("C-c c" . org-capture)
         ("C-c a" . org-agenda)))

(use-package s)

(use-package f)

(use-package dash)

(use-package hydra)

(use-package ivy
  :init
  (ivy-mode 1)
  (setq ivy-height 20
	ivy-fixed-height-minibuffer t
       	ivy-use-virtual-buffers t)
  :bind (("C-x b" . ivy-switch-buffer)
         ("C-c r" . ivy-resume)
	 ("C-x C-b" . ibuffer)))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x C-f" . counsel-find-file)
	 ("C-c g" . counsel-rg)
	 ("C-c f" . counsel-file-jump)
         ("C-c G" . counsel-git)
         ("C-x b" . counsel-switch-buffer)
         ("C-c h" . counsel-minibuffer-history)
         ("M-y" . counsel-yank-pop))
  :init (setq counsel-find-file-ignore-regexp "\\archive\\'"))

(use-package swiper
  :bind ("C-c s" . swiper))

(use-package ivy-hydra)

(use-package magit
  :init
  (setq magit-repository-directories '(("~/src" . 1)
                                       ("~/.emacs.d/straight/repos/" . 1)))
  :bind (("C-x g" . magit-status)
         ("C-c M-g" . magit-file-dispatch)
         ("C-c l" . magit-list-repositories)))

(use-package which-key
  :init (which-key-mode))

(use-package exec-path-from-shell
  :init (exec-path-from-shell-initialize))

(use-package anaconda-mode
  :init
  (add-hook 'python-mode-hook 'anaconda-mode)
  (add-hook 'python-mode-hook 'anaconda-eldoc-mode))

(use-package expand-region
  :bind ("C-." . er/expand-region)
  :init
  (require 'expand-region)
  (require 'cl)
  (defun mark-around* (search-forward-char)
    (let* ((expand-region-fast-keys-enabled nil)
           (char (or search-forward-char
                     (char-to-string
                      (read-char "Mark inner, starting with:"))))
           (q-char (regexp-quote char))
           (starting-point (point)))
      (when search-forward-char
        (search-forward char (point-at-eol)))
      (flet ((message (&rest args) nil))
        (er--expand-region-1)
        (er--expand-region-1)
        (while (and (not (= (point) (point-min)))
                    (not (looking-at q-char)))
          (er--expand-region-1))
        (er/expand-region -1))))
  (defun mark-around ()
    (interactive)
    (mark-around* nil))
  (define-key global-map (kbd "M-i") 'mark-around))

(use-package multiple-cursors
  :init
  (define-key global-map (kbd "C-'") 'mc-hide-unmatched-lines-mode)
  (define-key global-map (kbd "C-,") 'mc/mark-next-like-this)
  (define-key global-map (kbd "C-;") 'mc/mark-all-dwim))

(use-package move-lines
  :straight (move-lines
	     :type git
	     :host github
	     :repo "kinnala/move-lines")
  :after hydra
  :init
  (progn
    (defun tom/shift-left (start end &optional count)
      "Shift region left and activate hydra."
      (interactive
       (if mark-active
           (list (region-beginning) (region-end) current-prefix-arg)
         (list (line-beginning-position) (line-end-position) current-prefix-arg)))
      (python-indent-shift-left start end count)
      (tom/hydra-move-lines/body))

    (defun tom/shift-right (start end &optional count)
      "Shift region right and activate hydra."
      (interactive
       (if mark-active
           (list (region-beginning) (region-end) current-prefix-arg)
         (list (line-beginning-position) (line-end-position) current-prefix-arg)))
      (python-indent-shift-right start end count)
      (tom/hydra-move-lines/body))
    
    (defun tom/move-lines-p ()
      "Move lines up once and activate hydra."
      (interactive)
      (move-lines-up 1)
      (tom/hydra-move-lines/body))
    
    (defun tom/move-lines-n ()
      "Move lines down once and activate hydra."
      (interactive)
      (move-lines-down 1)
      (tom/hydra-move-lines/body))
    
    (defhydra tom/hydra-move-lines ()
      "Move one or multiple lines"
      ("n" move-lines-down "down")
      ("p" move-lines-up "up")
      ("<" python-indent-shift-left "left")
      (">" python-indent-shift-right "right")))
  
  :bind (("C-c n" . tom/move-lines-n)
	 ("C-c p" . tom/move-lines-p))

  :bind (:map python-mode-map
              ("C-c <" . tom/shift-left)
              ("C-c >" . tom/shift-right)))

(use-package flycheck
  :init (global-flycheck-mode))

(use-package term
  :straight f
  :init
  (defun tom/toggle-line-mode ()
    "Toggles term between line mode and char mode"
    (interactive)
    (if (term-in-line-mode)
        (term-char-mode)
      (term-line-mode)))
  (add-hook 'term-mode-hook
            (lambda () (define-key term-mode-map
                         (kbd "C-c C-j")
                         'tom/toggle-line-mode)))
  (add-hook 'term-mode-hook
            (lambda () (define-key term-raw-map
                         (kbd "C-c C-j")
                         'tom/toggle-line-mode))))

(use-package dired-x
  :straight f)

(use-package dired
  :after (term dired-x)
  :straight f
  :init
  (setq dired-dwim-target t)
  (setq dired-omit-files "^\\...+$")
  (add-hook 'dired-mode-hook (lambda () (dired-omit-mode 1)))
  :bind (("C-x C-j" . dired-jump))
  :bind (:map dired-mode-map
              ("'" . ansi-term)
              ("j" . swiper)
              ("s" . swiper)))

(use-package ob-async
  :after org)

(use-package request)

(use-package json-mode)

(use-package leuven-theme
  :after diredfl
  :init
  (load-theme 'leuven t)
  (global-hl-line-mode)
  (set-face-attribute 'font-lock-type-face nil :box 1)
  (set-face-attribute 'font-lock-function-name-face nil :box 1)
  (set-face-attribute 'font-lock-constant-face nil :box 1)
  (set-face-attribute
   'term nil :foreground "#000000" :background "#DDFFFF")
  (set-face-attribute
   'diredfl-compressed-file-suffix nil :foreground "#000000")
  (set-face-attribute
   'diredfl-dir-name nil :foreground "#000000" :background "#FFDDDD" :box nil)
  (set-face-attribute
   'diredfl-dir-heading nil :foreground "#777777" :background nil)
  (set-face-attribute
   'diredfl-write-priv nil :foreground "#000000" :background "#FF9999")
  (set-face-attribute
   'diredfl-read-priv nil :foreground "#000000" :background "#99FF99")
  (set-face-attribute
   'diredfl-exec-priv nil :foreground "#000000" :background "#9999FF")
  (set-face-attribute
   'dired-directory nil :foreground "#0000FF" :background "#FFDDDD" :box 1)
  (set-face-attribute 'mode-line nil :font "Iosevka-9" :background "#000000")
  (set-face-attribute 'mode-line-inactive nil :font "Iosevka-9")
  (set-face-attribute 'default nil :font "Iosevka-15")
  (setq initial-frame-alist '(
                              (mouse-color           . "midnightblue")
                              (foreground-color      . "grey20")
                              (background-color      . "FloralWhite")
                              (internal-border-width . 2)
                              (line-spacing          . 1)
                              (top . 20) (left . 650) (width . 91) (height . 60)))
  (setq default-frame-alist '(
                              (border-color          . "#4e3832")
                              (foreground-color      . "grey10")
                              (background-color      . "FloralWhite")
                              (cursor-color          . "purple")
                              (cursor-type           . box)
                              (top . 30) (left . 150) (width . 89) (height . 56)))
  (defun my-minibuffer-setup ()
    (set (make-local-variable 'face-remapping-alist)
         '((default :height 1.1))))
  (add-hook 'minibuffer-setup-hook 'my-minibuffer-setup))

(use-package highlight-indentation
  :init
  (defun set-hl-indent-color ()
    (set-face-background 'highlight-indentation-face "#ededdc"))
  (add-hook 'python-mode-hook 'highlight-indentation-mode)
  (add-hook 'python-mode-hook 'set-hl-indent-color)
  (add-hook 'yaml-mode-hook 'highlight-indentation-mode)
  (add-hook 'yaml-mode-hook 'set-hl-indent-color))

(use-package yaml-mode)

(use-package wgrep)

(use-package csv-mode
  :mode "\\.csv$"
  :init
  (setq csv-separators '(";")))

(use-package rainbow-delimiters
  :init (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package phi-search
  :after multiple-cursors
  :init (require 'phi-replace)
  :bind ("C-:" . phi-replace)
  :bind (:map mc/keymap
              ("C-s" . phi-search)
              ("C-r" . phi-search-backward)))

(use-package virtualenvwrapper
  :init
  (setq venv-location "~/src/venv")
  (add-hook 'venv-postactivate-hook
            (lambda () (setq flycheck-python-pylint-executable
                              (s-concat python-shell-virtualenv-root
                                        "bin/pylint"))))
  :bind ("C-c w" . venv-workon))

(use-package symbol-overlay
  :init (add-hook 'prog-mode-hook 'symbol-overlay-mode)
  :bind (("<f7>" . symbol-overlay-put)
         ("M-n" . symbol-overlay-switch-forward)
         ("M-p" . symbol-overlay-switch-backward)
         ("<f8>" . symbol-overlay-remove-all)))

(use-package restclient)

(use-package ob-restclient
  :after (org restclient)
  :init
  (org-babel-do-load-languages
   'org-babel-load-languages '((restclient . t))))

(use-package htmlize)

(use-package diredfl
  :init
  (diredfl-global-mode))

(use-package magit-annex)

(use-package python-pytest
  :bind ("C-c t" . python-pytest-popup))

;; useful functions

(defun tom/unfill-paragraph (&optional region)
  "Take REGION and turn it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

(define-key global-map "\M-Q" 'tom/unfill-paragraph)

;; other global configurations

;; show current function in modeline
(which-function-mode)

;; scroll screen
(define-key global-map "\M-n" 'scroll-up-line)
(define-key global-map "\M-p" 'scroll-down-line)

;; change yes/no to y/n
(defalias 'yes-or-no-p 'y-or-n-p)
(setq confirm-kill-emacs 'yes-or-no-p)

;; enable winner-mode, previous window config with C-left
(winner-mode 1)

;; windmove
(windmove-default-keybindings)

;; disable tool and menu bars
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)

;; change gc behavior
(setq gc-cons-threshold 50000000)

;; warn when opening large file
(setq large-file-warning-threshold 100000000)

;; disable startup screen
(setq inhibit-startup-screen t)

;; useful frame title format
(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

;; automatic revert
(global-auto-revert-mode t)

;; highlight parenthesis, easier jumping with C-M-n/p
(show-paren-mode 1)
(setq show-paren-delay 0)

;; control indentation
(setq-default indent-tabs-mode nil)
(setq tab-width 4)
(defvaralias 'c-basic-offset 'tab-width)

;; modify scroll settings
(setq scroll-preserve-screen-position t)

;; set default fill width (e.g. M-q)
(setq-default fill-column 80)

;; hide modeline
(setq-default mode-line-format '("%e" mode-line-front-space mode-line-mule-info mode-line-client mode-line-modified mode-line-remote mode-line-frame-identification mode-line-buffer-identification "   " mode-line-position (vc-mode vc-mode) "  " mode-line-misc-info mode-line-end-spaces))

;; window dividers
(fringe-mode 0)
(setq window-divider-default-places t
      window-divider-default-bottom-width 1
      window-divider-default-right-width 1)
(window-divider-mode 1)

;; put all backups to same directory to not clutter directories
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

;; display line numbers
(global-display-line-numbers-mode)

;; browse in chrome
(setq browse-url-browser-function 'browse-url-chromium)

;; don't fontify latex
(setq font-latex-fontify-script nil)

;; set default encodings to utf-8
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-language-environment 'utf-8)
(set-selection-coding-system 'utf-8)

;; make Customize to not modify this file
(setq custom-file (make-temp-file "emacs-custom"))

;; enable all disabled commands
(setq disabled-command-function nil)

;; ediff setup
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; unbind keys
(unbind-key "C-z" global-map)

;; start emacs frames maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-hook 'window-setup-hook 'toggle-frame-fullscreen t)

;; change emacs frame by number
(defun tom/select-frame (n)
  "Select frame identified by the number N."
  (interactive)
  (let ((frame (nth n (reverse (frame-list)))))
    (if frame
        (select-frame-set-input-focus frame)
      (select-frame-set-input-focus (make-frame))
      (toggle-frame-fullscreen))))

(define-key global-map
  (kbd "M-1")
  (lambda () (interactive)
    (tom/select-frame 0)))
(define-key global-map
  (kbd "M-2")
  (lambda () (interactive)
    (tom/select-frame 1)))
(define-key global-map
  (kbd "M-3")
  (lambda () (interactive)
    (tom/select-frame 2)))
(define-key global-map
  (kbd "M-4")
  (lambda () (interactive)
    (tom/select-frame 3)))

;; load private configurations
(load "~/Dropbox/Config/emacs/private.el" t)

;; start emacsclient server
(server-start)
