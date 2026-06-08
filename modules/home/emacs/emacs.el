;;; -*- lexical-binding: t -*-

;;; --- Package setup ---
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)

;;; --- UI ---
(set-face-attribute 'default nil :family "Iosevka Term SS15" :height 140)

(when (display-graphic-p)
  (load-theme 'modus-vivendi t))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)

(setq display-line-numbers-type 'relative)
(setq display-line-numbers-width-start t)
(global-display-line-numbers-mode 1)

(setq split-width-threshold nil
      split-height-threshold 0)

(cond
 ((eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark)))
 (t
  (add-to-list 'default-frame-alist '(undecorated . t))))


;;; --- Quality of life ---
(save-place-mode 1)
(savehist-mode 1)
(global-auto-revert-mode 1)
(electric-pair-mode 1)
(setq confirm-kill-emacs 'yes-or-no-p)
(setq use-short-answers t)
(setq scroll-margin 5
      scroll-conservatively 101)

(setq backup-directory-alist
      `(("." . ,(expand-file-name "backups" user-emacs-directory))))
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(let ((auto-saves-dir (expand-file-name "auto-saves/" user-emacs-directory)))
  (make-directory auto-saves-dir t)
  (setq auto-save-file-name-transforms
        `((".*" ,auto-saves-dir t))))

(setq project-vc-extra-root-markers '(".project"))

;;; --- Evil ---
(use-package undo-fu)
(use-package undo-fu-session
  :config (undo-fu-session-global-mode))

(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-undo-system 'undo-fu
	evil-want-C-i-jump nil)

  :config
  (evil-mode 1)

  (evil-ex-define-cmd "W"  'evil-write)
  (evil-ex-define-cmd "Q"  'evil-quit)
  (evil-ex-define-cmd "Wq" 'evil-save-and-close)
  (evil-ex-define-cmd "wQ" 'evil-save-and-close)
  (evil-ex-define-cmd "WQ" 'evil-save-and-close)

  (evil-global-set-key 'normal (kbd "-") 'dired-jump)

  (setq-default word-wrap t))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init)
  (evil-define-key 'normal dired-mode-map
    (kbd "RET") 'dired-find-alternate-file
    (kbd "-")   'dired-up-directory))


;;; --- Dired ---
(put 'dired-find-alternate-file 'disabled nil)
(setq dired-kill-when-opening-new-dired-buffer t
      dired-listing-switches "-al")
(require 'ls-lisp)
(setq ls-lisp-dirs-first t
      ls-lisp-use-insert-directory-program nil)

;;; --- Completion ---
(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

;;; --- Consult ---
(use-package consult
  :config
  (global-set-key (kbd "C-x b") 'consult-buffer)
  (global-set-key (kbd "M-y") 'consult-yank-pop)
  (evil-global-set-key 'normal (kbd "M-s l") 'consult-line)
  (evil-global-set-key 'normal (kbd "M-s g")
    (lambda () (interactive)
      (consult-grep (or (when-let (p (project-current)) (project-root p))
                        default-directory))))
  (evil-global-set-key 'normal (kbd "M-s f")
    (lambda () (interactive)
      (consult-find (or (when-let (p (project-current)) (project-root p))
                        default-directory))))
  (evil-global-set-key 'normal (kbd "M-s p") 'consult-project-buffer)
  (evil-global-set-key 'normal (kbd "M-s i") 'consult-imenu)
  (evil-global-set-key 'normal (kbd "M-s e") 'consult-flymake))

(setq project-switch-commands 'project-dired)

;;; --- Vterm ---
(use-package vterm
  :config
  (setq vterm-max-scrollback 10000
	vterm-kill-buffer-on-exit t)
  (add-hook 'vterm-mode-hook (lambda () (display-line-numbers-mode -1))))

(use-package multi-vterm
  :after vterm)

;;; --- Magit ---
(use-package magit
  :config
  (evil-global-set-key 'normal (kbd "M-g") #'magit-status))

;;; --- Kubernetes ---
(use-package kubel)
(use-package kubel-evil
  :after kubel)

;;; --- Perspective
(use-package perspective
  :custom
  (persp-mode-prefix-key (kbd "C-x x"))
  :config
  (persp-mode)
  (consult-customize consult-source-buffer :hidden t :default nil)
  (add-to-list 'consult-buffer-sources persp-consult-source))

;;; --- Org Mode ---
(use-package org
  :ensure nil)
(evil-global-set-key 'normal (kbd "M-o a") #'org-agenda)
(evil-global-set-key 'normal (kbd "M-o c") #'org-capture)
(evil-global-set-key 'normal (kbd "M-o l") #'org-store-link)

;;; --- Treesitter ---
;; Emacs 30 automatically uses ts-modes when grammars are available.
;; Nix provides all grammars via treesit-grammars.with-all-grammars.
(setq major-mode-remap-alist
	'((yaml-mode . yaml-ts-mode)
	(bash-mode . bash-ts-mode)
	(js-mode . js-ts-mode)
	(css-mode . css-ts-mode)
	(python-mode . python-ts-mode)))
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))

(use-package consult-eglot)
(evil-global-set-key 'normal (kbd "M-s s") 'consult-eglot-symbols)

;;; --- LSP: Eglot ---
(use-package exec-path-from-shell
  :config
  (setq exec-path-from-shell-arguments '("-l"))
  (exec-path-from-shell-initialize))

(add-hook 'go-ts-mode-hook         #'eglot-ensure)
(add-hook 'rust-ts-mode-hook       #'eglot-ensure)
(add-hook 'typescript-ts-mode-hook #'eglot-ensure)
(add-hook 'python-ts-mode-hook     #'eglot-ensure)
(add-hook 'zig-mode-hook           #'eglot-ensure)

(add-hook 'before-save-hook (lambda () (when (eglot-managed-p) (eglot-format-buffer))))

(with-eval-after-load 'eglot
  (evil-define-key 'normal eglot-mode-map (kbd "M-r")   'eglot-rename)
  (evil-define-key 'normal eglot-mode-map (kbd "M-a")   'eglot-code-actions)
  (evil-define-key 'normal eglot-mode-map (kbd "gd")    'xref-find-definitions)
  (evil-define-key 'normal eglot-mode-map (kbd "gI")    'eglot-find-implementation)
  (evil-define-key 'normal eglot-mode-map (kbd "[d")    'flymake-goto-prev-error)
  (evil-define-key 'normal eglot-mode-map (kbd "]d")    'flymake-goto-next-error)
  (evil-define-key 'normal eglot-mode-map (kbd "ge")    'flymake-show-buffer-diagnostics))

;;; --- Corfu ---
(use-package corfu
  :init (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  :bind (:map corfu-map
         ("C-n"     . corfu-next)
         ("C-p"     . corfu-previous)
         ("<escape>" . corfu-quit)
         ("<return>" . corfu-insert)))

;;; --- Language modes ---
(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode))

(use-package hcl-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.tf\\'" . hcl-mode)))


;;; --- escape colors in compile mode ---
(require 'ansi-color)
(defun endless/colorize-compilation ()
  "Colorize from `compilation-filter-start' to `point'."
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region
     compilation-filter-start (point))))

(add-hook 'compilation-filter-hook
          #'endless/colorize-compilation)

;;; --- Compilation settings ---

;; Always scroll compilation output
(setq compilation-scroll-output t)

;; Always enable comint mode in compilation buffers
(defun my/compile-autocomint (orig-fun command &rest args)
  "Force comint mode for all compilation commands."
  (apply orig-fun command t (cdr args)))

(advice-add 'compilation-start :around #'my/compile-autocomint)

;; Automatically switch focus to compilation buffer
(add-hook 'compilation-start-hook
          (lambda (_proc)
            (pop-to-buffer "*compilation*")))

;; --- Gnus ---
(setq gnus-select-method '(nntp "news.gmane.io"))
(setq gnus-secondary-select-methods '((nnrss "")))
(setq gnus-use-cache t)
(setq gnus-novice-user nil)

;; Async — prefetch articles for snappy reading
(setq gnus-asynchronous t)
(setq gnus-use-article-prefetch 15)

;; Startup behaviour
;; Don't auto-pull new groups from the server on startup.
;; Without this, every new gwene.* group on news.gmane.io (e.g. science
;; feeds) gets discovered and auto-subscribed.
(setq gnus-check-new-newsgroups nil)
(setq gnus-read-active-file 'some)
;; Any new group that *is* discovered goes to the killed list, not subscribed.
(setq gnus-subscribe-newsgroup-method 'gnus-subscribe-killed)
(setq gnus-use-dribble-file t)
(setq gnus-always-read-dribble-file t)

;; Group buffer
(setq gnus-permanently-visible-groups ".")
;; NOTE: Do NOT set gnus-auto-subscribed-groups to "gwene" — news.gmane.io
;; serves thousands of gwene.* feeds and they would all get auto-subscribed.
(setq gnus-group-line-format "%M%p%P %5y:%B%(%g%)\n")
(setq gnus-topic-display-empty-topics nil)
;; Sort groups by "rank" = subscription level + score.
;; Level reflects subscribedness (1 = most subscribed … 5 = least), so the
;; groups you care about most float to the top of each topic.
(setq gnus-group-sort-function 'gnus-group-sort-by-rank)

;; Summary buffer
(setq gnus-auto-select-first nil)
;; When entering a group, only fetch the newest 100 articles (don't ask).
;; Groups with more unread than this are "large"; we cap the fetch at 100.
(setq gnus-large-newsgroup 100)
(setq gnus-summary-ignore-duplicates t)
(setq gnus-suppress-duplicates t)
(setq gnus-summary-make-false-root 'adopt)
(setq gnus-summary-thread-gathering-function 'gnus-gather-threads-by-subject)
(setq gnus-summary-gather-subject-limit 'fuzzy)
(setq gnus-thread-sort-functions
      '((not gnus-thread-sort-by-date)
        (not gnus-thread-sort-by-number)))
(setq gnus-subthread-sort-functions 'gnus-thread-sort-by-date)
(setq gnus-summary-line-format "%U%R %-18,18&user-date; %4L:%-25,25f %B%s\n")
(setq gnus-sum-thread-tree-false-root "")
(setq gnus-sum-thread-tree-indent " ")
(setq gnus-sum-thread-tree-single-indent "")
(setq gnus-sum-thread-tree-leaf-with-other "+-> ")
(setq gnus-sum-thread-tree-root "")
(setq gnus-sum-thread-tree-single-leaf "\\-> ")
(setq gnus-sum-thread-tree-vertical "|")

;; Article display
(setq gnus-article-sort-functions
      '((not gnus-article-sort-by-number)
        (not gnus-article-sort-by-date)))
(setq gnus-inhibit-images t)
(setq gnus-treat-display-smileys nil)
(setq gnus-article-truncate-lines nil)
(setq gnus-html-frame-width 80)
(setq gnus-visible-headers
      '("^From:" "^To:" "^Cc:" "^Subject:" "^Newsgroups:" "^Date:"
        "Followup-To:" "Reply-To:" "^Organization:"))
(setq gnus-sorted-header-list gnus-visible-headers)

;; View links inside Emacs with eww (only in Gnus article buffers)
(with-eval-after-load 'gnus-art
  (add-hook 'gnus-article-mode-hook
            (lambda () (setq-local browse-url-browser-function 'eww-browse-url))))
;; eww: keep images, stop reflow-driven scroll jumping
(setq shr-image-animate nil
      shr-max-image-proportion 0.7)

(add-hook 'eww-mode-hook
          (lambda ()
            (display-line-numbers-mode -1)
            (setq-local scroll-margin 0
                        scroll-conservatively 0
                        scroll-preserve-screen-position t
                        auto-window-vscroll nil)))
;; Date format
(setq gnus-user-date-format-alist
      '(((gnus-seconds-today)                 . "Today %k:%M")
        ((+ (gnus-seconds-today) (* 24 3600)) . "Yesterday %k:%M")
        (604800                               . "%a %e %b")
        (t                                    . "%Y-%m-%d")))
(setq gnus-article-date-headers '(local))

;; Highlight current line in group/summary
(dolist (mode '(gnus-group-mode-hook gnus-summary-mode-hook))
  (add-hook mode #'hl-line-mode))

(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)
(add-hook 'gnus-select-group-hook #'gnus-group-set-timestamp)

;; Evil keybindings for Gnus Topic mode
;; This fixes conflicts where evil steals C-u and other keys
(with-eval-after-load 'gnus-topic
  (evil-define-key 'normal gnus-topic-mode-map
    ;; Topic folding/unfolding
    (kbd "TAB")     'gnus-topic-select-group  ;; toggle fold on topic line
    (kbd "za")      'gnus-topic-select-group  ;; vim-style toggle fold
    (kbd "<tab>")   'gnus-topic-select-group

    ;; Topic management
    (kbd "T n")     'gnus-topic-create-topic   ;; create new topic
    (kbd "T m")     'gnus-topic-move-group     ;; move group to topic
    (kbd "T r")     'gnus-topic-rename         ;; rename topic
    (kbd "T s")     'gnus-topic-sort-groups    ;; sort groups in topic
    (kbd "T M")     'gnus-topic-move-matching  ;; move matching groups

    ;; Topic indent (hierarchy)
    (kbd "T TAB")   'gnus-topic-indent         ;; make topic child of previous
    (kbd "T <backtab>") 'gnus-topic-unindent   ;; make topic top-level again

    ;; Universal argument workaround (C-u is taken by evil scroll)
    ;; Use the prefix arg via leader or just use numeric prefix: 4 g
    ;; To list all groups (normally C-u RET on topic):
    (kbd "O")       'gnus-topic-select-group   ;; open/toggle topic

    ;; Navigation
    (kbd "RET")     'gnus-topic-select-group
    (kbd "g r")     'gnus-group-get-new-news))

;; Gnus Summary mode
(with-eval-after-load 'gnus-sum
  (evil-define-key 'normal gnus-summary-mode-map
    (kbd "RET")     'gnus-summary-scroll-up
    (kbd "q")       'gnus-summary-exit
    (kbd "r")       'gnus-summary-reply
    (kbd "R")       'gnus-summary-reply-with-original
    (kbd "F")       'gnus-summary-followup-with-original))

;; -- Org
(use-package org
  :ensure nil
  :config
  (setq org-src-fontify-natively t)
  (setq org-fontify-whole-block-delimiter-line t)
  (setq org-fontify-quote-and-verse-blocks t)
  (add-to-list 'org-src-lang-modes '("shell" . sh)))

(use-package ob-async
  :ensure t)

;; active Babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((shell . t)
   (ocaml . t)
   (sql . t)
   (sqlite . t)
   (python . t)
   (emacs-lisp . t)))

(use-package htmlize
  :ensure t)

(use-package clipetty
  :ensure t
  :hook (after-init . global-clipetty-mode)
  :config
  (setq clipetty-tmux-ssh-agent t))

(xterm-mouse-mode 1)

;; ghostel
(use-package ghostel
  :ensure t)

;; ECA - ai
(use-package eca
  :ensure t)
