#lang racket

(require csv-reading)
(require plot)

(define ref-offset 20)
(define plot-window 6000)

(define signal0 '((0 0.1) (499 0.1) (500 0.9) (999 0.9)))
(define signaln '((0 0.1) (99 0.1) (100 0.5) (299 0.5) (300 0.9) (999 0.9)))

(define interrupt-file (open-input-file "data.csv"))
(define timer-file (open-input-file "datatimer.csv"))

(define interrupt-data (csv->list interrupt-file))
(define timer-data (csv->list timer-file))

(define (start-offset-from-data lst)
  (+ ref-offset (string->number (second (first lst)))))

(define interrupt-start (start-offset-from-data interrupt-data))
(define timer-start (start-offset-from-data timer-data))

(define (timer-point-from-row row)
  (let* ((ms (string->number (second row)))
         (corrected-ms (- ms timer-start))
         (value (string->number (fourth row))))
    (list corrected-ms value)))


(define (interrupt-point-from-row row)
  (let* ((ms (string->number (second row)))
         (corrected-ms (- ms interrupt-start))
         (value (string->number (fourth row))))
    (list corrected-ms value)))

(define (interrupt-datapoint row)
  (let ((point (interrupt-point-from-row row)))
    (list `(,(sub1 (first point)) ,(modulo (add1 (second point)) 2)) point)))

(define (flatten-once lst)
  (apply append lst))

(define timer-points (map timer-point-from-row timer-data))
(define interrupt-points (flatten-once (map interrupt-datapoint interrupt-data)))

(define (graph start-offset data)
  (plot (list (lines (map (lambda (n) (list (+ start-offset ref-offset (first n)) (second n))) signal0) #:color 1)
              (lines (map (lambda (n) (list (+ start-offset ref-offset (first n)) (second n))) signaln) #:color 3)
              (lines data #:color 2))
        #:aspect-ratio (/ 4 1)
        #:width 3000
        #:x-min start-offset
        #:x-max (+ start-offset plot-window)
        #:y-max 1.1
        #:y-min -0.1
        #:x-label "ticks (ms)"))

(map (lambda (n) (graph n timer-points)) (build-list (ceiling (/ 80000 plot-window)) (lambda (x) (* x plot-window))))

(map (lambda (n) (graph n interrupt-points)) (build-list (ceiling (/ 80000 plot-window)) (lambda (x) (* x plot-window))))
