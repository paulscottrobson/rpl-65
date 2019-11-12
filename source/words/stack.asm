; ******************************************************************************
; ******************************************************************************
;
;		Name : 		stack.asm
;		Purpose : 	Stack Manipulation functions
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;								Clear Stack
;
; ******************************************************************************

Stack_Empty: 	;; [clr]
		StartCommand
		ldx 	#0
		NextCommand

; ******************************************************************************
;
;									Drop TOS
;
; ******************************************************************************

Stack_Drop: 	;; [drop]
		StartCommand
		dex
		NextCommand

; ******************************************************************************
;
;								  Duplicate TOS
;
; ******************************************************************************

Stack_Dup:		;; [dup]
		StartCommand
		lda 	lowStack,x					; copy to next up
		sta 	lowStack+1,x
		lda 	highStack,x
		sta 	highStack+1,x
		inx 								; bump stack pointer
		NextCommand

; ******************************************************************************
;
;									Nip 2nd on stack
;
; ******************************************************************************

Stack_Nip: 	;; [nip]
		StartCommand
		lda 	lowStack,x	 				; copy top to 2nd
		sta 	lowStack-1,x
		lda 	highStack,x
		sta 	highStack-1,x
		dex 								; drop tos
		NextCommand

; ******************************************************************************
;
;								Copy 2nd on stack to TOS
;
; ******************************************************************************

Stack_Over:		;; [over]
		StartCommand
		lda 	lowStack-1,x				; copy to next up
		sta 	lowStack+1,x
		lda 	highStack-1,x
		sta 	highStack+1,x
		inx 							; bump stack pointer
		NextCommand

; ******************************************************************************
;
;								Swap top two values
;
; ******************************************************************************

sswap:	.macro
		lda 	\1,x
		tay
		lda 	\1-1,x
		sta 	\1,x
		tya
		sta 	\1-1,x
		.endm

Stack_Swap:		;; [swap]
		StartCommand
		phy
		.sswap 	lowStack
		.sswap 	highStack
		ply
		NextCommand		

	