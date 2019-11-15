; ******************************************************************************
; ******************************************************************************
;
;		Name : 		tok_token.asm
;		Purpose : 	Check if current word is a token.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;					Check if current is a token. If so CS else CC
;
; ******************************************************************************

TOKCheckIsToken:
		set16 	zTemp0,KeywordText 			; position in table
		stz 	zTemp1 						; best match length
		stz 	zTemp2 						; current token.
		;
		;		Token check loop.
		;
_TCTLoop:
		ldy 	#1 							; position to start comparing
		phx 								; save start
		;
_TCTCompare:
		lda 	(zTemp0),y 					; compare the characters using EOR.
		eor 	InputBuffer,x 				; because bit 7 of keyword table => end of word.
		inx 								; bump both pointers.
		iny
		asl 	a 							; A will now be 0 if the same. CS => end.
		bne 	_TCTNext 					; different, go to next.
		bcc 	_TCTCompare 				; still comparing.
		;
		lda 	(zTemp0) 					; get current length
		cmp 	zTemp1						; best so far
		bcc 	_TCTNext 					; if not, skip to next.
		;
		sta 	zTemp1 						; new best score
		lda 	zTemp2 						; copy current token to result
		sta 	zTemp2+1
		;
_TCTNext:
		plx 								; restore start position.
		inc 	zTemp2 						; increment current token.
		lda 	(zTemp0) 					; add the length + 1 to the keyword pointer
		sec
		adc 	zTemp0
		sta 	zTemp0
		bcc		_TCTNoCarry
		inc 	zTemp0+1
_TCTNoCarry:
		lda 	(zTemp0)					; have we finished ?
		bne 	_TCTLoop 					; no, check the next keyword.
		;
		clc
		lda 	zTemp1 						; best length is zero, exit with CC
		beq 	_TCTExit
		;
		txa 								; add that length to the input index.
		clc
		adc 	zTemp1
		tax
		;
		lda 	zTemp2+1 					; token number
		jsr 	TOKWriteToken 				; write it out.
		sec 								; set carry and exit
_TCTExit:
		rts		