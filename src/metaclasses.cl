
(in-package :clem)

;;; Taken from KMR's clsql package
(defun remove-keyword-arg (arglist akey)
  (let ((mylist arglist)
	(newlist ()))
    (labels ((pop-arg (alist)
	       (let ((arg (pop alist))
		     (val (pop alist)))
		 (unless (equal arg akey)
		   (setf newlist (append (list arg val) newlist)))
		 (when alist (pop-arg alist)))))
      (pop-arg mylist))
    newlist))

;;; Also taken from KMR's clsql package
(declaim (inline delistify-dsd))
(defun delistify-dsd (list)
  "Some MOPs, like openmcl 0.14.2, cons attribute values in a list."
  (if (and (listp list) (null (cdr list)))
      (car list)
      list))

(defun fill-slot-from-ancestor (slot class)
  (let ((ancestor (find-if #'(lambda (anc)
			       (when (slot-exists-p anc slot)
				 (slot-boundp anc slot)))
			   (compute-class-precedence-list class))))
    (when ancestor
      (setf (slot-value class slot) (slot-value ancestor slot)))))

(defun fill-slots-from-ancestor (slots class &rest all-keys)
  (mapcar #'(lambda (x)
	      (unless (getf (car all-keys) x)
		(fill-slot-from-ancestor x class)))
	  slots))

(defclass standard-matrix-class (standard-class)
  ((element-type :accessor element-type :initarg :element-type)
   (specialized-array :accessor specialized-array-p :initarg :specialized-array)))

;;;
;;; Need validate-superclass for some reason. Read AMOP and fix this note
;;;
(defmethod validate-superclass ((c1 standard-matrix-class) (c2 standard-class))
  t)

(defun add-root-class (root-class direct-superclasses)
  (if (member root-class direct-superclasses)
      direct-superclasses
      (insert-before root-class
		     (car (class-direct-superclasses root-class))
		     direct-superclasses)))

(defmethod initialize-instance :around
    ((class standard-matrix-class) &rest all-keys &key direct-superclasses element-type &allow-other-keys)
  (let ((root-class (find-class 'typed-matrix))
	(mc (find-class 'standard-matrix-class)))
    (if (and root-class (not (equal class root-class)))
	(if (member-if #'(lambda (super)
			   (eq (class-of super) mc)) direct-superclasses)
	    (call-next-method)
	    (apply #'call-next-method class
		   :direct-superclasses
		   (add-root-class root-class direct-superclasses)
		   (remove-keyword-arg all-keys :direct-superclasses)))
	(call-next-method)))
  (fill-slots-from-ancestor '(:element-type :specialized-array) class all-keys))

(defmethod reinitialize-instance :around
    ((class standard-matrix-class) &rest all-keys &key direct-superclasses element-type &allow-other-keys)
  (let ((root-class (find-class 'typed-matrix))
	(mc (find-class 'standard-matrix-class)))
    (if (and root-class (not (equal class root-class)))
	(if (member-if #'(lambda (super)
			   (eq (class-of super) mc)) direct-superclasses)
	    (call-next-method)
	    (apply #'call-next-method class
		   :direct-superclasses
		   (add-root-class root-class direct-superclasses)
		   (remove-keyword-arg all-keys :direct-superclasses)))
	(call-next-method)))
  (fill-slots-from-ancestor '(:element-type :specialized-array) class all-keys))
