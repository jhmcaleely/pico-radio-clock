#lang racket

(require csv-reading)
(require plot)

(define file (open-input-file "data.csv"))

(define data (csv->list file))

(define start (string->number (second (first data))))

(define (datapoint x)
  (let* ((ms (string->number (second x)))
        (corrected-ms (- ms start))
        (value (string->number (fourth x))))
    (list `(,(sub1 corrected-ms) ,(modulo (add1 value) 2)) `(,corrected-ms ,value))))

(define new-data (map datapoint data))

(define (flatten-once lst)
  (apply append lst))

(plot (lines (flatten-once new-data))
      #:aspect-ratio (/ 4 1)
      #:x-label "ticks (ms)")
