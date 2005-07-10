
(defpackage #:clem-system (:use #:asdf #:cl))
(in-package #:clem-system)

;;;;
;;;; The following section customizes asdf to work with filenames
;;;; with a .cl extension and to put fasl files in a separate
;;;; directory.
;;;;
;;;; To enable this behvior, use asdf component type
;;;;  :clem-cl-source-file
;;;;
(defclass clem-cl-source-file (cl-source-file) ())

(defmethod source-file-type ((c clem-cl-source-file) (s module)) "cl")

(defparameter *fasl-directory*
  (make-pathname :directory '(:relative #+sbcl "sbcl-fasl"
			      #+openmcl "openmcl-fasl"
			      #-(or sbcl openmcl) "fasl")))

(defmethod asdf::output-files ((operation compile-op) (c clem-cl-source-file))
  (list (merge-pathnames *fasl-directory*
			 (compile-file-pathname (component-pathname c)))))

(defsystem :clem
  :name "clem"
  :author "Cyrus Harmon <ch-lisp@bobobeach.com>"
  :version "0.1.1-20050701"
  :licence "BSD"
  :components
  ((:module
    :src
    :components
    ((:clem-cl-source-file "defpackage")
     (:clem-cl-source-file "metaclasses" :depends-on ("defpackage"))
     (:clem-cl-source-file "matrix" :depends-on ("defpackage" "metaclasses"))
     (:clem-cl-source-file "typed-matrix" :depends-on ("defpackage" "matrix"))
     (:clem-cl-source-file "defmatrix" :depends-on ("typed-matrix"))
     (:clem-cl-source-file "defmatrix-types" :depends-on ("defmatrix"))
     (:clem-cl-source-file "typed-matrix-utils" :depends-on ("typed-matrix"))
     (:clem-cl-source-file "row-vector" :depends-on ("matrix"))
     (:clem-cl-source-file "col-vector" :depends-on ("matrix"))
     (:clem-cl-source-file "scalar" :depends-on ("matrix"))
     (:clem-cl-source-file "matrixops" :depends-on ("typed-matrix-utils"))
     (:clem-cl-source-file "transform" :depends-on ("matrix" "defmatrix-types"))
     (:module
      :typed-ops
      :components
      ((:clem-cl-source-file "defmatrix-mref")
       (:clem-cl-source-file "defmatrix-move-add-subtr")
       (:clem-cl-source-file "defmatrix-scale")
       (:clem-cl-source-file "defmatrix-hprod")
       (:clem-cl-source-file "defmatrix-mult")
       (:clem-cl-source-file "defmatrix-mult-block")
       (:clem-cl-source-file "defmatrix-transform"))
      :depends-on ("defmatrix-types"))))
   (:static-file "Makefile")))

