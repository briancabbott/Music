;
;; Second-order Markov process
;

; To run code put your cursor after each expression and press
; Command-Return, then check the console window for any output.

; This second order markov patter generates music in the style of
; Stephen Foster. The transition table is taken from Chapter 8 of
; "Computer Music" by Dodge/Jerse. Sounds best with slow strings.

(define (foster len octave chan)
  (let ((p1 (make-markov '((b3  d4  -> d4)
                           (cs4 d4  -> (d4 .3125) (e4 .3125) (a4 .3125))
                           (d4  d4  -> (cs4 .125) (d4 .125) (e4 .5625) 
                                (fs4 .125) (a4 .0625))
                           (e4  d4  -> (b3 .0625) (d4 .0625) (e4 .25) 
                                (fs4 .3125) (a4 .0625) (cs5 .0625) (d5 .1875))
                           (fs4 d4  -> (e4 .75) (fs4 .1875) (g4 .0625))
                           (a4  d4  -> (e4 .6875) (fs4 .3125))
                           (b4  d4  -> d4)
                           (d4  b3  -> d4)
                           (d4  cs4 -> d4)
                           (e4  cs4 -> d4)
                           (d4  e4  -> (d4 .1875) (e4 .25) (fs4 .5) (a4 .0625))
                           (e4  e4  -> (cs4 .0625) (d4 .75) (e4 .0625)
                                (fs4 .125))
                           (fs4 e4  -> (cs4 .125) (d4 .4375) (e4 .1875) 
                                (fs4 .125) (a4 .0625) (d5 .0625))
                           
                           (d4  fs4 -> (e4 .4375) (fs4 .1875) (g4 .125) (a4 .25))
                           (e4  fs4 -> (d4 .0625) (e4 .1875) (fs4 .3125) (g4 .25)
                                (a4 .0625) (b4 .0625)) 
                           (fs4 fs4 -> (d4 .1875) (e4 .25) (fs4 .3125) (g4 .125)
                                (a4 .0625))
                           (g4  fs4 -> (e4 .5) (g4 .5))
                           (a4  fs4 -> (d4 .3125) (e4 .25) (fs4 .1875) (g4 .0625)
                                (a4 .125) (b4 .0625))
                           (b4  fs4 -> (e4 .6875) (fs4 .3125))
                           (d4  g4  -> (fs4 .6875) (b4 .3125))
                           (fs4 g4  -> (fs4 .25) (g4 .1875) (a4 .3125)
                                (b4 .1875))
                           (g4  g4  -> (g4 .5) (a4 .5))
                           (a4  g4  -> fs4)
                           (b4  g4  -> b4)
                           (a4  gs4 -> a4)
                           (d4  a4  -> (fs4 .25) (a4 .75))
                           (e4  a4  -> (a4 .8125) (b4 .1875))
                           (fs4 a4  -> (fs4 .125) (a4 .625) (b4 .1875) (d5 .0625))
                           (g4  a4  -> (d4 .125) (a4 .625) (d5 .25))
                           (gs4 a4  -> a4)
                           (a4  a4  -> (fs4 .25) (g4 .0625) (gs4 .0625)
                                (a4 .3125) (b4 .3125)) 
                           (b4  a4  -> (d4 .0625) (fs4 .5625) (g4 .0625) (a4 .125)
                                (b4 .0625) (d5 .125))
                           (d5  a4  -> (fs4 .875) (a4 .125))
                           (e5  a4  -> a4)
                           (fs4 b4  -> a4)
                           (g4  b4  -> a4)
                           (a4  b4  -> (d4 .0625) (fs4 .0625) (a4 .75) (b4 .0625)
                                (b4 .0625))
                           (b4  b4  -> (fs4 .125) (a4 .75) (d5 .125))
                           (cs5 b4  -> a4)
                           (d5  b4  -> (g4 .0625) (a4 .3125) (b4 .3125) (d5 .25))
                           (d4  cs5 -> d5)
                           (d5  cs5 -> (b4 .75) (d5 .25)) 
                           (e5  cs5 -> d5)
                           (d4  d5  -> (a4 .125) (b4 .6875) (cs5 .1875) )
                           (e4  d5  -> cs5)
                           (a4  d5  -> (a4 .3125) (b4 .3125) (cs5 .1875) (d5 .125))
                           (b4  d5  -> (a4 .5625) (b4 .125) (cs5 .3125))
                           (cs5 d5  -> (b4 .3125) (e5 .625))
                           (d5  d5  -> b4)
                           (d5  e5  ->  (a4 .3125) (cs5 .6875))) ))

        ;; p2 is rhythmic pattern that randomly selects between several
        ;; rhythmic motives that are characterisitic of Foster's style

        (p2 (make-weighting (list (list (make-cycle '(2 2))     .375)
                                  (list (make-cycle '(1 1 1 1)) .125)
                                  (list (make-cycle '(2 1 1))   .125)
                                  (list (make-cycle '(1 1 2))   .125)
                                  (list (make-cycle '(1 2 1))   .25)
                                  (list 4                       .125))))
        )
    
    ;; the process simply reads data from the 2 markov patterns and
    ;; transposes the data according to the octave offset passed into
    ;; the function.

  (process repeat len
           for k = (keynum (next p1))
           for d = (in-tempo (next p2) 200)
           do
           (mp:midi :key (+ k octave) :chan chan
                    :dur (* d 1.25) :amp .5)
           (wait d)
           )))
  
; Sample call that generates 4 parallel foster processes in different
; octaves. Select "Slow Strings" on the four channels to get a pretty
; good Copeland sound....

(define string-ensemble 49)

(mp:prog :val string-ensemble)

(sprout (list (foster 90 -12  0)
              (foster 90 0    0)
              (foster 90 12   0)
              (foster 90 24   0)
              ))

