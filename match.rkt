#lang scheme/base

(require "base.rkt")

(require (for-syntax scheme/base
                     syntax/parse)
         scheme/match
         srfi/26
         "debug.rkt")

; Match expanders --------------------------------

(begin-for-syntax
  (define (redirect-transformer id-stx)
    (syntax-parser
      [_:id id-stx]
      [(_ . rest) #`(#,id-stx . rest)])))

; (_ expr pattern ...)
(define-match-expander match:eq?
  (lambda (stx)
    (syntax-case stx ()
      [(_ expr pattern ...)
       #'(? (cut eq? <> expr) pattern ...)]))
  (redirect-transformer #'eq?))

; (_ expr pattern ...)
(define-match-expander match:equal?
  (lambda (stx)
    (syntax-case stx ()
      [(_ expr pattern ...)
       #'(? (cut equal? <> expr) pattern ...)]))
  (redirect-transformer #'equal?))

; (_ proc pattern ...)
(define-match-expander app*
  (syntax-rules ()
    [(_ expr pattern)
     (app expr pattern)]
    [(_ expr pattern ...)
     (app (lambda (val)
            (call-with-values (cut expr val) list))
          (list pattern ...))]))

; Provide statements -----------------------------

(provide (rename-out [match:eq?    eq?]
                     [match:equal? equal?])
         app*)
