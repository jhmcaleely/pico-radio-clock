#lang racket

(require csv-reading)
(require plot)

(define ref-start 26000)
(define ref-offset 20)

(define (signal-point n)
  (+ ref-start ref-offset n))

(define signal0 '((0 0.1) (499 0.1) (500 0.9) (999 0.9)))
(define signaln '((0 0.1) (99 0.1) (100 0.5) (299 0.5) (300 0.9) (999 0.9)))



(define file (open-input-file "data.csv"))

(define data (csv->list file))

(define start (+ ref-offset (string->number (second (first data)))))

(define (datapoint x)
  (let* ((ms (string->number (second x)))
        (corrected-ms (- ms start))
        (value (string->number (fourth x))))
    (list `(,(sub1 corrected-ms) ,(modulo (add1 value) 2)) `(,corrected-ms ,value))))

(define new-data (map datapoint data))

(define (flatten-once lst)
  (apply append lst))

(define (graph nn)
(plot (list (lines (map (lambda (n) (list (+ nn ref-offset (first n)) (second n))) signal0) #:color 1)
            (lines (map (lambda (n) (list (+ nn ref-offset (first n)) (second n))) signaln) #:color 3)
            (lines (flatten-once new-data) #:color 2))
      #:aspect-ratio (/ 4 1)
      #:width 3000
      #:x-min nn
      #:x-max (+ nn 6000)
      #:y-max 1.1
      #:y-min -0.1
      #:x-label "ticks (ms)"))

(map graph (build-list 16 (lambda (x) (* x 6000))))
