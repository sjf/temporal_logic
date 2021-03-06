(module utils
  (export 
    (identity x)
    (first l)
    (second l)
    (third l)
    (member? i l)
    (compose f1 f2)
    (reduce f i l)
    (maxf f l)
    (find-if p l)
    (list-remove-all l item)
    (list-remove-if p item)
    (find-if-all p l)
    (list-less l1 l2)
    (nub l)
    (flatten l)
    (flatten-deep l)
    (powerset l)
    (cross-product l1 l2)
    (union a b)
    (intersection a b)
;;     (sort-strings l)))
    (string-join l s)
    (to-string a)
    (temp-filename)
    (panic str)
    (dump-trace)
))

(define (identity x) x)

;; these are already defined by chicken
(define (first l)
  (car l))
(define (second l)
  (cadr l))
(define (third l)
  (caddr l))

;; Always returns a boolean
;; member only returns a boolean for false
(define (member? i l)
  (if (member i l)
      #t
      #f))

(define (compose f1 f2)
  (lambda (x)
    (f2 (f1 x))))

(define (reduce f i l)
  ;; from qobischeme
  (cond ((null? l) i)
	((null? (cdr l)) (car l))
	(else (let loop ((l (cdr l))
			 (c (car l)))
		(if (null? l) 
		    c
		    (loop (cdr l) (f c (car l))))))))

;; Return the element from the list
;; that gives the largest value for f
(define (maxf f l)
  (reduce (lambda (x y)
	    (if (> (f x) (f y))
		x
		y))
	  '()
	  l))

;; return the first item in l for which predicate p is true
(define (find-if p l)
  (if (null? l)
      #f
      (if (p (car l))
          (car l)
          (find-if p (cdr l)))))

;; Remove the first occurent of item from list l, returns a new list
(define (list-remove l item)
  (if (null? l)
      l
      (let  ((a (car l))
	     (b (cdr l)))
	(if (equal? a item)
	    b
	    (cons a (list-remove b item))))))

;; Remove all occurences of item from the list
(define (list-remove-all l item)
  (if (null? l)
      l
      (let ((a (car l))
            (b (cdr l)))
       (if (equal? a item)
         (list-remove-all b item)
         (cons a (list-remove-all b item))))))

;; Remove all the items from l for which p is true
(define (list-remove-if p l)
  (cond ((null? l) (list))
	((p (car l))
	 (list-remove-if p (cdr l)))
	(else 
	 (cons (car l) (list-remove-if p (cdr l))))))

;; The list of items in l for which predicate p is true
(define (find-if-all p l)
  (cond ((null? l) (list))
	((p (car l)) 
	 (cons (car l) (find-if-all p (cdr l))))
	(else 
	 (find-if-all p (cdr l)))))
		    
;; Remove the items in l2 from l1
(define (list-less l1 l2)
  (if (null? l2)
      l1
      (let ((a (car l2))
	    (b (cdr l2)))
	(list-less (list-remove l1 a) b))))

;; Returns a new list with the duplicates removed
(define (nub l)
  (let loop ((b l)	
	     (n (list)))
    (cond ((null? b) n)
	  ((member (car b) n)
	   (loop (cdr b) n))
	  (else
	   (loop (cdr b) (cons (car b) n))))))

;; flatten a list of lists
(define (flatten l)
  (cond ((null? l) l)
	((list? (car l))
	 (append (car l) (flatten (cdr l))))
	(else 
	 (cons (car l) (flatten (cdr l))))))

(define (flatten-deep l)
  (cond ((null? l) '())
	((list? l) (append (flatten-deep (car l)) (flatten-deep (cdr l))))
	(else (list l))))

;; Return the power set of l, eg. all the subsets of l
(define (powerset l)
  (if (null? l) 
      (list (list))
      (let* ((a (car l))
	     (rest (cdr l))
	     (prest (powerset rest)))
	(append prest (map (lambda (x) (cons a x)) prest)))))

;; returns a list of pairs of a and each element of l
(define (%pair-each a l)
  (if (null? l)
      l
      (cons (list a (car l)) 
	    (%pair-each a (cdr l)))))

;; return the cross product of l1 and l2
(define (cross-product l1 l2)
  (if (null? l1) 
      l1
      (let ((prod-a (%pair-each (car l1) l2))
	    (prodRest (cross-product (cdr l1) l2)))
	(append prod-a prodRest))))

;; returns a list which contains the all the elements of a and b
;; with no duplicates
(define (union a b)
  (cond ((null? a) b)
	((member (car a) b)
	 (union (cdr a) b))
	(else 
	 (cons (car a) (union (cdr a) b)))))

(define (intersection a b)
  (let loop ((intersec (list))
	     (a a)
	     (b b))
    (if (not (null? a))
	(if (member (car a) b)
	    (loop (cons (car a) intersec)
		  (cdr a)
		  b)
	    (loop intersec (cdr a) b))
	intersec)))
		   
;; chicken only      
;; removes the runtime arguments to chicken and the program name, argv[0]
;; chicken arguments begin with -:
;;(define (get-args)
;;  (let loop ((args (cdr (argv))))
;;    (cond ((null? args) (list))
;;	  ((substring=? "-:" (car args) 0 0)
;;	   (loop (cdr args)))
;;	  (else args))))

;; sort a list of strings
(define (sort-strings l)
  (sort l (lambda (a b) (< (string-compare3 a b) 0))))


; join elements in a list of strings using s as a delimter
(define (string-join l s)
  (if (null? l) 
      ""
      (let loop ((str (car l))
		 (l (cdr l)))
	(cond ((null? l) str)
	      (else (loop (string-append 
			   (string-append str s)
			   (car l))
			  (cdr l)))))))

(define (to-string a)
  (format "~a" a))

(define (temp-filename)
  (let ((filename
	 (format "~a~a~a~s" 
		 (os-tmp) 
		 (file-separator)
		 "tmp" 
		 (random 65535))))
    ;; remove this file at program exit
;;     (register-exit-function! 
;;      (lambda (exit-status)
;;        (delete-file filename)))
    filename))
 
(define (panic str)
  (error "" str ""))
(define (dump-trace)
  (dump-trace-stack (current-output-port) 1024))
