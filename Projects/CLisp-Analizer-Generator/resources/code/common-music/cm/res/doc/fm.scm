;
;; Composing with Frequency Modulation.
;

; To run code put your cursor after each expression and press
; Command-Return, then check the console window for any output.

; FM is a powerful algorithm for generating note sets because it can
; generate a wide variety of spectra (both harmonic and inharmonic)
; from just three input parameters: a carrier (center frequency), a
; carrier/modulator ratio, and an FM index that controls the density,
; or width, of the spectrum. Common Music provides the fm-spectrum
; function for computing spectral sets using fm:

; fm-spectrum(carrier, ratio, index)

; Returns an FM spectrum given a carrier (in hertz), a carrier to
; modulator ratio and and fm index.
;
; Example of fm spectral output using a constant carrier (100 hz) c/m
; ratio (1.4) and index of 3.
;

(define myspec (fm-spectrum 100 1.4 3))

(spectrum-pairs myspec)

(spectrum-keys myspec)

(note (spectrum-keys myspec))

(note (spectrum-keys myspec :order -1))

(note (spectrum-keys myspec :order -1 :quant 1))

(note (spectrum-keys myspec :order 0))

(note (spectrum-keys myspec :min 60 :max 71 :quant 1))

; Example: Generate some FM chords with random fluctuations of cm
; ratio and index:

(define (fm-chords reps cen cm1 cm2 in1 in2 rhy) 
  (let ((dur rhy))
    (process repeat reps 
             for spec = (fm-spectrum (hertz cen) (between cm1 cm2) (between in1 in2))
             do
             (loop for k in (spectrum-keys spec :min 48 :max 72)
                   do 
                   (mp:midi :key k :dur dur :chan 0))
             (wait dur)
             )))

(sprout (fm-chords 12 60 1.0 2.0 2.0 4.0 .8))

; Try it with quarter tone tuning

(mp:tuning 2)

(sprout (fm-chords 12 60 1.0 2.0 2.0 4.0 .8))

; Reset tuning to semitone

(mp:tuning 1)

; FM Etude: improvisation.

; Contour is a melodic line used for the carrier frequencies

(define contour (keynum '(a4 g f e a4 b c d gs b c5 ef fs gs 
                             a5 bf g f e a5 b c d gs3 f e cs c 
                             bf5 gs5 as3 cs5 e6 f4 gs5 d6 e f g
                             c5 b a g bf c5 cs e4 f gs d4 c b 
                             a4 e5 f g a5)))

; Improvised specra are used as melodic gestures 70% of the time
; otherwise as chords

(define (fm-improv line beat)
  (let* ((amp .7)
         (dur beat))
    (process for knum in line
             for mel? = (odds .7)
             for rhy = (pick dur (/ dur 2) (/ dur 4))
             for spec = (fm-spectrum (hertz knum)
                                     (between 1.1 1.9)
                                     (pick 1 2 3))
             for keys = (spectrum-keys spec :unique #t
                                       :min (transpose knum -14)
                                       :max (transpose knum 14)
                                       :order (if mel? 0 1))
             for sub = (if mel? (/ rhy (length keys)) 0)
             do
             (loop for k in keys 
                   for i = 0 then (+ i  1)
                   do
                   (mp:midi (* i sub) :key k :dur dur :amp amp))
             (wait rhy)
             )))

(sprout (fm-improv contour 1))

