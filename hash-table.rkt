#lang mzscheme

(require "base.rkt"
         "list.rkt")

; pair ... -> hash-table
(define (make-hash-table/pairs . pairs)
  (let ([table (make-hash-table)])
    (alist-for-each 
     (lambda (key value)
       (hash-table-put! table key value))
     pairs)
    table))

; hash-table any -> boolean
(define (hash-table-mapped? table key)
  (let/ec escape
    (hash-table-get table key (cut escape #f))
    #t))

; hash-table -> (listof any)
(define (hash-table-keys table)
  (hash-table-map table (lambda (k v) k)))

; hash-table -> (listof any)
(define (hash-table-values table)
  (hash-table-map table (lambda (k v) v)))

; Provide statements -----------------------------

(provide/contract
 [make-hash-table/pairs (->* () () #:rest (listof pair?) hash-table?)]
 [hash-table-mapped?    (-> hash-table? any/c boolean?)]
 [hash-table-keys       (-> hash-table? (or/c pair? null?))]
 [hash-table-values     (-> hash-table? (or/c pair? null?))])
