;;;; quicklisp-asdf-helper.lisp

(defpackage #:quicklisp-asdf-helper
  (:use #:cl)
  (:local-nicknames (#:a #:alexandria)))

(in-package #:quicklisp-asdf-helper)

(defun init-file-name ()
  #p
  #+allegro                 ".clinit.cl"
  #+abcl                    ".abclrc"
  #+(and ccl windows)       "ccl-init.lisp"
  #+(and ccl (not windows)) ".ccl-init.lisp"
  #+clasp                   ".clasprc"
  #+clisp                   ".clisprc.lisp"
  #+cmucl                   ".cmucl-init.lisp"
  #+ecl                     ".eclrc"
  #+mezzano                 "init.lisp"
  #+mkcl                    ".mkclrc"
  #+lispworks               ".lispworks"
  #+sbcl                    ".sbclrc"
  #+scl                     ".scl-init.lisp")

(defun init-file-pathname ()
  ;; Are we running on Roswell?
  (if (find-package '#:roswell)
      ;; We are - return the Roswell init file.
      (let ((homedir (funcall (find-symbol (symbol-name '#:homedir)
                                           (find-package '#:roswell.util)))))
        (merge-pathnames #p"init.lisp" homedir))
      ;; We aren't - fall back to implementation-specific filenames.
      (merge-pathnames (init-file-name) (user-homedir-pathname))))

(defparameter *section-beginning*
  (format nil "~%;;; Begin QUICKLISP-ASDF-HELPER section~%"))
(defparameter *section-end*
  (format nil "~%;;; End QUICKLISP-ASDF-HELPER section~%"))

(defun find-section (string)
  (a:when-let ((start (search *section-beginning* string))
               (end (search *section-end* string :from-end t)))
    (values start (+ end (length *end*)))))

(defun remove-section (string)
  (multiple-value-bind (start end) (find-section string)
    (let ((before (subseq string 0 start))
          (after (subseq string end (length string))))
      (concatenate 'string before after))))

(defun make-section (source-pathname compiled-pathname)
  (let ((*print-case* :downcase))
    (format nil "~A~%~S~%~A"
            *section-beginning*
            `(or (load ,compiled-pathname :if-does-not-exist nil)
                 (load ,source-pathname))
            *section-end*)))

#|

QUICKLISP-ASDF-HELPER> (make-section #p"/tmp/foo.lisp" #p"/tmp/foo.fasl")
"
;;; Begin QUICKLISP-ASDF-HELPER section

(or (load #P\"/tmp/foo.fasl\" :if-does-not-exist nil) (load #P\"/tmp/foo.lisp\"))

;;; End QUICKLISP-ASDF-HELPER section
"




QUICKLISP-ASDF-HELPER> (remove-section "foo ba baz quux
ksjdhfkjsdfh

;;; Begin QUICKLISP-ASDF-HELPER section

sdkfjlsfjkdf

;;; End QUICKLISP-ASDF-HELPER section
")
"foo ba baz quux
ksjdhfkjsdfh
"

|#
