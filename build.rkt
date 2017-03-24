#!/usr/bin/env mzscheme -q
#lang scheme

(require scheme/runtime-path
         scheme/system)

; Configuration ----------------------------------

; string
(define plt-version "4.2.2")

; path
(define-runtime-path planet-path "planet")

; Tasks ------------------------------------------

(define (env)
  (putenv "PLTVERSION" plt-version)
  (putenv "PLTPLANETDIR" (path->string planet-path)))

(define (autoplanet)
  (env)
  (system "mzscheme autoplanet.rkt"))

(define (envvars)
  (autoplanet)
  (let ([path (make-temporary-file "mzscheme-envvars-~a.sh")])
    (with-output-to-file path
      (lambda ()
        (printf #<<ENDSCRIPT
export PLTVERSION=~a
export PLTPLANETDIR="~a"

ENDSCRIPT
                plt-version
                (path->string planet-path)))
      #:exists 'replace)
    (display (path->string path))))

(define (compile)
  (autoplanet)
  (system "mzc -v run-tests.rkt"))

(define (test-compile)
  (autoplanet)
  (system "mzc -v run-tests.rkt"))

(define (test)
  (test-compile)
  (system "mzscheme run-tests.rkt"))

(define (docs)
  (autoplanet)
  (system "scribble ++xref-in setup/xref load-collections-xref --htmls scribblings/unlib.scrbl"))

(match (vector-ref (current-command-line-arguments) 0)
  ["envvars"         (envvars)]
  ["compile"         (compile)]
  ["test-compile"    (test-compile)]
  ["test"            (test)]
  ["docs"            (docs)])
