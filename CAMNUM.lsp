;------------------------------------------------------------------------------
; MIT License
;
; Copyright (c) 2025 Paul-David Zagan
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;
;------------------------------------------------------------------------------
; Description: 
;   Numbers camera blocks along a selected polyline (fence) starting from
;   a specified first camera. Places MText labels with customizable prefix
;   and numbering.
;
; Usage:
;   Load this LISP file into AutoCAD.
;   Run command: NUMCAMS
;   Follow prompts to select the first camera, all cameras, polyline, and
;   enter numbering prefix and start number.
;------------------------------------------------------------------------------

(defun c:NUMCAMS ( / startEnt startPt prefix startNum i ss ent blk insPt angle camList sortedList polyline closestPt dist numStr startParam param totalParam)

  (vl-load-com)

  ;; Select the starting camera block (prompt at cursor)
  (setq startEnt (car (entsel "\nSelect the FIRST camera block (starting point): ")))
  (if (not startEnt)
    (progn (princ "\nNo starting block selected.") (exit))
  )
  (setq startPt (cdr (assoc 10 (entget startEnt))))

  ;; Select all camera blocks (prompt at cursor)
  (prompt "\nSelect ALL camera blocks (including the first one): ")
  (setq ss (ssget))
  (if (not ss)
    (progn (princ "\nNo blocks selected.") (exit))
  )

  ;; Remove the start block if included again
  (setq ss (ssdel startEnt ss))

  ;; Ask for prefix and starting number
  (setq prefix (getstring T "\nEnter camera number prefix (e.g., CAM-): "))
  (setq startNum (getint "\nEnter starting number: "))
  (if (not startNum) (setq startNum 1))

  ;; Select polyline (prompt at cursor)
  (setq polyline (car (entsel "\nSelect the polyline (fence): ")))
  (if (not polyline)
    (progn (princ "\nNo polyline selected.") (exit))
  )

  ;; Get full param range of the polyline
  (setq totalParam (vlax-curve-getendparam polyline))

  ;; Get parameter for the starting block
  (setq startParam (vlax-curve-getparamatpoint
                     polyline
                     (vlax-curve-getclosestpointto polyline startPt)))

  ;; Add the starting block to the list (relative distance = 0)
  (setq camList (list (list 0.0 (vlax-ename->vla-object startEnt) startPt)))

  ;; Loop through selected blocks
  (repeat (sslength ss)
    (setq ent (ssname ss 0))
    (setq ss (ssdel ent ss))
    (setq blk (vlax-ename->vla-object ent))
    (setq insPt (vlax-get blk 'InsertionPoint))

    ;; Get the parameter value on the polyline
    (setq param (vlax-curve-getparamatpoint
                  polyline
                  (vlax-curve-getclosestpointto polyline insPt)))

    ;; Compute wrapped relative distance
    (setq dist (if (< param startParam)
                 (+ (- totalParam startParam) param)
                 (- param startParam)))

    ;; Store in list
    (setq camList (cons (list dist blk insPt) camList))
  )

  ;; Sort blocks by distance from the starting point
  (setq sortedList (vl-sort camList
                            (function (lambda (a b) (< (car a) (car b))))))

  ;; Number blocks and add MText labels
  (setq i startNum)
  (foreach item sortedList
    (setq blk (cadr item))
    (setq insPt (caddr item))
    (setq numStr (strcat prefix (itoa i)))

    ;; Create MText label 3 units to the left of the block
    (entmakex
      (list
        (cons 0 "MTEXT")
        (cons 100 "AcDbEntity")
        (cons 100 "AcDbMText")
        (cons 8 "CBS_CAM_NUMBERING") ;; Change layer if desired
        (cons 10 (list (- (car insPt) 3.0) (cadr insPt) (caddr insPt)))
        (cons 40 1) ;; Text height
        (cons 1 numStr)
        (cons 7 "Standard") ;; Text style
        (cons 71 1) ;; Left attachment
        (cons 72 5) ;; Left alignment
        (cons 50 0.0) ;; Rotation angle
      )
    )

    (setq i (1+ i))
  )

  (princ (strcat "\n" (itoa (length sortedList)) " cameras numbered and labeled with MText."))
  (princ)
)
