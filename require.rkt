#lang scheme/base

(require (for-syntax scheme/base
                     scheme/path
                     scheme/provide-transform
                     scheme/require-transform
                     srfi/26
                     "profile.rkt"
                     "require-internal.rkt"
                     "syntax.rkt")
         scheme/require-syntax
         "profile.rkt"
         (for-template scheme/base))

(begin-for-syntax
  (define-timer alias-timer))

; (_ string)
(define-require-syntax directory-in
  (lambda (stx)
    (syntax-case stx ()
      [(_ dirname)
       (if (string? (syntax->datum #'dirname))
           (let ([path (path->complete-path (build-path (syntax->datum #'dirname)))])
             #`(combine-in #,@(map (lambda (path)
                                     #`(file #,(path->string path)))
                                   (filter scheme-source-path? 
                                           (map (cut build-path path <>)
                                                (directory-list path))))))
           (raise-syntax-error #f "directory name must be a string literal" stx #'dirname))])))

; (_ id relative-or-absolute-directory-string)
; (_ (id id) relative-or-absolute-directory-string)
(define-syntax (define-library-aliases stx)
  (syntax-case* stx (file planet) symbolic-identifier=?
    [(_ id clause kws ...)
     (identifier? #'id)
     (with-syntax ([id-in  (make-id #'id #'id '-in)]
                   [id-out (make-id #'id #'id '-out)])
       (syntax/loc stx
         (define-library-aliases (id-in id-out) clause kws ...)))]
    [(_ (id-in id-out) (file directory) kws ...)
     (and (identifier? #'id-in)
          (identifier? #'id-out)
          (string? (syntax->datum #'directory)))
     (quasisyntax/loc stx
       (begin
         (define-syntaxes (id-in id-out)
           (make-file-library-transformers directory))
         #,(if (memq '#:provide (syntax->datum #'(kws ...)))
               #'(provide id-in id-out)
               #'(begin))))]
    [(_ (id-in id-out) (planet spec) kws ...)
     (and (identifier? #'id-in)
          (identifier? #'id-out)
          (identifier? #'spec))
     (quasisyntax/loc stx
       (begin
         (define-syntaxes (id-in id-out)
           (make-planet-library-transformers 'spec))
         #,(if (memq '#:provide (syntax->datum #'(kws ...)))
               #'(provide id-in id-out)
               #'(begin))))]))

; Provide statements -----------------------------

(provide directory-in
         define-library-aliases)
