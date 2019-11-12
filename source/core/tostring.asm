; ******************************************************************************
; ******************************************************************************
;
;		Name : 		tostring.asm
;		Purpose : 	Convert integer to string
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;		   Convert integer at YX to ASCIIZ string in ConvertBuffer
;								(decimal unsigned)
;
; ******************************************************************************

IntToString:
		stx 	zTemp0 						; count is in zTemp0
		sty 	zTemp0+1
		ldy 	#0 							; index into token buffer (out)
		ldx 	#0 							; index into the word table
_ITSLoop:
		stz 	zTemp1 						; this is the count of subtracts.
_ITSSubtractLoop:
		sec
		lda 	zTemp0 						; try to calculate
		sbc 	_ITSWords,x
		pha
		lda 	zTemp0+1
		sbc 	_ITSWords+1,x
		bcc 	_ITSEndSub 					; can't subtract any more.
		;
		sta 	zTemp0+1 					; update zTemp
		pla 								
		sta 	zTemp0
		inc 	zTemp1 						; bump subtract count.
		bra 	_ITSSubtractLoop 
		;
_ITSEndSub:
		pla 								; throw away the interim result
		lda 	zTemp1 						; if the subtract count is non zero
		bne 	_ITSWriteOut 				; always write it out
		cpy 	#0 							; don't write if this is the first 
		beq 	_ITSNext 					; suppressing leading zeros.
_ITSWriteOut:
		ora 	#48 						; output digit.
		sta 	ConvertBuffer,y
		iny
_ITSNext:
		inx
		inx
		cpx 	#_ITSWordsEnd-_ITSWords 	; done all subtractors
		bne 	_ITSLoop 					; do the new digits
		;
		lda 	zTemp0 						; output the last digit
		ora 	#48
		sta 	ConvertBuffer,y 				; make it ASCIIZ.
		lda 	#0
		sta 	ConvertBuffer+1,y
		rts
		;
		;		Subtractor table.
		;
_ITSWords:
		.word 	10000,1000,100,10
_ITSWordsEnd:		