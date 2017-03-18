#lang mzscheme

(require mzlib/kw
         srfi/13/string
         "base.rkt"
         (only "string.rkt"
               string+false?
               ensure-string))

; (listof string) string [#:prefix string] [#:suffix string] -> string
(define/kw (string-delimit items delimiter #:key [prefix #f] [suffix #f])
    (let ([delimited (string-join items delimiter)])
      (if prefix
          (if suffix
              (string-append prefix delimited suffix)
              (string-append prefix delimited))
          (if suffix
              (string-append delimited suffix)
              delimited))))

; Provide statements ---------------------------

(provide string+false?
         ensure-string
         string-delimit)
