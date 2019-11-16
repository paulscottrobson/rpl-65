; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		saveload.asm
;		Purpose :	Save/Load program
;		Date :		16th November 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									Save Program
;
; *******************************************************************************************

System_Save: ;; [save]
		StartCommand
		phx

		jsr 	ResetVarMemory 				; make sure start/end are right
		jsr 	SLGetFileName 				; get filename -> zTemp0

		lda 	memVarPtr 					; end address
		sta 	zTemp1
		lda 	memVarPtr+1
		sta 	zTemp1+1

		lda 	#ProgramStart & $FF 		; program start to YA
		ldy 	#ProgramStart >> 8
		jsr 	ExternSave

		ply
		jmp 	WarmStart

; *******************************************************************************************
;
;									Load Program
;
; *******************************************************************************************

System_Load: ;; [load]
		StartCommand
		jsr 	SLGetFileName 				; get filename -> zTemp0
		lda 	#ProgramStart & $FF 		; program start to YA
		ldy 	#ProgramStart >> 8
		jsr 	ExternLoad
		jsr 	ResetMemory 				; reset everything.
		jmp 	WarmStart
		
; *******************************************************************************************
;
;							Get filename -> zTemp1
;
; *******************************************************************************************

SLGetFileName:
		cpx 	#255 						; gotta be something on the stack
		beq 	_SLFNFail
		lda 	highStack,x 				; should be something in token buffer
		cmp 	#TokenBuffer >> 8
		bne 	_SLFNFail
		sta 	zTemp1+1 					; copy the filename address to zTemp0/1
		lda 	lowStack,x
		sta 	zTemp1

		lda 	#InputBuffer & $FF 			; f/n in input buffer.
		sta 	zTemp0
		lda 	#InputBuffer >> 8
		sta 	zTemp0+1

		lda 	(zTemp1) 					; copy string to input buffer
		inc 	a
		tax
		ldy 	#0
_SLCopy:lda 	(zTemp1),y
		sta 	(zTemp0),y
		iny
		dex 
		bne 	_SLCopy
		ldx 	#3 							; check if it ends in .RPL
_SLCheckEnd:
		dey
		lda 	_SLFNExtension,x
		cmp 	(zTemp0),y
		bne 	_SLNoExtension
		dex
		bpl 	_SLCheckEnd
		bra 	_SLExit
_SLNoExtension:
		ldy 	#0							; add the extension.
_SLExtend:
		inc 	InputBuffer
		ldx 	InputBuffer
		lda 	_SLFNExtension,y
		iny
		sta 	InputBuffer,x
		cmp		#0
		bne 	_SLExtend 	
		dec 	InputBuffer 				; because wrote the $00
_SLExit:		
		rts

_SLFNFail:
		rerror	"BAD FILENAME"
_SLFNExtension:
		.text 	".RPL",0
		