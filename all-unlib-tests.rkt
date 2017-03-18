#lang scheme/base

(require "bytes-test.rkt"
         "cache-test.rkt"
         "cache-internal-test.rkt"
         "convert-test.rkt"
         "contract-test.rkt"
         "crc-test.rkt"
         "debug-test.rkt"
         "enum-test.rkt"
         "enumeration-test.rkt"
         "exn-test.rkt"
         "file-test.rkt"
         "generator-test.rkt"
         "gen-test.rkt"
         "hash-table-test.rkt"
         "hash-test.rkt"
         "keyword-test.rkt"
         "lifebox-test.rkt"
         "list-test.rkt"
         "log-test.rkt"
         "match-test.rkt"
         "number-test.rkt"
         "pipeline-test.rkt"
         "preprocess-test.rkt"
         "project-test.rkt"
         "profile-test.rkt"
         "string-test.rkt"
         "symbol-test.rkt"
         "syntax-test.rkt"
         "test-base.rkt"
         "trace-test.rkt"
         "url-test.rkt"
         "yield-test.rkt")

; Tests ------------------------------------------

(define/provide-test-suite all-unlib-tests
  bytes-tests
  cache-tests
  cache-internal-tests
  contract-tests
  convert-tests
  crc-tests
  debug-tests
  enum-tests
  enumeration-tests
  exn-tests
  file-tests
  generator-tests
  gen-tests
  hash-table-tests
  hash-tests
  keyword-tests
  lifebox-tests
  list-tests
  log-tests
  match-tests
  number-tests
  pipeline-tests
  preprocess-tests
  profile-tests
  project-tests
  string-tests
  symbol-tests
  syntax-tests
  trace-tests
  url-tests
  yield-tests)