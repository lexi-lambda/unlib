#lang scheme/base

(require "server-util.rkt")

(begin (make-data-directories)
       (copy-configuration-files)
       (make-groups)
       (update-permissions))
