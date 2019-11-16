; ******************************************************************************
; ******************************************************************************
;
;		Name : 		error.asm
;		Purpose : 	Error Handler.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

SyntaxError:		
		rerror 	"SYNTAX"

; ******************************************************************************
;
;								Handle Errors
;
; ******************************************************************************

ErrorHandler:
		plx 								; pull address off.
		ply		
		inx 								; point to message
		bne 	_EHNoCarry
		iny
_EHNoCarry:		
		jsr 	PrintStringXY 				; print string at XY
		lda 	(codePtr) 					; gone off the end, like in structures ?
		beq 	_EHNoLine
		ldx 	#_EHMessage & $FF 			; print " AT "
		ldy 	#_EHMessage >> 8
		jsr 	PrintStringXY
		ldy 	#1 							; line# into YX.
		lda 	(codePtr),y
		tax
		iny
		lda 	(codePtr),y
		tay
		jsr 	PrintIntegerUnsigned
_EHNoLine:
		lda 	#13
		jsr 	PrintCharacter
		jmp 	WarmStart

_EHMessage:
		.text	" AT ",0

; ******************************************************************************
;
;				Print unsigned integer, return print count in A
;
; ******************************************************************************

PrintIntegerUnsigned:
		jsr 	IntToString
		ldx 	#ConvertBuffer & $FF 		; print number
		ldy 	#ConvertBuffer >> 8
		jsr 	PrintStringXY
		tya
		rts

; ******************************************************************************
;
;							Print String at (Y,X)
;
; ******************************************************************************

PrintStringXY:
		stx 	zTemp0
		sty 	zTemp0+1
		ldy 	#0
_PSLoop:lda 	(zTemp0),y
		beq 	_PSExit
		jsr 	PrintCharacter
		iny
		bra 	_PSLoop
_PSExit:rts

; ******************************************************************************
;
;							Print Character in A
;
; ******************************************************************************

PrintCharacter:
		pha
		phx
		phy
		jsr 	$FFD2
		ply
		plx
		pla
		rts

		