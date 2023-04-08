#lang racket

(require csv-reading)
(require plot)

(define file (open-input-file "Dev\\pico-radio-clock\\data.csv"))

;(define data (csv->list file))

(define (datapoint x)
  (list (string->number (second x)) (string->number (fourth x))))

(define new-data (csv-map datapoint file))

(plot (lines new-data))
