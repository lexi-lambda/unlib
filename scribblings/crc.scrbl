#lang scribble/doc

@(require "base.rkt")

@title[#:tag "crc"]{CRC checksums}

@(define-eval crc-eval unlib/crc)

@defmodule[unlib/crc]{

@defproc[(crc32 [data bytes?]) natural?]{

Returns the IEEE 32-bit checksum of @scheme[data].

@examples[
  #:eval crc-eval
  (crc32 #"Hello world!")
  (crc32 #"Hello world.")]}

} @;{end defmodule}