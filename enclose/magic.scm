#| -*- Scheme -*-

Copyright (c) 1987, 1988, 1989, 1990, 1991, 1995, 1997, 1998,
              1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006,
              2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014,
              2015, 2016, 2017, 2018, 2019
            Massachusetts Institute of Technology

This file is part of MIT scmutils.

MIT scmutils is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

MIT scmutils is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with MIT scmutils; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301,
USA.

|#

;;;; Magic interface to Scheme compiler, CPH & GJS

(declare (usual-integrations))

;;; This is the basic thing...

(define (compile-and-run sexp #!optional environment declarations keep?)
  (if (default-object? environment) (set! environment scmutils-base-environment))
  (if (default-object? declarations) (set! declarations '((usual-integrations))))
  (if (default-object? keep?) (set! keep? 'keep))
  (scode-eval (compile-expression sexp environment declarations keep?) environment))

(define (compile-and-run-numerical sexp #!optional environment declarations keep?)
  (if (default-object? environment) (set! environment scmutils-base-environment))
  (if (default-object? declarations) (set! declarations '((usual-integrations))))
  (if (default-object? keep?) (set! keep? 'keep))
  (scode-eval (compile-numerical sexp environment declarations keep?) environment))

(define (compile-numerical sexp #!optional environment declarations keep?)
  (if (default-object? environment) (set! environment scmutils-base-environment))
  (if (default-object? declarations) (set! declarations '((usual-integrations))))
  (if (default-object? keep?) (set! keep? 'keep))
  (compile-expression (text/cselim (gjs/cselim sexp))
		      (compose generic->floating flonumize)
		      environment
		      declarations
		      keep?))

(define (compile-and-run-sexp sexp #!optional environment declarations keep?)
  (if (default-object? environment) (set! environment scmutils-base-environment))
  (if (default-object? declarations) (set! declarations '((usual-integrations))))
  (if (default-object? keep?) (set! keep? 'keep))
  (scode-eval (compile-sexp sexp environment declarations keep?) environment))

(define (compile-sexp sexp #!optional environment declarations keep?)
  (if (default-object? environment) (set! environment scmutils-base-environment))
  (if (default-object? declarations) (set! declarations '((usual-integrations))))
  (if (default-object? keep?) (set! keep? 'keep))
  (compile-expression (text/cselim (gjs/cselim sexp))
		      (lambda (x) x)
		      environment
		      declarations
		      keep?))


;;; This takes a closed procedure and makes a faster one

(define (compile-procedure procedure #!optional declarations keep-debugging-info?)
  (if (not (procedure? procedure))
      (error:wrong-type-argument procedure "procedure" 'compile-procedure))
  (if (default-object? declarations) (set! declarations '((usual-integrations))))
  (if (default-object? keep-debugging-info?) (set! keep-debugging-info? 'keep))
  (if (compound-procedure? procedure)
      (compiler-output->procedure
       (compile-procedure-text (procedure-lambda procedure)
			       (lambda (x) x) ;scode-transformer
			       declarations
			       keep-debugging-info?)			       
       (procedure-environment procedure))
      procedure))

;;; Imports from the Scheme compiler subsystem

(define integrate/sexp
  (access integrate/sexp (->environment '(scode-optimizer top-level))))

(define integrate/scode
  (access integrate/scode (->environment '(scode-optimizer top-level))))

(define compiler-output->procedure
  (access compiler-output->procedure (->environment '(compiler top-level))))

(define compile-scode
  (access compile-scode (->environment '(compiler top-level))))

;;; System changed scode manipulation names to more consistent names.

(define make-scode-variable
  (if (environment-bound? system-global-environment 'make-scode-variable)
      (access make-scode-variable system-global-environment)
      (access make-variable system-global-environment)))


(define make-scode-assignment
  (if (environment-bound? system-global-environment 'make-scode-assignment)
      (access make-scode-assignment system-global-environment)
      (access make-assignment system-global-environment)))

(define scode-assignment-name
  (if (environment-bound? system-global-environment 'scode-assignment-name)
      (access scode-assignment-name system-global-environment)
      (access assignment-name system-global-environment)))

(define scode-assignment-value
  (if (environment-bound? system-global-environment 'scode-assignment-value)
      (access scode-assignment-value system-global-environment)
      (access assignment-value system-global-environment)))


(define scode-variable?
  (if (environment-bound? system-global-environment 'scode-variable?)
      (access scode-variable? system-global-environment)
      (access variable? system-global-environment)))

(define scode-variable-name
  (if (environment-bound? system-global-environment 'scode-variable-name)
      (access scode-variable-name system-global-environment)
      (access variable-name system-global-environment)))



(define make-scode-combination
  (if (environment-bound? system-global-environment 'make-scode-combination)
      (access make-scode-combination system-global-environment)
      (access make-combination system-global-environment)))

(define scode-combination-operator
  (if (environment-bound? system-global-environment 'scode-combination-operator)
      (access scode-combination-operator system-global-environment)
      (access combination-operator system-global-environment)))

(define scode-combination-operands
  (if (environment-bound? system-global-environment 'scode-combination-operands)
      (access scode-combination-operands system-global-environment)
      (access combination-operands system-global-environment)))


(define make-scode-comment
  (if (environment-bound? system-global-environment 'make-scode-comment)
      (access make-scode-comment system-global-environment)
      (access make-comment system-global-environment)))

(define scode-comment-expression
  (if (environment-bound? system-global-environment 'scode-comment-expression)
      (access scode-comment-expression system-global-environment)
      (access comment-expression system-global-environment)))

(define scode-comment-text
  (if (environment-bound? system-global-environment 'scode-comment-text)
      (access scode-comment-text system-global-environment)
      (access comment-text system-global-environment)))


(define make-scode-conditional
  (if (environment-bound? system-global-environment 'make-scode-conditional)
      (access make-scode-conditional system-global-environment)
      (access make-conditional system-global-environment)))

(define scode-conditional-predicate
  (if (environment-bound? system-global-environment 'scode-conditional-predicate)
      (access scode-conditional-predicate system-global-environment)
      (access conditional-predicate system-global-environment)))

(define scode-conditional-consequent
  (if (environment-bound? system-global-environment 'scode-conditional-consequent)
      (access scode-conditional-consequent system-global-environment)
      (access conditional-consequent system-global-environment)))

(define scode-conditional-alternative
  (if (environment-bound? system-global-environment 'scode-conditional-alternative)
      (access scode-conditional-alternative system-global-environment)
      (access conditional-alternative system-global-environment)))


(define make-scode-delay
  (if (environment-bound? system-global-environment 'make-scode-delay)
      (access make-scode-delay system-global-environment)
      (access make-delay system-global-environment)))

(define scode-delay-expression
  (if (environment-bound? system-global-environment 'scode-delay-expression)
      (access scode-delay-expression system-global-environment)
      (access delay-expression system-global-environment)))


(define make-scode-disjunction
  (if (environment-bound? system-global-environment 'make-scode-disjunction)
      (access make-scode-disjunction system-global-environment)
      (access make-disjunction system-global-environment)))

(define scode-disjunction-predicate
  (if (environment-bound? system-global-environment 'scode-disjunction-predicate)
      (access scode-disjunction-predicate system-global-environment)
      (access disjunction-predicate system-global-environment)))

(define scode-disjunction-alternative
  (if (environment-bound? system-global-environment 'scode-disjunction-alternative)
      (access scode-disjunction-alternative system-global-environment)
      (access disjunction-alternative system-global-environment)))


(define make-scode-definition
  (if (environment-bound? system-global-environment 'make-scode-definition)
      (access make-scode-definition system-global-environment)
      (access make-definition system-global-environment)))

(define scode-definition-name
  (if (environment-bound? system-global-environment 'scode-definition-name)
      (access scode-definition-name system-global-environment)
      (access definition-name system-global-environment)))

(define scode-definition-value
  (if (environment-bound? system-global-environment 'scode-definition-value)
      (access scode-definition-value system-global-environment)
      (access definition-value system-global-environment)))


(define make-scode-lambda
  (if (environment-bound? system-global-environment 'make-scode-lambda)
      (access make-scode-lambda system-global-environment)
      (access make-lambda system-global-environment)))

(define scode-lambda-components
  (if (environment-bound? system-global-environment 'scode-lambda-components)
      (access scode-lambda-components system-global-environment)
      (access lambda-components system-global-environment)))


(define make-scode-sequence
  (if (environment-bound? system-global-environment 'make-scode-sequence)
      (access make-scode-sequence system-global-environment)
      (access make-sequence system-global-environment)))

(define scode-sequence-actions
  (if (environment-bound? system-global-environment 'scode-sequence-actions)
      (access scode-sequence-actions system-global-environment)
      (access sequence-actions system-global-environment)))


(define (scode-operator-name operator)
  (cond ((primitive-procedure? operator)
	 (primitive-procedure-name operator))
	(else
	 (scode-variable-name operator))))

;;; Interface procedures to the Scheme compiler

;;; This compiles an s-expression to something that can be evaluated with scode-eval

(define (compile-expression s-expression scode-transformer environment declarations keep-debugging-info?)
  (fluid-let ((sf:noisy? #f))
    (compile-scode
     (scode-transformer (integrate/sexp s-expression environment declarations #f))
     (and keep-debugging-info? 'KEEP))))


;;; This compiles a procedure text

(define (compile-procedure-text procedure-text scode-transformer declarations keep-debugging-info?)
  (fluid-let ((sf:noisy? #f))
    (compile-scode
     (scode-transformer 
      (integrate/scode
       (make-scode-declaration declarations procedure-text)
       #f))
     (and keep-debugging-info? 'KEEP))))


(define (named-combination-transformer do-leaf do-named-combination)
  (letrec
      ((do-expr
	(lambda (expr)
	  ((scode-walk scode-walker expr) expr)))
       (scode-walker
	(make-scode-walker
	 do-leaf
	 `((assignment
	    ,(lambda (expr)
	       (make-scode-assignment (scode-assignment-name expr)
				      (do-expr (scode-assignment-value expr)))))
	   (combination
	    ,(lambda (expr)
	       (if (or (primitive-procedure? (scode-combination-operator expr))
		       (scode-variable? (scode-combination-operator expr)))
		   (do-named-combination expr)
		   (make-scode-combination (do-expr (scode-combination-operator expr))
					   (map do-expr
						(scode-combination-operands expr))))))
	   (comment
	    ,(lambda (expr)
	       (make-scode-comment (scode-comment-text expr)
				   (do-expr (scode-comment-expression expr)))))
	   (conditional
	    ,(lambda (expr)
	       (make-scode-conditional (do-expr (scode-conditional-predicate expr))
				       (do-expr (scode-conditional-consequent expr))
				       (do-expr (scode-conditional-alternative expr)))))
	   (delay
	    ,(lambda (expr)
	       (make-scode-delay (do-expr (scode-delay-expression expr)))))
	   (disjunction
	    ,(lambda (expr)
	       (make-scode-disjunction (do-expr (scode-disjunction-predicate expr))
				       (do-expr (scode-disjunction-alternative expr)))))
	   (definition
	    ,(lambda (expr)
	       (make-scode-definition (definition-name expr)
				      (do-expr (scode-definition-value expr)))))
	   (lambda
	    ,(lambda (expr)
	       (scode-lambda-components expr
		 (lambda (name required optional rest auxiliary decls body)
		   (make-scode-lambda name required optional rest auxiliary decls
				(do-expr body))))))
	   (sequence
	    ,(lambda (expr)
	       (make-scode-sequence (map do-expr (scode-sequence-actions expr)))))))))
    do-expr))

(define flonumize
  (named-combination-transformer
   (lambda (expr)
     (if (and (number? expr)
	      (real? expr)
	      (exact? expr))
	 (exact->inexact expr)
	 expr))
   (lambda (expr)
     (let ((operator (scode-combination-operator expr))
	   (operands (scode-combination-operands expr)))
       (let ((operator-name (scode-operator-name operator)))
	 (case operator-name
	   ((make-vector make-initialized-vector v:generate vector:generate
	     make-list make-initialized-list
	     s:generate)
	    (make-scode-combination operator
				    (cons (car operands)
					  (map flonumize (cdr operands)))))
	   ((vector-ref vector-set! list-ref s:ref s:with-substituted-coord)
	    (make-scode-combination operator
				    (cons* (flonumize (car operands))
					   (cadr operands)
					   (map flonumize (cddr operands)))))
	   ((matrix-ref matrix-set!)
	    (make-scode-combination operator
				    (cons* (flonumize (car operands)) 
					   (cadr operands)
					   (caddr operands)
					   (map flonumize (cdddr operands)))))
	   ((m:minor m:submatrix ref)
	    (make-scode-combination operator
				    (cons* (flonumize (car operands))
					   (cdr operands))))
	   ((v:make-zero v:make-basis-unit
	     m:make-zero m:make-identity
	     exact->inexact)
	    expr)
	   ((expt)
	    (let ((base (flonumize (car operands)))
		  (e (cadr operands)))
	      (if (exact-integer? e)
		  (cond ((= e 0)
			 1.)
			((= e 1)
			 base)
			((<= 2 e 4)
			 (make-scode-combination (make-scode-variable '*)
						 (make-list base e)))
			(else
			 (make-scode-combination operator (list base e))))
		  (make-scode-combination operator (list base (flonumize e))))))
	   (else
	    (if (string-prefix? "fix:" (symbol->string operator-name))
		expr
		(make-scode-combination operator (map flonumize operands))))))))))

(define generic->floating
  (let ()
    (define (make-flo-bin op)
      (lambda (x y)
	(make-scode-combination (make-scode-variable op)
				(list x y))))
    (let ((flo:+:bin (make-flo-bin 'flo:+))
	  (flo:-:bin (make-flo-bin 'flo:-))
	  (flo:*:bin (make-flo-bin 'flo:*))
	  (flo:/:bin (make-flo-bin 'flo:/))
	  (flo:-:una
	   (lambda (x)
	     (make-scode-combination (make-scode-variable 'flo:-)
				     (list 0. y))))
	  (flo:/:una
	   (lambda (x)
	     (make-scode-combination (make-scode-variable 'flo:/)
				     (list 1. y)))))
      (named-combination-transformer
       (lambda (expr) expr)	     
       (lambda (expr)
	 (let ((operator (scode-combination-operator expr))
	       (operands (scode-combination-operands expr)))
	   (let ((operator-name (scode-operator-name operator)))
	     (case operator-name
	       ((+ &+)
		(apply (accumulation flo:+:bin 0.)
		       (map generic->floating operands)))
	       ((* &*)
		(apply (accumulation flo:*:bin 1.)
		       (map generic->floating operands)))
	       ((- &-)
		(apply (inverse-accumulation flo:-:bin flo:+:bin flo:-:una 0.)
		       (map generic->floating operands)))
	       ((/ &/)
		(apply (inverse-accumulation flo:/:bin flo:*:bin flo:/:una 1.)
		       (map generic->floating operands)))
	       ((sqrt exp abs cos sin tan)
		(make-scode-combination
		 (make-scode-variable
		  (string->symbol
		   (string-append "flo:"
				  (symbol->string operator-name))))
		 (list (generic->floating (car operands)))))
	       (else
		(if (string-prefix? "fix:" (symbol->string operator-name))
		    expr
		    (make-scode-combination operator
					    (map generic->floating operands))))))))))))


#|
(define ((test-transformer trans) expr)
  (pp (trans (syntax expr scmutils-base-environment))))

((test-transformer (compose generic->floating flonumize))
 '(+ 1 (* 2 (tan 3) (sin a) (vector-ref b 5)) 6))
(flo:+ (flo:+ 1.
	      (flo:* (flo:* (flo:* 2. (flo:tan 3.))
			    (flo:sin a))
		     (vector-ref b 5)))
       6.)
|#
