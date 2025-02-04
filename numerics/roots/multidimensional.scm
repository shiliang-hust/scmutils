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

;;;; Multidimensional root finder, with secant approximation to derivative.
;;;   GJS -- 10 May 2005

(declare (usual-integrations))

;;; f is a vector-valued function of a vector argument
(define (multidimensional-root f initial-point initial-step min-step)
  (multidimensional-root-internal f initial-point initial-step min-step
                                  (lambda (x) x)
                                  barf-on-zero-pivot))

(define (multidimensional-root-internal f initial-point initial-step min-step
                                        succeed fail)
  (let ((N (v:dimension initial-point)))
    (define (step xn xn-1)
      (let ((fn (f xn))
	    (fps
	     (v:generate N
	       (lambda (i)
		 (f
		  (vector-with-substituted-coord xn i
						 (vector-ref xn-1 i)))))))
	(assert (fix:= N (v:dimension fn)))
	(let ((M
	       (matrix:generate N N
				(lambda (i j)
				  (/ (- (vector-ref fn i)
					(vector-ref (vector-ref fps j) i))
				     (- (vector-ref xn j)
					(vector-ref xn-1 j)))))))
	  (lu-solve M fn
                    (lambda (x)
                      (vector-vector xn x))
                    fail))))
    (define (good-root? xn xn-1)
      (let lp ((i 0) (diff 0))
	(if (fix:= i N)
	    (< diff min-step)
	    (lp (fix:+ i 1)
		(max diff
		     (magnitude (- (vector-ref xn i)
                                   (vector-ref xn-1 i))))))))
    (define (try xn xn-1)
      (if (good-root? xn xn-1)
	  (succeed xn)
	  (try (step xn xn-1) xn)))
    (try initial-point
	 (if (vector? initial-step)
	     (v:generate N
			 (lambda (i)
			   (+ (vector-ref initial-point i)
			      (vector-ref initial-step i))))
	     (v:generate N
			 (lambda (i)
			   (+ (vector-ref initial-point i)
			      initial-step)))))))

#|
(multidimensional-root 
 (lambda (v)
   (let ((x (vector-ref v 0)) (y (vector-ref v 1)))
     (vector (+ x y -3) (+ x (- y) -1))))
 (vector 1.5 1.5)
 .01
 1e-10)
;Value: #(2. 1.)

(multidimensional-root 
 (lambda (v)
   (let ((x (vector-ref v 0)) (y (vector-ref v 1)))
     (vector (square x) (+ x (- y) -1))))
 (vector 1.5 1.5)
 .01
 1e-10)
;Value: #(1.194318926912262e-10 -.9999999998805681)

(multidimensional-root 
 (lambda (v)
   (let ((x (vector-ref v 0)) (y (vector-ref v 1)))
     (vector (+ x (- y) -1) (square (+ x y -3)))))
 (vector 1.5 1.4)
 .01
 1e-15)
;Value: #(1.9999999999999996 .9999999999999997)
|#
