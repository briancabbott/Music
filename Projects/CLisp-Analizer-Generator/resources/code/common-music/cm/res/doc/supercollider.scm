;
;; Working with Supercollider
;

; To run examples put the cursor at the end of each expression and
; press Command-Return. Look in the console window for any output.

; This example assumes you already have "wavesc.rtf" open and running
; inside SuperCollider. If not, first use Grace's Instrument Browser
; Dialog located the Audio menu to find the instrument named
; 'sc:wave', then select the instrument and click the Export button on
; the dialog to restore the file to your hard drive. Next drag the
; "wavesc.rtf" file onto SuperCollider to open it, then choose Select
; all in SC's Edit menu and evaluate the selection using Eval
; Selection in SC's Lang menu. Once you see a 'running' status in SC's
; localhost server window you can start working with these examples.

; Open an OSC connection with the SuperCollider app that's running
; wavesc.rtf. 

(osc:open 7779 57110)

; Load a premade sinewave instrument from Grace's embedded
; distribution.

(load "wavesc.scm")

; Eval the next line several time to try it out. If you don't hear
; sound, make sure SC booted port 57100 in the Post window and use the
; commented out sound examples at the end of wavesc.rtf to test your
; audio.

(sc:wave 0 .5 (between 220 440) .2
         :ampenv '(0 1 15 .5 50 .1 100 0)
         )

; Try it with frequency skew fuctions.

(let ((g (pick .5 2 1.5 .666 1.059 .943)))
  (sc:wave 0 1 (between 220 440) .25 :ampenv '(0 1 15 .5 50 .1 100 0)
           :skew (list 0 1 80 g 100 g))
  )

; Try using a process

(define (gong num dur freq amp deg )
  (process repeat num
           for frq = (between freq (* freq 3))
           do
           (sc:wave 0 dur frq amp
                    :ampenv '(0 0 1 1 10 .5 40 .2 100 0)
                    :degree deg)))

(sprout (gong 2 2 440 .1 45))

(sprout (gong 8 2 440 .1 45))

; Try a process that sprouts gongs

(define (gongalong num rate dur freqenv)
  (process for i below num
           do (sprout (gong (pick 2 3) dur (interp (/ i num) freqenv)
                            .05
                            (between 10 81)))
           (wait rate)))

(sprout (gongalong 20 .5 2 '(0 440 1 300)))

; If you have a midi keyboard hooked up you can play gongs:

(define (midigong msg)
  (let ((frq (hertz (third msg)))
        (amp (rescale (fourth msg) 0 127 0.01 .5))
        (dur (pick .5 1 1.5)))
    (loop repeat (between 3 6)
          for f = (between frq (* frq 3))
          do
          (sc:wave 0 dur f amp
                   :ampenv '(0 0 1 1 10 .5 40 .2 100 0)))))

; Start receiving MIDI NoteOn messages from your Audio>MidiIn device.

(mp:receive mm:on midigong)

; Stop receiving...

(mp:receive ) 
