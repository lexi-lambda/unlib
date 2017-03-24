#lang scheme/base

(require scheme/file
         (except-in srfi/1 any)
         "file.rkt"
         "test-base.rkt")

; Test data --------------------------------------

(define mdt-top1 "make-directory-tree-test-data-1")
(define mdt-top2 "make-directory-tree-test-data-2")

(define mdt-dir1 "directory1")
(define mdt-dir2 "directory2")
(define mdt-dir3 "directory3")
(define mdt-dirs (list mdt-dir1 mdt-dir2 mdt-dir3))

(define mdt-sub1 "subdirectory1")
(define mdt-sub2 "subdirectory2")
(define mdt-sub3 "subdirectory3")
(define mdt-subs (list mdt-sub1 mdt-sub2 mdt-sub3))

(define mdt-tree
  (list mdt-top1
        (append-map (lambda (dir)
                      (list dir mdt-subs))
                    mdt-dirs)
        mdt-top2
        (append-map (lambda (dir)
                      (list dir mdt-subs))
                    mdt-dirs)))

(define mdt-all
  (append-map
   (lambda (dir)
     (map (lambda (sub)
            (format "~a/~a/~a" mdt-top1 dir sub))
          mdt-subs))
   mdt-dirs))

; -> void
(define (delete-mdt-files)
  (when (directory-exists? mdt-top1) (delete-directory/files mdt-top1))
  (when (directory-exists? mdt-top2) (delete-directory/files mdt-top2)))

(define mncf-top   "make-non-conflicting-filename-test-data")
(define mncf-file1 "file-with-extension.ext")
(define mncf-file2 "file-with-extension1.ext")
(define mncf-file3 "file-with-extension2.ext")
(define mncf-file4 "file-without-extension")
(define mncf-file5 "file-without-extension1")
(define mncf-file6 "file-without-extension2")
(define mncf-file7 "file-with-two.extensions.ext")

; create-mncf-files : -> void
(define (create-mncf-files)
  (delete-mncf-files)
  (make-directory mncf-top)
  (touch (build-path mncf-top mncf-file1))
  (touch (build-path mncf-top mncf-file2))
  (touch (build-path mncf-top mncf-file3))
  (touch (build-path mncf-top mncf-file4))
  (touch (build-path mncf-top mncf-file5))
  (touch (build-path mncf-top mncf-file6))
  (touch (build-path mncf-top mncf-file7)))

; -> void
(define (delete-mncf-files)
  (when (directory-exists? mncf-top) (delete-directory/files mncf-top)))

(define cf-top   "concatenate-files-test-data")
(define cf-file1 "file1.txt")
(define cf-file2 "file2.txt")
(define cf-file3 "file3.txt")
(define cf-cat   "file123.txt")

; -> void
(define (create-cf-files)
  (delete-cf-files)
  (make-directory cf-top)
  (touch (build-path cf-top cf-file1) cf-file1)  ; File contains the text "file1.txt"
  (touch (build-path cf-top cf-file2) cf-file2)  ; File contains the text "file2.txt"
  (touch (build-path cf-top cf-file3) cf-file3)) ; File contains the text "file3.txt"

; -> void
(define (delete-cf-files)
  (when (directory-exists? cf-top) (delete-directory/files cf-top)))

; Tests ------------------------------------------

