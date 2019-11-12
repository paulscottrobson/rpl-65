; ******************************************************************************
; ******************************************************************************
;
;		Name : 		stack.asm
;		Purpose : 	Interpreter Stack 
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;								Reset stack
;
; ******************************************************************************

StackReset:
		lda 	#IntStack & $FF 			; reset SP
		sta 	iStack
		lda 	#IntStack >> 8
		sta 	iStack+1
		lda 	#STM_TOP					; dummy TOS value
		sta 	(iStack)
		rts

; ******************************************************************************
;
;							Push byte on stack
;
; ******************************************************************************

StackPushByte:
		dec 	iStack
		sta 	(iStack)
		beq 	_SPBUnderflow
		rts
_SPBUnderflow:
		rerror 	"STACK"

; ******************************************************************************
;
;					  Push current position on stack
;
; ******************************************************************************

StackPushPosition:
		tya
		jsr 	StackPushByte
		lda 	codePtr+1
		jsr 	StackPushByte
		lda 	codePtr
		jsr 	StackPushByte
		rts

; ******************************************************************************
;
;					 Check TOS, returns CS if okay, CC fail
;
; ******************************************************************************

StackCheckTop:
		cmp 	(iStack)
		beq 	_SCTOk
		clc
		rts
_SCTOk:	sec
		rts

; ******************************************************************************
;
;							Pop Bytes off Stack
;
; ******************************************************************************

StackPop:
		clc
		adc 	iStack
		sta 	iStack
		rts

; ******************************************************************************
;
;						Restore code position from (iStack),y
;
; ******************************************************************************

StackRestorePosition:
		lda 	(iStack),y
		sta 	codePtr
		iny
		lda 	(iStack),y
		sta 	codePtr+1
		iny
		lda 	(iStack),y
		tay
		rts
