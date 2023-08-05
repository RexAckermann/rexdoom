; $DOOMDIR/config.el -**- lexical-binding: t; -**-

(setq user-full-name "Rex Ackermann"
      user-mail-address "ackermann88888@gmail.com")

(setq org-directory "~/org/")

(eval-after-load 'tramp '(setenv "SHELL" "/bin/sh"))

;;; Emacs Load Path
(setq load-path (cons "~/.config/scripts/" load-path))

;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))

(setq doom-font (font-spec :family "FiraCode Nerd Font Mono" :size 15)
      doom-variable-pitch-font (font-spec :family "FiraCode Nerd Font" :size 15)
      doom-serif-font (font-spec :family "FiraCode Nerd Font" :size 15)
      doom-unicode-font (font-spec :family "FiraCode Nerd Font" :size 15)
      doom-big-font (font-spec :family "FiraCode Nerd Font" :size 25)
      )
  ;; (setq! doom-big-font (font-spec :family "FiraCode Nerd Font Mono" :size 12))
  ;; (setq doom-font "Terminus (TTF):pixelsize=12:antialias=off")
  ;; (setq doom-font "Fira Code-14")

(global-font-lock-mode t)

(setq doom-theme 'doom-molokai)

(setq display-line-numbers-type 'relative)

;;(set-frame-parameter (selected-frame) 'alpha '(<active> . <inactive>))
;;(set-frame-parameter (selected-frame) 'alpha <both>)
(add-to-list 'default-frame-alist '(alpha . (95 . 85)))
(set-frame-parameter nil 'alpha '(80 . 85))

(defun toggle-transparency ()
  (interactive)
  (let ((alpha (frame-parameter nil 'alpha)))
    (if (eq
     (if (numberp alpha)
         alpha
       (cdr alpha)) ; may also be nil
     95)
    (set-frame-parameter nil 'alpha '(80 . 85))
      (set-frame-parameter nil 'alpha '(95 . 95)))))

;;       '((height . 720)
;;         (width . 1080)))
;; (setq default-frame-alist '((fullscreen . maximized)))
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq frame-inhibit-implied-resize t)

;; (setq +lsp-company-backends '(:separate company-yasnippet company-capf))

;; (defun gjg/winner-clean-up-modified-list ()
;;   "Remove dead frames from `winner-modified-list`"
;;   (dolist (frame winner-modified-list)
;;     (unless (frame-live-p frame)
;;       (delete frame winner-modified-list))))
;; (advice-add 'winner-save-old-configurations :before #'gjg/winner-clean-up-modified-list)

;; (set-face-attribute 'mode-line nil :font "Ubuntu Mono-13")
(setq doom-modeline-height 30     ;; sets modeline height
      doom-modeline-bar-width 5   ;; sets right bar width
      doom-modeline-persp-name t  ;; adds perspective name to modeline
      doom-modeline-persp-icon t) ;; adds folder icon next to persp name

;; (minimap-mode)
;; (add-hook 'kill-buffer-hook 'minimap-kill)
;; (add-hook 'kill-emacs-hook 'minimap-kill)

(map! :leader
      :desc "Search in Buffer" "/" #'+default/search-buffer
      :desc "Go to" "." #'helm-find-files
      :desc "Sudo-Edit" "t s" #'sudo-edit
      :desc "Imenu-List" "t I" #'imenu-list-smart-toggle
      :desc "Toggle Transparency" "t t" #'toggle-transparency
      )

;; (defun emacsclient_startup (_)
;;   (demap-open))

;; (add-to-list 'after-make-frame-functions 'minimap-mode)

;; (add-hook 'server-visit-hook 'demap-open)

;; This function runs code inside selected block or or on whole buffer.

(defun auto_quickrun (beginning-of-buffer end)
  "Runs selected if a region is active, otherwise runs not-selected."
  (interactive "r")
  (if (region-active-p)
      (quickrun-region beginning-of-buffer end)
    (quickrun)))

(map! :leader
      :desc "RunCode-quickrun" "c r" #'auto_quickrun
      :desc "RunCode-quickrun-buffer" "c b" 'quickrun
      )
;; (global-set-key (kbd "SPC c r") 'auto_quickrun)

(org-babel-do-load-languages
 'org-babel-load-languages '((C . t)))

;; (defun my/run-babel-exec-blocks ()
;;   "Execute babel :exec blocks in current buffer."
;;   (interactive)
;;   (org-babel-map-src-blocks nil
;;     (let ((header (org-babel-get-header (point) :eval)))
;;       (when (string-match-p ":exec" header)
;;         (org-babel-execute-src-block)))))
;; (add-hook 'after-save-hook #'my/run-babel-exec-blocks)

;; (setq enable-local-eval t)

(defun org-babel-edit ()
  "Edit python src block with lsp support by tangling the block and
then setting the org-edit-special buffer-file-name to the
absolute path. Finally load eglot."
  (interactive)

;; org-babel-get-src-block-info returns lang, code_src, and header
;; params; Use nth 2 to get the params and then retrieve the :tangle
;; to get the filename
  (setq tangled-file-name (expand-file-name (assoc-default :tangle (nth 2 (org-babel-get-src-block-info)))))

  ;; tangle the src block at point
  ;; (org-babel-tangle '(4))
  (org-edit-special)

  ;; Now we should be in the special edit buffer with python-mode. Set
  ;; the buffer-file-name to the tangled file so that pylsp and
  ;; plugins can see an actual file.
  (setq-local buffer-file-name tangled-file-name)
  (eglot-ensure)
  )

(map! :leader
      :desc "Org-Block" "b e" #'org-babel-edit
      )

(defun convert-docx-to-org-and-open ()
  "Convert the current buffer's file from docx to org format and open it."
  (interactive)
  (when (and (buffer-file-name)
             (string= (file-name-extension (buffer-file-name)) "docx"))
    (let** ((docx-file (buffer-file-name))
           (org-file (concat (file-name-sans-extension docx-file) ".org")))
      (call-process "pandoc" nil nil nil "--from=docx" "--to=org"
                    docx-file "-o" org-file)
      (find-file org-file)
      (add-hook 'after-save-hook
                   (call-process "pandoc" nil nil nil "--from=org" "--to=docx"
                                 (buffer-file-name) "-o" docx-file)))))

(global-set-key (kbd "C-c d") 'convert-docx-to-org-and-open)

;; (defun lsp-org ()
;;   (interactive)
;;   (-if-let ((virtual-buffer &as &plist :workspaces) (-first (-lambda ((&plist :in-range))
;;                                                               (funcall in-range))
;;                                                             lsp--virtual-buffer-connections))
;;       (unless (equal lsp--virtual-buffer virtual-buffer)
;;         (setq lsp--buffer-workspaces workspaces)
;;         (setq lsp--virtual-buffer virtual-buffer)
;;         (setq lsp-buffer-uri nil)
;;         (lsp-mode 1)
;;         (lsp-managed-mode 1)
;;         (lsp-patch-on-change-event))

;;     (save-excursion
;;       (-let**** (virtual-buffer
;;               (wcb (lambda (f)
;;                      (with-current-buffer (plist-get virtual-buffer :buffer)
;;                        (-let**** (((&plist :major-mode :buffer-file-name
;;                                         :goto-buffer :workspaces) virtual-buffer)
;;                                (lsp--virtual-buffer virtual-buffer)
;;                                (lsp--buffer-workspaces workspaces))
;;                          (save-excursion
;;                            (funcall goto-buffer)
;;                            (funcall f))))))
;;               ((&plist :begin :end :post-blank :language) (cl-second (org-element-context)))
;;               ((&alist :tangle file-name) (cl-third (org-babel-get-src-block-info 'light)))

;;               (file-name (if file-name
;;                              (f-expand file-name)
;;                            (user-error "You should specify file name in the src block header.")))
;;               (begin-marker (progn
;;                               (goto-char begin)
;;                               (forward-line)
;;                               (set-marker (make-marker) (point))))
;;               (end-marker (progn
;;                             (goto-char end)
;;                             (forward-line (1- (- post-blank)))
;;                             (set-marker (make-marker) (1+ (point)))))
;;               (buf (current-buffer))
;;               (src-block (buffer-substring-no-properties begin-marker
;;                                                          (1- end-marker)))
;;               (indentation (with-temp-buffer
;;                              (insert src-block)

;;                              (goto-char (point-min))
;;                              (let ((indentation (current-indentation)))
;;                                (plist-put lsp--virtual-buffer :indentation indentation)
;;                                (org-do-remove-indentation)
;;                                (goto-char (point-min))
;;                                (- indentation (current-indentation))))))
;;         (add-hook 'post-command-hook #'lsp--virtual-buffer-update-position nil t)

;;         (when (fboundp 'flycheck-add-mode)
;;           (lsp-flycheck-add-mode 'org-mode))

;;         (setq lsp--virtual-buffer
;;               (list
;;                :in-range (lambda (&optional point)
;;                            (<= begin-marker (or point (point)) (1- end-marker)))
;;                :goto-buffer (lambda () (goto-char begin-marker))
;;                :buffer-string
;;                (lambda ()
;;                  (let ((src-block (buffer-substring-no-properties
;;                                    begin-marker
;;                                    (1- end-marker))))
;;                    (with-temp-buffer
;;                      (insert src-block)

;;                      (goto-char (point-min))
;;                      (while (not (eobp))
;;                        (delete-region (point) (if (> (+ (point) indentation) (point-at-eol))
;;                                                   (point-at-eol)
;;                                                 (+ (point) indentation)))
;;                        (forward-line))
;;                      (buffer-substring-no-properties (point-min)
;;                                                      (point-max)))))
;;                :buffer buf
;;                :begin begin-marker
;;                :end end-marker
;;                :indentation indentation
;;                :last-point (lambda () (1- end-marker))
;;                :cur-position (lambda ()
;;                                (lsp-save-restriction-and-excursion
;;                                  (list :line (- (lsp--cur-line)
;;                                                 (lsp--cur-line begin-marker))
;;                                        :character (let ((character (- (point)
;;                                                                       (line-beginning-position)
;;                                                                       indentation)))
;;                                                     (if (< character 0)
;;                                                         0
;;                                                       character)))))
;;                :line/character->point (-lambda (line character)
;;                                         (-let [inhibit-field-text-motion t]
;;                                           (+ indentation
;;                                              (lsp-save-restriction-and-excursion
;;                                                (goto-char begin-marker)
;;                                                (forward-line line)
;;                                                (-let [line-end (line-end-position)]
;;                                                  (if (> character (- line-end (point)))
;;                                                      line-end
;;                                                    (forward-char character)
;;                                                    (point)))))))
;;                :major-mode (org-src-get-lang-mode language)
;;                :buffer-file-name file-name
;;                :buffer-uri (lsp--path-to-uri file-name)
;;                :with-current-buffer wcb
;;                :buffer-live? (lambda (_) (buffer-live-p buf))
;;                :buffer-name (lambda (_)
;;                               (propertize (format "%s(%s:%s)%s"
;;                                                   (buffer-name buf)
;;                                                   begin-marker
;;                                                   end-marker
;;                                                   language)
;;                                           'face 'italic))
;;                :real->virtual-line (lambda (line)
;;                                      (+ line (line-number-at-pos begin-marker) -1))
;;                :real->virtual-char (lambda (char) (+ char indentation))
;;                :cleanup (lambda ()
;;                           (set-marker begin-marker nil)
;;                           (set-marker end-marker nil))))
;;         (setf virtual-buffer lsp--virtual-buffer)
;;         (puthash file-name virtual-buffer lsp--virtual-buffer-mappings)
;;         (push virtual-buffer lsp--virtual-buffer-connections)

;;         ;; TODO: tangle only connected sections
;;         (add-hook 'after-save-hook 'org-babel-tangle nil t)
;;         (add-hook 'lsp-after-open-hook #'lsp-patch-on-change-event nil t)
;;         (add-hook 'kill-buffer-hook #'lsp-kill-virtual-buffers nil t)

;;         (setq lsp--buffer-workspaces
;;               (lsp-with-current-buffer virtual-buffer
;;                 (lsp)
;;                 (plist-put virtual-buffer :workspaces (lsp-workspaces))
;;                 (lsp-workspaces)))))))



;; imenu-list

(setq imenu-list-focus-after-activation t)
(setq imenu-list-auto-resize t)
(setq zone-timer (run-with-idle-timer 100 t 'zone))

;; org-auto-tangle

;; (require 'org-auto-tangle)
;; (add-hook 'org-mode-hook 'org-auto-tangle-mode)
;; (setq org-auto-tangle-default t)

(use-package! org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))

(defun dt/insert-auto-tangle-tag ()
  "Insert auto-tangle tag in a literate config."
  (interactive)
  (evil-org-open-below 1)
  (insert "#+auto_tangle: t ")
  (evil-force-normal-state))

(map! :leader
      :desc "Insert auto_tangle tag" "i a" #'dt/insert-auto-tangle-tag)

;; clippy

;; (setq clippy-tip-show-function #'clippy-popup-tip-show)

;; undo-tree

;; (setq global-undo-tree-mode t)
(map! "<f5>" #'undo-tree-visualize)
(map! "<f3>" #'treemacs)
;; (global-set-key (kbd "SPC /") #'+default/search-buffer)
;; (global-set-key (kbd "M-.") #'+default/search-cwd)

 (defun init_undo-tree ()
     ;;  do awesome things
     (undo-tree-mode)
   )
 (add-hook 'buffer-list-update-hook 'init_undo-tree)

;; zlc is zsh something
(require 'zlc)
(zlc-mode t)

;; beacon

(beacon-mode 1)
;; (after! lsp-mode (setq lsp-enable-file-watchers nil))

;; company-completion

;;; completion/company/config.el -**- lexical-binding: t; -**-

(use-package! company
  :commands (company-complete-common
             company-complete-common-or-cycle
             company-manual-begin
             company-grab-line)
  :hook (doom-first-input . global-company-mode)
  :init
  (setq! company-minimum-prefix-length 1
        company-tooltip-limit 14
        company-tooltip-align-annotations t
        company-require-match 'never
        company-global-modes
        '(not erc-mode
              circe-mode
              message-mode
              help-mode
              gud-mode
              vterm-mode)
        company-frontends
        '(company-pseudo-tooltip-frontend  ; always show candidates in overlay tooltip
          company-echo-metadata-frontend)  ; show selected candidate docs in echo area

        ;; Buffer-local backends will be computed when loading a major mode, so
        ;; only specify a global default here.
        company-backends '(company-capf
                           company-files
                           company-dabbrev-code
                           company-keywords
                           company-dict
                           company-semantic
                           company-etags
                           company-abbrev
                           company-yasnippet
                           company-tempo)

        ;; These auto-complete the current selection when
        ;; `company-auto-commit-chars' is typed. This is too magical. We
        ;; already have the much more explicit RET and TAB.
        ;; company-auto-commit nil

        ;; Only search the current buffer for `company-dabbrev' (a backend that
        ;; suggests text your open buffers). This prevents Company from causing
        ;; lag once you have a lot of buffers open.
        company-dabbrev-other-buffers nil
        ;; Make `company-dabbrev' fully case-sensitive, to improve UX with
        ;; domain-specific words with particular casing.
        company-dabbrev-ignore-case nil
        company-dabbrev-downcase nil)

  (when (modulep! +tng)
    (add-hook 'global-company-mode-hook #'company-tng-mode))

  :config
  (when (modulep! :editor evil)
    (add-hook 'company-mode-hook #'evil-normalize-keymaps)
    (add-hook! 'evil-normal-state-entry-hook
      (defun +company-abort-h ()
        ;; HACK `company-abort' doesn't no-op if company isn't active; causing
        ;;      unwanted side-effects, like the suppression of messages in the
        ;;      echo-area.
        ;; REVIEW Revisit this to refactor; shouldn't be necessary!
        (when company-candidates
          (company-abort))))
    ;; Allow users to switch between backends on the fly. E.g. C-x C-s followed
    ;; by C-x C-n, will switch from `company-yasnippet' to
    ;; `company-dabbrev-code'.
    (defadvice! +company--abort-previous-a (&rest _)
      :before #'company-begin-backend
      (company-abort)))

  (add-hook 'after-change-major-mode-hook #'+company-init-backends-h 'append)


  ;; NOTE Fix #1335: ensure `company-emulation-alist' is the first item of
  ;;      `emulation-mode-map-alists', thus higher priority than keymaps of
  ;;      evil-mode. We raise the priority of company-mode keymaps
  ;;      unconditionally even when completion is not activated. This should not
  ;;      cause problems, because when completion is activated, the value of
  ;;      `company-emulation-alist' is ((t . company-my-keymap)), when
  ;;      completion is not activated, the value is ((t . nil)).
  (add-hook! 'evil-local-mode-hook
    (when (memq 'company-emulation-alist emulation-mode-map-alists)
      (company-ensure-emulation-alist)))

  ;; Fix #4355: allow eldoc to trigger after completions.
  (after! eldoc
    (eldoc-add-command 'company-complete-selection
                       'company-complete-common
                       'company-capf
                       'company-abort)))


;;
;;; Packages

(after! company-files
  ;; Fix `company-files' completion for org file:**** links
  (add-to-list 'company-files--regexps "file:\\(\\(?:\\.\\{1,2\\}/\\|~/\\|/\\)[^\]\n]**\\)"))


(use-package! company-box
  :when (modulep! +childframe)
  :hook (company-mode . company-box-mode)
  :config
  (setq company-box-show-single-candidate t
        company-box-backends-colors nil
        company-box-max-candidates 50
        company-box-icons-alist 'company-box-icons-all-the-icons
        ;; Move company-box-icons--elisp to the end, because it has a catch-all
        ;; clause that ruins icons from other backends in elisp buffers.
        company-box-icons-functions
        (cons #'+company-box-icons--elisp-fn
              (delq 'company-box-icons--elisp
                    company-box-icons-functions))
        company-box-icons-all-the-icons
        (let ((all-the-icons-scale-factor 0.8))
          `((Unknown       . ,(all-the-icons-material "find_in_page"             :face 'all-the-icons-purple))
            (Text          . ,(all-the-icons-material "text_fields"              :face 'all-the-icons-green))
            (Method        . ,(all-the-icons-material "functions"                :face 'all-the-icons-red))
            (Function      . ,(all-the-icons-material "functions"                :face 'all-the-icons-red))
            (Constructor   . ,(all-the-icons-material "functions"                :face 'all-the-icons-red))
            (Field         . ,(all-the-icons-material "functions"                :face 'all-the-icons-red))
            (Variable      . ,(all-the-icons-material "adjust"                   :face 'all-the-icons-blue))
            (Class         . ,(all-the-icons-material "class"                    :face 'all-the-icons-red))
            (Interface     . ,(all-the-icons-material "settings_input_component" :face 'all-the-icons-red))
            (Module        . ,(all-the-icons-material "view_module"              :face 'all-the-icons-red))
            (Property      . ,(all-the-icons-material "settings"                 :face 'all-the-icons-red))
            (Unit          . ,(all-the-icons-material "straighten"               :face 'all-the-icons-red))
            (Value         . ,(all-the-icons-material "filter_1"                 :face 'all-the-icons-red))
            (Enum          . ,(all-the-icons-material "plus_one"                 :face 'all-the-icons-red))
            (Keyword       . ,(all-the-icons-material "filter_center_focus"      :face 'all-the-icons-red))
            (Snippet       . ,(all-the-icons-material "short_text"               :face 'all-the-icons-red))
            (Color         . ,(all-the-icons-material "color_lens"               :face 'all-the-icons-red))
            (File          . ,(all-the-icons-material "insert_drive_file"        :face 'all-the-icons-red))
            (Reference     . ,(all-the-icons-material "collections_bookmark"     :face 'all-the-icons-red))
            (Folder        . ,(all-the-icons-material "folder"                   :face 'all-the-icons-red))
            (EnumMember    . ,(all-the-icons-material "people"                   :face 'all-the-icons-red))
            (Constant      . ,(all-the-icons-material "pause_circle_filled"      :face 'all-the-icons-red))
            (Struct        . ,(all-the-icons-material "streetview"               :face 'all-the-icons-red))
            (Event         . ,(all-the-icons-material "event"                    :face 'all-the-icons-red))
            (Operator      . ,(all-the-icons-material "control_point"            :face 'all-the-icons-red))
            (TypeParameter . ,(all-the-icons-material "class"                    :face 'all-the-icons-red))
            (Template      . ,(all-the-icons-material "short_text"               :face 'all-the-icons-green))
            (ElispFunction . ,(all-the-icons-material "functions"                :face 'all-the-icons-red))
            (ElispVariable . ,(all-the-icons-material "check_circle"             :face 'all-the-icons-blue))
            (ElispFeature  . ,(all-the-icons-material "stars"                    :face 'all-the-icons-orange))
            (ElispFace     . ,(all-the-icons-material "format_paint"             :face 'all-the-icons-pink)))))

  ;; HACK Fix oversized scrollbar in some odd cases
  ;; REVIEW `resize-mode' is deprecated and may stop working in the future.
  ;; TODO PR me upstream?
  (setq x-gtk-resize-child-frames 'resize-mode)

  ;; Disable tab-bar in company-box child frames
  ;; TODO PR me upstream!
  (add-to-list 'company-box-frame-parameters '(tab-bar-lines . 0))

  ;; Don't show documentation in echo area, because company-box displays its own
  ;; in a child frame.
  (delq! 'company-echo-metadata-frontend company-frontends)

  (defun +company-box-icons--elisp-fn (candidate)
    (when (derived-mode-p 'emacs-lisp-mode)
      (let ((sym (intern candidate)))
        (cond ((fboundp sym)  'ElispFunction)
              ((boundp sym)   'ElispVariable)
              ((featurep sym) 'ElispFeature)
              ((facep sym)    'ElispFace)))))

  ;; `company-box' performs insufficient frame-live-p checks. Any command that
  ;; "cleans up the session" will break company-box.
  ;; TODO Fix this upstream.
  (defadvice! +company-box-detect-deleted-frame-a (frame)
    :filter-return #'company-box--get-frame
    (if (frame-live-p frame) frame))
  (defadvice! +company-box-detect-deleted-doc-frame-a (_selection frame)
    :before #'company-box-doc
    (and company-box-doc-enable
         (frame-local-getq company-box-doc-frame frame)
         (not (frame-live-p (frame-local-getq company-box-doc-frame frame)))
         (frame-local-setq company-box-doc-frame nil frame))))


(use-package! company-dict
  :defer t
  :config
  (setq company-dict-dir (expand-file-name "dicts" doom-user-dir))
  (add-hook! 'doom-project-hook
    (defun +company-enable-project-dicts-h (mode &rest _)
      "Enable per-project dictionaries."
      (if (symbol-value mode)
          (add-to-list 'company-dict-minor-mode-list mode nil #'eq)
        (setq company-dict-minor-mode-list (delq mode company-dict-minor-mode-list))))))












;; Org mode file path completion

(after! org (set-company-backend! 'org-mode 'company-files 'company-capf))
(after! sh-script (set-company-backend! 'company-files ))
(after! cc-mode (set-company-backend! 'company-files 'company-capf))

(after! js2-mode
  (set-company-backend! 'js2-mode 'company-tide 'company-yasnippet 'company-files))

(after! sh-script
  (set-company-backend! 'sh-mode
    '(company-shell :with company-yasnippet 'company-files)))

(after! cc-mode
  (set-company-backend! 'c-mode
    '(:separate company-irony-c-headers company-irony 'company-files)))

;; gptel
;;
;;
;;
;;
;;
(use-package! gptel
 :config
 ;; (setq! gptel-api-key (shell-command-to-string "awk -F \"=\" \'{print $2}\' ~/.zshrc_private | head -n 1")))
 (setq! gptel-api-key "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"))

;; sudo-edit

(global-set-key (kbd "C-c C-r SPC-t-S") 'sudo-edit)
;; dired-toggle-sudo

(setq helm-follow-mode-persistent t)
;; (setq helm-follow-input-idle-delay 0.5)

(setq helm-ff-ignore-following-on-directory t)

;; (after! (solaire-mode demap)
  (setq demap-minimap-window-side  'right)
  (setq demap-minimap-window-width 15)
  (let ((gray1 "#1A1C22")
        (gray2 "#21242b")
        (gray3 "#282c34")
        (gray4 "#2b3038") )
    (face-spec-set 'demap-minimap-font-face
                   `((t :background ,gray2
                        :inherit    unspecified
                        :family     "minimap"
                        :height     10          )))
    (face-spec-set 'demap-visible-region-face
                   `((t :background ,gray4
                        :inherit    unspecified )))
    (face-spec-set 'demap-visible-region-inactive-face
                   `((t :background ,gray3
                        :inherit    unspecified )))
    (face-spec-set 'demap-current-line-face
                   `((t :background ,gray1
                        :inherit    unspecified )))
    (face-spec-set 'demap-current-line-inactive-face
                   `((t :background ,gray1
                        :inherit    unspecified ))))

;; (demap-open)

;; (add-hook 'buffer 'demap-open)
;; (add-hook 'kill-buffer-hook 'demap-close)

;; init.el -**- lexical-binding: t; -**-