(define/provide-test-suite file-tests
  
  (test-case "path-contains?"
    (check-true  (path-contains? (build-path "/a/b/c")   (build-path "/a/b/c/d")))
    (check-false (path-contains? (build-path "/a/b/c/d") (build-path "/a/b/c")))
    (check-true  (path-contains? (build-path "/a/b/c")   (build-path "/a/b/c")))
    (check-true  (path-contains? (build-path "/a/b/c")   (build-path "/a/b/c/d/../e")))
    (check-false (path-contains? (build-path "/a/b/c")   (build-path "/a/b/c/d/../../d")))
    (check-true  (path-contains? (build-path "/a/b/c")   (build-path "/a/b/c/d/../../c/d"))))
  
  (test-suite "make-directory-tree"
    
    #:before delete-mdt-files
    #:after  delete-mdt-files
    
    (test-case "create single directory"
      (check-false (directory-exists? mdt-top1))
      (make-directory-tree mdt-top1)
      (check-true (directory-exists? mdt-top1))
      (delete-directory mdt-top1))
    
    (test-case "create peer directories"
      (check-false (directory-exists? mdt-top1))
      (check-false (directory-exists? mdt-top2))
      (make-directory-tree (list mdt-top1 mdt-top2))
      (check-true (directory-exists? mdt-top1))
      (check-true (directory-exists? mdt-top2))
      (delete-directory mdt-top1)
      (delete-directory mdt-top2))
    
    (test-case "create parent/child directories"
      (check-false (directory-exists? mdt-top1))
      (check-false (directory-exists? mdt-top2))
      (make-directory-tree (list mdt-top1 (list mdt-top2)))
      (check-true (directory-exists? mdt-top1))
      (check-true (directory-exists? (build-path mdt-top1 mdt-top2)))
      (check-false (directory-exists? mdt-top2))
      (delete-directory/files mdt-top1))
    
    (test-case "create tree of directories"
      (check-false (directory-exists? mdt-top1))
      (make-directory-tree mdt-tree)
      (map check-true (map directory-exists? mdt-all) mdt-all)))
  
  (test-suite "make-non-conflicting-[filename/path]" 
    
    #:before create-mncf-files
    #:after  delete-mncf-files
    
    (test-equal? "make-non-conflicting-filename works when there are no conflicts"
      (make-non-conflicting-filename mncf-top "non-conflicting-filename.ext")
      "non-conflicting-filename.ext")
    
    (test-equal? "filename with extension"
      (make-non-conflicting-filename mncf-top mncf-file1)
      "file-with-extension3.ext")
    
    (test-equal? "filename with no extension"
      (make-non-conflicting-filename mncf-top mncf-file4)
      "file-without-extension3")
    
    (test-equal? "filename with two extensions"
      (make-non-conflicting-filename mncf-top mncf-file7)
      "file-with-two.extensions1.ext")
    
    (test-equal? "filename with an index"
      (make-non-conflicting-filename mncf-top mncf-file2)
      "file-with-extension3.ext")
    
    (test-equal? "make-non-conflicting-path"
      (make-non-conflicting-path mncf-top mncf-file1)
      (build-path mncf-top "file-with-extension3.ext")))
  
  (test-suite "read-file->string"
    
    #:before create-cf-files
    
    (test-case "works as expected"
      (check-equal? (read-file->string (build-path cf-top cf-file1)) cf-file1)
      (check-equal? (read-file->string (build-path cf-top cf-file2)) cf-file2)
      (check-equal? (read-file->string (build-path cf-top cf-file3)) cf-file3))
    
    (test-exn "exn when file missing"
      exn:fail:filesystem?
      (cut read-file->string (build-path cf-top cf-cat))))
  
  (test-suite "concatenate-files"
    
    #:after delete-cf-files
    
    (test-case "works as expected"
      (check-equal? (read-file->string (build-path cf-top cf-file1)) cf-file1)
      (check-equal? (read-file->string (build-path cf-top cf-file2)) cf-file2)
      (check-equal? (read-file->string (build-path cf-top cf-file3)) cf-file3)
      (concatenate-files (build-path cf-top cf-cat)
                         (list (build-path cf-top cf-file1)
                               (build-path cf-top cf-file2)
                               (build-path cf-top cf-file3)))
      (check-equal? (read-file->string (build-path cf-top cf-cat)) (string-append cf-file1 cf-file2 cf-file3))))
  
  (test-suite "directory-tree and in-directory"
    
    #:before (lambda ()
               (when (directory-exists? "dtt")
                 (delete-directory/files "dtt"))
               (make-directory-tree '("dtt" ("a" ("b.txt" "c.png") "d" ("e.txt" "f.png")))))
    #:after (lambda ()
              (when (directory-exists? "dtt")
                (delete-directory/files "dtt")))
    
    (test-case "directory-tree"
      (check-equal? (map path->string (directory-tree "dtt"))
                    (list "dtt" "dtt/a" "dtt/a/b.txt" "dtt/a/c.png" "dtt/d" "dtt/d/e.txt" "dtt/d/f.png"))
      (check-equal? (map path->string (directory-tree "dtt" #:order 'post))
                    (list "dtt/a/b.txt" "dtt/a/c.png" "dtt/a" "dtt/d/e.txt" "dtt/d/f.png" "dtt/d" "dtt"))
      (check-equal? (map path->string 
                         (directory-tree
                          "dtt" 
                          #:filter (lambda (path) (and (regexp-match #px"txt$" (path->string path)) #t))))
                    (list "dtt/a/b.txt"
                          "dtt/d/e.txt")))
    
    (test-case "in-directory"
      (check-equal? (for/list ([path (in-directory "dtt")])
                      (path->string path))
                    (list "dtt" "dtt/a" "dtt/a/b.txt" "dtt/a/c.png" "dtt/d" "dtt/d/e.txt" "dtt/d/f.png"))
      (check-equal? (for/list ([path (in-directory "dtt" #:order 'post)])
                      (path->string path))
                    (list "dtt/a/b.txt" "dtt/a/c.png" "dtt/a" "dtt/d/e.txt" "dtt/d/f.png" "dtt/d" "dtt"))
      (check-equal? (for/list ([path (in-directory
                                      "dtt"
                                      #:filter (lambda (path)
                                                 (and (regexp-match #px"txt$" (path->string path)) #t)))])
                      (path->string path))
                    (list "dtt/a/b.txt" "dtt/d/e.txt")))
    
    (test-case "prettify-file-size"
      (check-equal? (prettify-file-size 0)                            "0 bytes")
      (check-equal? (prettify-file-size 1)                            "1 byte")
      (check-equal? (prettify-file-size 2)                            "2 bytes")
      (check-equal? (prettify-file-size 512)                          "512 bytes")
      (check-equal? (prettify-file-size 1000)                         "0.9 KB")
      (check-equal? (prettify-file-size 1024)                         "1 KB")
      (check-equal? (prettify-file-size 1950)                         "1.9 KB")
      (check-equal? (prettify-file-size 19500)                        "19 KB")
      (check-equal? (prettify-file-size (* 1024 512))                 "512 KB")
      (check-equal? (prettify-file-size (* 1024 1000))                "0.9 MB")
      (check-equal? (prettify-file-size (* 1024 1024))                "1 MB")
      (check-equal? (prettify-file-size (* 1024 1024 1000))           "0.9 GB")
      (check-equal? (prettify-file-size (* 1024 1024 1024))           "1 GB")
      (check-equal? (prettify-file-size (* 1024 1024 1024 1000))      "0.9 TB")
      (check-equal? (prettify-file-size (* 1024 1024 1024 1024))      "1 TB")
      (check-equal? (prettify-file-size (* 1024 1024 1024 1024 1000)) "1000 TB")
      (check-equal? (prettify-file-size (* 1024 1024 1024 1024 1024)) "1024 TB"))))

; Helpers ----------------------------------------

; path -> void
;
; Used in tests for make-non-conflicting-filename.
(define (touch path [content #f])
  (unless (file-exists? path)
    (with-output-to-file path
      (cut display (if content content "Temporary file: feel free to delete.")))))
