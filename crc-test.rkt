#lang scheme/base

(require "test-base.rkt")

(require "crc.rkt")

; Tests ------------------------------------------

; test-suite
(define/provide-test-suite crc-tests
  
  (test-case "crc32"
    (check-equal? (crc32 #"Hello world!") 461707669)
    (check-equal? (crc32 #"Hello world.") 2335835140)))
