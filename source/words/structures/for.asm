; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		for.asm
;		Purpose :	For/Next/Index
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Date : 		13th November 2019
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;										For
;
; *******************************************************************************************

Struct_For: ;; [for]
		StartCommand
		clc
		lda 	lowStack,x 					; push ~ count on the stack
		eor 	#$FF
		adc 	#1
		php
		jsr 	StackPushByte
		lda 	highStack,x
		eor 	#$FF
		plp
		adc 	#0
		jsr 	StackPushByte
		dex 									; throw TOS
		;
		jsr 	StackPushPosition 				; save stack position
		lda 	#KWD_FOR 						; push for marker
		jsr 	StackPushByte
		NextCommand

; *******************************************************************************************
;
;									Extract Loop Index
;
; *******************************************************************************************

Struct_Index: ;; [index]
		StartCommand
		lda 	#KWD_FOR 						; check it's a for
		jsr 	StackCheckTop
		bcc 	SNFail
		;
		inx 									; new stack entry
		phy
		ldy 	#4 								; access index value
		lda 	(iStack),y
		eor 	#$FF
		sta 	highStack,x
		iny
		lda 	(iStack),y
		eor 	#$FF
		sta 	lowStack,x
		ply 									; restore code pointer
		NextCommand
		
; *******************************************************************************************
;
;										Next
;
; *******************************************************************************************

Struct_Next: ;; [next]		
		StartCommand
		lda 	#KWD_FOR 						; check it's a for
		jsr 	StackCheckTop
		bcc 	SNFail
		;
		phy 									; save code position
		ldy 	#5 								; bump the count
		lda 	(iStack),y
		inc 	a
		sta 	(iStack),y
		bne 	_SNLoopBack
		dey
		lda 	(iStack),y
		inc 	a
		sta 	(iStack),y
		bne 	_SNLoopBack  					; non-zero loop back.
		;
		ply 									; restore code position.
		lda 	#6 								; pop 6 bytes off the stack
		jsr 	StackPop 	
		NextCommand
		;
_SNLoopBack:		
		ply 									; restore code position, being junked anyway.
		ldy 	#1 								; transfer to position at (iStack),y
		jsr 	StackRestorePosition
		NextCommand

SNFail:rerror 	"NO FOR"
