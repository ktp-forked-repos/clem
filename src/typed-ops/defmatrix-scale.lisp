
(in-package :clem)

(defgeneric mat-scale-range ( m q startr endr startc endc))
(defgeneric mat-scale (m q))
(defgeneric mat-scale-range! ( m q startr endr startc endc))
(defgeneric mat-scale! (m q))

(defmacro def-matrix-scale (type-1 accumulator-type &key suffix)
  (let ((element-type-1 (element-type (find-class `,type-1)))
	(accumulator-element-type (element-type (find-class `,accumulator-type))))
    `(progn
       (defmethod ,(ch-util:make-intern (concatenate 'string "mat-scale-range" suffix))
	   ((m ,type-1) q startr endr startc endc)
         (if (subtypep (type-of q) ',element-type-1)
             (let ((qconv (coerce q ',element-type-1)))
               (declare (type ,element-type-1 qconv))
               (destructuring-bind (mr mc) (dim m)
                 (let ((p (make-instance ',accumulator-type :rows mr :cols mc)))
                   (with-matrix-vals (m ,element-type-1 a)
                     (with-matrix-vals (p ,accumulator-element-type c)
                       (do ((i startr (1+ i)))
                           ((> i endr))
                         (declare (dynamic-extent i) (type fixnum i))
                         (do ((j startc (1+ j)))
                             ((> j endc))
                           (declare (dynamic-extent j) (type fixnum j))
                           (setf (aref c i j) (* (aref a i j) qconv))))))
                   p)))
             (destructuring-bind (mr mc) (dim m)
               (let ((p (make-instance ',accumulator-type :rows mr :cols mc)))
                 (with-matrix-vals (m ,element-type-1 a)
                   (do ((i startr (1+ i)))
                       ((> i endr))
                     (declare (dynamic-extent i) (type fixnum i))
                     (do ((j startc (1+ j)))
                         ((> j endc))
                       (declare (dynamic-extent j) (type fixnum j))
                       ,(if (subtypep element-type-1 'integer)
                            `(set-val-fit p i j (* (aref a i j) q) :truncate t)
                            `(set-val-fit p i j (* (aref a i j) q))))))
                 p))))
       
       (defmethod ,(ch-util:make-intern (concatenate 'string "mat-scale" suffix))
	   ((m ,type-1) q)
	 (destructuring-bind (mr mc) (dim m)
	   (,(ch-util:make-intern (concatenate 'string "mat-scale-range" suffix)) m q 0 (1- mr) 0 (1- mc)))))))

(defmacro def-matrix-scale-fit (type-1 accumulator-type &key suffix)
  (let ((element-type-1 (element-type (find-class `,type-1))))
    `(progn
       (defmethod ,(ch-util:make-intern (concatenate 'string "mat-scale-fit-range" suffix))
	   ((m ,type-1) q startr endr startc endc)
         (let ((qconv (coerce q ',element-type-1)))
           (declare (type ,element-type-1 qconv))
           (destructuring-bind (mr mc) (dim m)
             (let ((p (make-instance ',accumulator-type :rows mr :cols mc)))
               (with-matrix-vals (m ,element-type-1 a)
                 (do ((i startr (1+ i)))
                     ((> i endr))
                   (declare (dynamic-extent i) (type fixnum i))
                   (do ((j startc (1+ j)))
                       ((> j endc))
                     (declare (dynamic-extent j) (type fixnum j))
                     (set-val-fit p i j (* (aref a i j) qconv)))))
               p))))
       
       (defmethod ,(ch-util:make-intern (concatenate 'string "mat-scale-fit" suffix))
	   ((m ,type-1) q)
	 (destructuring-bind (mr mc) (dim m)
	   (,(ch-util:make-intern (concatenate 'string "mat-scale-fit-range" suffix)) m q 0 (1- mr) 0 (1- mc)))))))

(defmacro def-matrix-scale! (type-1 &key suffix)
  (let ((element-type-1 (element-type (find-class `,type-1))))
    `(progn
       (defmethod ,(ch-util:make-intern (concatenate 'string "mat-scale-range!" suffix))
	   ((m ,type-1) q startr endr startc endc)
         (if (subtypep (type-of q) ',element-type-1)
             (let ((qconv (coerce q ',element-type-1)))
               (declare (type ,element-type-1 qconv))
               (with-matrix-vals (m ,element-type-1 a)
                 (do ((i startr (1+ i)))
                     ((> i endr))
                   (declare (dynamic-extent i) (type fixnum i))
                   (do ((j startc (1+ j)))
                       ((> j endc))
                     (declare (dynamic-extent j) (type fixnum j))
                     (setf (aref a i j) (* (aref a i j) qconv))))))
             (with-matrix-vals (m ,element-type-1 a)
               (do ((i startr (1+ i)))
                   ((> i endr))
                 (declare (dynamic-extent i) (type fixnum i))
                 (do ((j startc (1+ j)))
                     ((> j endc))
                   (declare (dynamic-extent j) (type fixnum j))
                   (set-val-fit m i j ,(if (subtypep element-type-1 'integer)
                                           `(truncate (* (aref a i j) q))
                                           `(* (aref a i j) q)))))))
         m)
       
       (defmethod ,(ch-util:make-intern (concatenate 'string "mat-scale!" suffix))
	   ((m ,type-1) q)
	 (destructuring-bind (mr mc) (dim m)
	   (,(ch-util:make-intern (concatenate 'string "mat-scale-range!" suffix)) m q 0 (1- mr) 0 (1- mc)))))))

(defmacro def-matrix-scale-fit! (type-1 &key suffix)
  (let ((element-type-1 (element-type (find-class `,type-1))))
    `(progn
       (defmethod ,(ch-util:make-intern (concatenate 'string "mat-scale-range-fit!" suffix))
	   ((m ,type-1) q startr endr startc endc)
         (if (subtypep (type-of q) ',element-type-1)
             (let ((qconv (coerce q ',element-type-1)))
               (declare (type ,element-type-1 qconv))
               (with-matrix-vals (m ,element-type-1 a)
                 (do ((i startr (1+ i)))
                     ((> i endr))
                   (declare (dynamic-extent i) (type fixnum i))
                   (do ((j startc (1+ j)))
                       ((> j endc))
                     (declare (dynamic-extent j) (type fixnum j))
                     (set-val-fit m i j (* (aref a i j) qconv))))))
             (with-matrix-vals (m ,element-type-1 a)
               (do ((i startr (1+ i)))
                   ((> i endr))
                 (declare (dynamic-extent i) (type fixnum i))
                 (do ((j startc (1+ j)))
                     ((> j endc))
                   (declare (dynamic-extent j) (type fixnum j))
                   (set-val-fit m i j (* (aref a i j) q))))))
         m)
       
       (defmethod ,(ch-util:make-intern (concatenate 'string "mat-scale-fit!" suffix))
	   ((m ,type-1) q)
	 (destructuring-bind (mr mc) (dim m)
	   (,(ch-util:make-intern (concatenate 'string "mat-scale-range-fit!" suffix)) m q 0 (1- mr) 0 (1- mc)))))))


(macrolet ((frob (type-1 type-2 &key suffix)
	     `(progn
		(def-matrix-scale ,type-1 ,type-2 :suffix ,suffix)
                (def-matrix-scale-fit ,type-1 ,type-2 :suffix ,suffix)
		(def-matrix-scale! ,type-1 :suffix ,suffix)
                (def-matrix-scale-fit! ,type-1 :suffix ,suffix))))
  (frob double-float-matrix double-float-matrix)
  (frob single-float-matrix single-float-matrix)
  (frob ub8-matrix ub8-matrix)
  (frob ub16-matrix ub16-matrix)
  (frob ub32-matrix ub32-matrix)
  (frob sb8-matrix sb8-matrix)
  (frob sb16-matrix sb16-matrix)
  (frob sb32-matrix sb32-matrix)
  (frob bit-matrix bit-matrix)
  (frob fixnum-matrix fixnum-matrix)
  (frob real-matrix real-matrix)
  (frob integer-matrix integer-matrix)
  (frob complex-matrix complex-matrix)
  (frob t-matrix t-matrix))