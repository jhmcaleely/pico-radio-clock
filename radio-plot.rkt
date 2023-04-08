#lang racket

(require csv-reading)
(require plot)

(define ref-offset 20)
(define plot-window 6000)

(define signal0 '((0 0.1) (499 0.1) (500 0.9) (999 0.9)))
(define signaln '((0 0.1) (99 0.1) (100 0.5) (299 0.5) (300 0.9) (999 0.9)))

(define (raw-csv-data file)
  (csv->list (open-input-file file)))

(define interrupt-data (raw-csv-data "data.csv"))
(define timer-data (raw-csv-data "datatimer.csv"))

(define (start-offset-from-data lst)
  (+ ref-offset (string->number (second (first lst)))))

(define (point-from-row row start)
  (let* ((ms (string->number (second row)))
         (corrected-ms (- ms start))
         (value (string->number (fourth row))))
    (list corrected-ms value)))

(define (interrupt-datapoint row start)
  (let ((point (point-from-row row start)))
    (list `(,(sub1 (first point)) ,(modulo (add1 (second point)) 2)) point)))

(define (flatten-once lst)
  (apply append lst))

(define timer-points
  (map (lambda (row) (point-from-row
                      row
                      (start-offset-from-data timer-data)))
       timer-data))

(define interrupt-points
  (flatten-once (map (lambda (row) (interrupt-datapoint
                                    row
                                    (start-offset-from-data interrupt-data)))
                     interrupt-data)))

(define (offset-points start-offset point)
   (list (+ start-offset ref-offset (first point)) (second point)))

(define (graph window-offset data)
  (plot (list (lines (map (lambda (n) (offset-points window-offset n)) signal0) #:color 1)
              (lines (map (lambda (n) (offset-points window-offset n)) signaln) #:color 2)
              (lines data #:color 3))
        #:aspect-ratio (/ 4 1)
        #:width 3000
        #:x-min window-offset
        #:x-max (+ window-offset plot-window)
        #:y-max 1.1
        #:y-min -0.1
        #:x-label "ticks (ms)"))

(define plot-windows (build-list (ceiling (/ 80000 plot-window)) (lambda (x) (* x plot-window))))

(define (all-plots points)
  (map (lambda (n) (graph n points)) plot-windows))

(all-plots timer-points)
(all-plots interrupt-points)
