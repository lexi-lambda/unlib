#lang scheme/base

(require "base.rkt"
         "number.rkt")

; Contracts ------------------------------------

; natural -> contract
(define (arity/c arity)
  (flat-named-contract
   (format "procedure-with-arity-~a/c" arity)
   (lambda (item)
     (and (procedure? item)
          (procedure-arity-includes? item arity #t)))))

; Provide statements --------------------------- 

(provide/contract
 [arity/c (-> natural? flat-contract?)])
