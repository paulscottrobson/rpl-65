; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		repeat.asm
;		Purpose :	Repeat/Until
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Date : 		13th November 2019
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;										Repeat
;
; *******************************************************************************************

Struct_Repeat: ;; [repeat]
		StartCommand
		jsr 	StackPushPosition 				; save stack position
		lda 	#KWD_REPEAT 					; push repeat marker
		jsr 	StackPushByte
		NextCommand

; *******************************************************************************************
;
;										Until
;
; *******************************************************************************************

Struct_Until: ;; [until]		
		StartCommand
		lda 	#KWD_REPEAT 					; check it's a repeat
		jsr 	StackCheckTop
		bcc 	_SUFail
		;
		lda		lowStack,x						; check it was zero ?
		ora 	highStack,x
		dex
		ora 	#0
		beq 	_SULoopBack 					; if so keep going.
		;
		lda 	#4 								; pop 4 bytes off the stack
		jsr 	StackPop 	
		NextCommand
		;
_SULoopBack:		
		ldy 	#1 								; transfer to position at (iStack),y
		jsr 	StackRestorePosition
		NextCommand

_SUFail:rerror 	"NO REPEAT"