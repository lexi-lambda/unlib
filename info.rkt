#lang info

(define scribblings '(("scribblings/unlib.scrbl" (multi-page))))

(define collection "unlib")

(define deps
  '())
(define build-deps
  '())

(define compile-omit-paths
  '("autoplanet.rkt"
    "build.rkt"
    "planet"
    "planetdev"))
