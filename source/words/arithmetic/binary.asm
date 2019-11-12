; ******************************************************************************
; ******************************************************************************
;
;		Name : 		binary.asm
;		Purpose : 	Simple Binary Functions
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;								Add top two values
;
; ******************************************************************************

Stack_Add: 	;; [+]
		StartCommand
		dex
		clc
		lda		lowStack,x
		adc 	lowStack+1,x
		sta 	lowStack,x
		;
		lda		highStack,x
		adc 	highStack+1,x
		sta 	highStack,x
		NextCommand

; ******************************************************************************
;
;								Sub top two values
;
; ******************************************************************************

Stack_Sub: 	;; [-]
		StartCommand
		dex
		sec
		lda		lowStack,x
		sbc 	lowStack+1,x
		sta 	lowStack,x
		;
		lda		highStack,x
		sbc 	highStack+1,x
		sta 	highStack,x
		NextCommand

; ******************************************************************************
;
;								And top two values
;
; ******************************************************************************

Stack_And: 	;; [and]
		StartCommand
		dex
		lda		lowStack,x
		and		lowStack+1,x
		sta 	lowStack,x
		;
		lda		highStack,x
		and 	highStack+1,x
		sta 	highStack,x
		NextCommand

; ******************************************************************************
;
;								Xor top two values
;
; ******************************************************************************

Stack_Xor: 	;; [xor]
		StartCommand
		dex
		lda		lowStack,x
		eor		lowStack+1,x
		sta 	lowStack,x
		;
		lda		highStack,x
		eor 	highStack+1,x
		sta 	highStack,x
		NextCommand

; ******************************************************************************
;
;								Or top two values
;
; ******************************************************************************

Stack_Or: 	;; [or]
		StartCommand
		dex
		lda		lowStack,x
		ora		lowStack+1,x
		sta 	lowStack,x
		;
		lda		highStack,x
		ora 	highStack+1,x
		sta 	highStack,x
		NextCommand
		
; ******************************************************************************
;
;						Shift left/right multiple times
;
; ******************************************************************************

Stack_Shl: 	;; [shl]		
		StartCommand
		sec
		bra 	StackShift
Stack_Shr:	;; [shr]
		StartCommand
		clc
StackShift:
		php
		dex 
		lda 	lowStack+1,x 					; if the shift >= 32
		and 	#$E0 							; going to be zero.
		ora 	highStack+1,x		
		bne 	_SSZero
		;
_SSLoop:		
		dec 	lowStack+1,x 				; dec check count
		bmi 	_SSDone 					; completed ?
		plp 								; restore flag
		php	
		bcs 	_SSLeft 					; do either shift.
		lsr 	highStack,x
		ror 	lowStack,x
		bra 	_SSLoop
_SSLeft:		
		asl 	lowStack,x
		rol 	highStack,x
		bra 	_SSLoop
		;
_SSZero:									; zero TOS
		stz 	lowStack,x 					; too many shifts.
		stz 	highStack,x
_SSDone:
		plp 								; throw flag.
		NextCommand
