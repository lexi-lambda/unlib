#lang scheme/base

(require "log.rkt"
         "test-base.rkt")

; Helpers ----------------------------------------

; log-receiver
(define test-receiver 
  (make-log-receiver (current-application-logger) 'debug))

; string time-utc string -> void
(define-check (check-message level-string timestamp expected)
  (match-define (vector level message continuation-marks topic)
    (sync test-receiver))
  (check-equal? message 
                (format "~a,~a,~a"
                        level-string
                        (format-log-timestamp timestamp)
                        expected)))

; (_ log-level time-utc string)
(define-shortcut (test-message level-string timestamp expected)
  (check-message level-string timestamp expected))

; Tests ------------------------------------------

(define/provide-test-suite log-tests
  
  (test-message "log-fatal*"
                "F"
                (log-fatal* "a" "b" "c" 1 2 3 #t #f)
                "\"a\",\"b\",\"c\",1,2,3,#t,#f")
  
  (test-message "log-error*"
                "E"
                (log-error* "a" "b" "c" 1 2 3 #t #f)
                "\"a\",\"b\",\"c\",1,2,3,#t,#f")
  
  (test-message "log-warning*"
                "W"
                (log-warning* "a" "b" "c" 1 2 3 #t #f)
                "\"a\",\"b\",\"c\",1,2,3,#t,#f")
  
  (test-message "log-info*"
                "I"
                (log-info* "a" "b" "c" 1 2 3 #t #f)
                "\"a\",\"b\",\"c\",1,2,3,#t,#f")
  
  (test-message "log-debug*"
                "D"
                (log-debug* "a" "b" "c" 1 2 3 #t #f)
                "\"a\",\"b\",\"c\",1,2,3,#t,#f"))
