#lang scheme/base

(require "all-unlib-tests.rkt"
         "test-base.rkt")

(print-struct #t)
(error-print-width 1024)

(run-tests all-unlib-tests)
