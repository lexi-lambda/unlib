#lang scheme/base

(require "base.rkt")

(require preprocessor/mzpp)

; Procedures -----------------------------------

; (U string port) (alistof symbol any) -> string
(define (apply-template template bindings)
  (let ((op (open-output-string)))
    (parameterize ([current-output-port op]
                   [current-namespace (make-base-namespace)])
      (namespace-require '(lib "mzpp.rkt" "preprocessor"))
      (for-each
       (lambda (cell)
         (let ((key (car cell))
               (val (cdr cell)))
           (eval `(define ,key ,val))))
       bindings)
      (eval `(preprocess ,template)))
    (get-output-string op)))

; Provide statements --------------------------- 

(provide apply-template)
