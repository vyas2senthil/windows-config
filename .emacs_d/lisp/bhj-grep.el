(defun grep-shell-quote-argument (argument)
  "Quote ARGUMENT for passing as argument to an inferior shell."
  (cond
   ((and (boundp 'no-grep-quote)
         no-grep-quote)
    (format "\"%s\"" argument))
   ((equal argument "")
    "\"\"")
   (t
    ;; Quote everything except POSIX filename characters.
    ;; This should be safe enough even for really weird shells.
    (let ((result "") (start 0) end)
      (while (string-match "[].*[^$\"\\]" argument start)
        (setq end (match-beginning 0)
              result (concat result (substring argument start end)
                             (let ((char (aref argument end)))
                               (cond
                                ((eq ?$ char)
                                 "\\\\\\")
                                ((eq ?\\  char)
                                 "\\\\\\")
                                (t
                                 "\\"))) (substring argument end (1+ end)))
              start (1+ end)))
      (concat "\"" result (substring argument start) "\"")))))

(defun grep-default-command ()
  "Compute the default grep command for C-u M-x grep to offer."
  (let ((tag-default (grep-shell-quote-argument (grep-tag-default)))
        ;; This a regexp to match single shell arguments.
        ;; Could someone please add comments explaining it?
        (sh-arg-re "\\(\\(?:\"\\(?:\\\\\"\\|[^\"]\\)+\"\\|'[^']+'\\|\\(?:\\\\.\\|[^\"' \\|><\t\n]\\)\\)+\\)")

        (grep-default (or (car grep-history) my-grep-command)))
    ;; In the default command, find the arg that specifies the pattern.
    (when (or (string-match
               (concat "[^ ]+\\s +\\(?:-[^ ]+\\s +\\)*"
                       sh-arg-re "\\(\\s +\\(\\S +\\)\\)?")
               grep-default)
              ;; If the string is not yet complete.
              (string-match "\\(\\)\\'" grep-default))
      ;; Maybe we will replace the pattern with the default tag.
      ;; But first, maybe replace the file name pattern.

      ;; Now replace the pattern with the default tag.
      (replace-match tag-default t t grep-default 1))))

(autoload 'nodup-ring-insert "bhj-defines")
;;;###autoload
(defun bhj-edit-grep-pattern ()
  (interactive)
  (beginning-of-line)
  (let ((min (progn
               (search-forward "\"" nil t)
               (point)))
        (max (progn
               (search-forward "\"" nil t)
               (backward-char)
               (point))))
    (undo-boundary)
    (when (< min max)
      (delete-region min max))))

;;;###autoload
(defun grep-bhj-dir ()
  (interactive)
  (let ((default-directory
          (if (boundp 'bhj-grep-dir)
              bhj-grep-dir
            default-directory)))
    (call-interactively 'grep)))

;;;###autoload
(defun grep-imenu ()
  (interactive)
  (let ((grep-gtags-history grep-imenu-history)
        (grep-buffer-name "*grep-imenu*"))
    (grep-gtags 'grep-imenu-history "grep-imenu -i -e pat")))

;;;###autoload
(defun grep-gtags (&optional history-var def-grep-command)
  (interactive)
  (let ((grep-history grep-gtags-history)
        (no-grep-quote t)
        (compilation-buffer-name-function (lambda (_ign) (if (boundp 'grep-buffer-name)
                                                             grep-buffer-name
                                                           "*grep-gtags*")))
        (my-grep-command (or def-grep-command "grep-gtags -e pat"))
        (current-prefix-arg 4))
    (nodup-ring-insert cscope-marker-ring (point-marker))
    (set-gtags-start-file)
    (call-interactively 'grep-bhj-dir)
    (set (or history-var 'grep-gtags-history) grep-history)))

(defun grep-tag-default-path ()
  (or (and transient-mark-mode mark-active
           (/= (point) (mark))
           (buffer-substring-no-properties (point) (mark)))
      (save-excursion
        (let* ((re "[^-a-zA-Z0-9._/]")
               (p1 (progn (search-backward-regexp re)
                          (if (looking-at "(")
                              (progn
                                (search-backward-regexp "\\." (line-beginning-position))
                                (prog1
                                    (1+ (point))
                                  (search-forward-regexp "(")))
                            (1+ (point)))))
               (p2 (progn (forward-char)
                          (search-forward-regexp re)
                          (backward-char)
                          (if (looking-at ":[0-9]+")
                              (progn
                                (forward-char)
                                (search-forward-regexp "[^0-9]")
                                (1- (point)))
                            (point)))))
          (buffer-substring-no-properties p1 p2)))))

;;;###autoload
(defun grep-find-file ()
  (interactive)
  (let ((grep-history grep-find-file-history)
        (my-grep-command "beagrep -f -e pat")
        (compilation-buffer-name-function (lambda (_ign) "*grep-find-file*"))
        (current-prefix-arg 4))
    (flet ((grep-tag-default () (grep-tag-default-path)))
      (nodup-ring-insert cscope-marker-ring (point-marker))
      (call-interactively 'grep-bhj-dir)
      (setq grep-find-file-history grep-history))))

;;;###autoload
(defun grep-func-call ()
  (interactive)
  (let ((grep-history grep-func-call-history)
        (my-grep-command "grep-func-call -e pat")
        (compilation-buffer-name-function (lambda (_ign) "*grep-func-call*"))
        (current-prefix-arg 4))
    (nodup-ring-insert cscope-marker-ring (point-marker))
    (let ((file (my-buffer-file-name (current-buffer)))
          (mode-name-minus-mode
           (replace-regexp-in-string "-mode$" "" (symbol-name major-mode))))
      (if (file-remote-p file)
          (let ((process-environment tramp-remote-process-environment))
            (setenv "GTAGS_START_FILE" (file-remote-p file 'localname))
            (setenv "GTAGS_LANG_FORCE" (or (cdr (assoc mode-name-minus-mode emacs-mode-ctags-lang-map))
                                           mode-name-minus-mode))
            (setq tramp-remote-process-environment process-environment))
        (setenv "GTAGS_START_FILE" file)
        (setenv "GTAGS_LANG_FORCE" (or (cdr (assoc mode-name-minus-mode emacs-mode-ctags-lang-map))
                                       mode-name-minus-mode))))
    (call-interactively 'grep-bhj-dir)
    (setq grep-func-call-history grep-history)))

(provide 'bhj-grep)
