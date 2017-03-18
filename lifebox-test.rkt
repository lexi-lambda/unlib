#lang scheme/base

(require "lifebox.rkt"
         "test-base.rkt")

; Tests ------------------------------------------

(define/provide-test-suite lifebox-tests
  
  (test-case "lifebox-expired?"
    (check-pred lifebox-expired? (make-lifebox 0 'hi))
    (check-false (lifebox-expired? (make-lifebox (+ (current-seconds) 100) 'hi)))
    (check-true  (lifebox-expired? (make-lifebox 100 'hi) 100))
    (check-false (lifebox-expired? (make-lifebox 100 'hi) 99))))
