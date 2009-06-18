#lang scheme/base

(require (for-syntax scheme/base
                     "enumeration-info.ss"
                     "syntax.ss")
         scheme/provide-syntax
         scheme/string
         "base.ss"
         "exn.ss")

; Structure types --------------------------------

; (struct symbol (listof symbol) (listof string))
(define-struct enum (name values pretty-values) #:transparent)

; Accessors and mutators -------------------------

; enum -> string
(define (enum->string enum [separator ", "])
  (string-join (map enum-value->string (enum-values enum)) separator))

; enum -> string
(define (enum->pretty-string enum [separator ", "])
  (string-join (enum-pretty-values enum) separator))

; enum any -> boolean
(define (enum-value? enum value)
  (and (memq value (enum-values enum)) #t))

; enum any -> boolean
(define (enum-value+false? enum value)
  (or (not value) (enum-value? enum value)))

; enum any [(U any (-> any))] -> (U string #f)
(define (enum-prettify
         enum
         value
         [default (cut raise-type-error
                       'enum-prettify
                       (format "(U ~a)" (enum->string enum " "))
                       value)])
  (or (for/or ([val (enum-values enum)] [str (enum-pretty-values enum)])
        (and (eq? val value) str))
      (if (procedure? default)
          (default)
          default)))

; Syntax -----------------------------------------

; (_ id (value-clause ...) keyword-arg ...)
(define-syntax (define-enum complete-stx)
  
  (define id-stx #f)          ; (U syntax #f)
  (define value-id-stxs null) ; (listof syntax)
  (define value-stxs null)    ; (listof syntax)
  (define pretty-stxs null)   ; (listof syntax)
  
  ; syntax syntax -> void
  (define (parse-values stx)
    (syntax-case stx ()
      [() (parse-finish)]
      [([id val str] other ...)
       (identifier? #'id)
       (begin (set! value-id-stxs (cons #'id value-id-stxs))
              (set! value-stxs    (cons #'val value-stxs))
              (set! pretty-stxs   (cons #'str pretty-stxs))
              (parse-values #'(other ...)))]
      [([id str] other ...)
       (parse-values #'([id 'id str] other ...))]
      [([id] other ...)
       (with-syntax ([str (format "~a" (syntax->datum #'id))])
         (parse-values #'([id 'id str] other ...)))]
      [(id other ...)
       (parse-values #'([id] other ...))]))
  
  (define (parse-finish)
    (with-syntax ([id             id-stx]
                  [private-id     (make-id #f id-stx)]
                  [(value-id ...) (reverse value-id-stxs)]
                  [(value ...)    (reverse value-stxs)]
                  [(pretty ...)   (reverse pretty-stxs)])
      #'(begin
          (define private-id
            (make-enum
             'id
             (list value ...)
             (list pretty ...)))
          
          (define-syntaxes (id)
            (let ([certify (syntax-local-certifier #t)])
              (enum-info-add!
               (make-enum-info
                (certify #'id)
                (certify #'private-id)
                (list (certify #'value-id) ...)
                (list (certify #'value) ...))))))))
  
  (syntax-case complete-stx ()
    [(_ id (value ...))
     (identifier? #'id)
     (begin (set! id-stx #'id)
            (parse-values #'(value ...)))]))

(define-syntax (enum-list stx)
  (syntax-case stx ()
    [(_ enum-id val-id ...)
     (andmap identifier? (syntax->list #'(enum-id val-id ...)))
     (syntax/loc stx
       (list (enum-id val-id) ...))]))

; Helpers ----------------------------------------

; (U boolean symbol integer) -> string
(define (enum-value->string val)
  (cond [(boolean? val) (if val "yes" "no")]
        [(symbol? val)  (symbol->string val)]
        [(integer? val) (number->string val)]))

; Provide statements -----------------------------

(provide define-enum
         enum-list)

(provide/contract
 [struct enum ([name          symbol?]
               [values        list?]
               [pretty-values (listof string?)])]
 [enum->string        (->* (enum?) (string?) string?)]
 [enum->pretty-string (->* (enum?) (string?) string?)]
 [enum-value?         (-> enum? any/c boolean?)]
 [enum-value+false?   (-> enum? any/c boolean?)]
 [enum-prettify       (->* (enum? any/c) ((or/c string? (-> string?))) string?)])