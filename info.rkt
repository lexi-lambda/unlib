#lang info

(define collection "unlib")

(define deps
  '("base"
    "compatibility-lib"
    "gregor-lib"
    "preprocessor"
    "rackunit-lib"
    "scheme-lib"
    "scribble-lib"
    "srfi-lib"
    "srfi-lite-lib"))
(define build-deps
  '("racket-doc"
    "srfi-doc"))

(define scribblings '(("scribblings/unlib.scrbl" (multi-page))))
