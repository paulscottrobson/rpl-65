; ******************************************************************************
; ******************************************************************************
;
;		Name : 		system.asm
;		Purpose : 	System Commands
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	13th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;							 NEW erase program
;
; ******************************************************************************

Command_New: ;; [new]
		StartCommand
		stz 	ProgramStart
		jmp 	WarmStart
		
; ******************************************************************************
;
;							 OLD unerase program
;
; ******************************************************************************

Command_Old: ;; [old]
		StartCommand
		set16 	codePtr,ProgramStart 		; try and find first line.
		ldy 	#3
_COAdvance:	
		cpy 	#192 						; first lines > this can't be recovered
		bcs		_COFail
		jsr 	AdvanceInCode
		lda 	(codePtr),y
		bne 	_COAdvance
		iny 								; byte after end of line
		sty 	ProgramStart 				; overwrite first byte with offset.
_CONotDeleted:		
		jmp 	WarmStart		
_COFail:rerror	"CANT?"

; ******************************************************************************
;
;								END program
;
; ******************************************************************************

Command_End: ;; [end]
		StartCommand
		jmp 	WarmStart

; ******************************************************************************
;
;							  STOP with error
;
; ******************************************************************************

Command_Stop: ;; [stop]
		.byte 	$FF
		StartCommand
		rerror 	"STOP"

; ******************************************************************************
;
;								ASSERT
;
; ******************************************************************************

Command_Assert: ;; [assert]
		StartCommand
		lda 	lowStack,x 					; check TOS = 0 ?
		ora 	highStack,x
		beq 	_CAFail
		dex 								; throw if not.
		NextCommand
_CAFail:
		rerror 	"ASSERT"

; ******************************************************************************
;
;							SYS Call M/C routine
;
; ******************************************************************************

Command_Sys: ;; [sys]
		StartCommand
		lda 	lowStack,x 					; save call address
		sta 	zTemp0
		lda 	highStack,x
		sta 	zTemp0+1
		dex 								; pop tos
		phx 								; save XY
		phy
		lda 	FastVariables+('A'-'A'+1)*2 ; load AXY
		ldx 	FastVariables+('X'-'A'+1)*2 
		ldy 	FastVariables+('Y'-'A'+1)*2 
		jsr 	_CSCallInd
		ply 								; restore XY
		plx
		NextCommand
_CSCallInd:
		jmp 	(zTemp0)		

; ******************************************************************************
;
;								Stack Dump
;
; ******************************************************************************

Command_DumpStack: ;; [?]
		StartCommand
		phx 								; save pos and sp
		phy
		stx 	SignCount
		ldx 	#$FF
_CDSLoop:
		cpx 	SignCount 					; done all ?
		beq 	_CDSExit 					
		inx
		phx 								; save SP
		lda 	highStack,x 				; get tos
		tay
		lda 	lowStack,x
		tax
		cpy 	#0
		bpl 	_CDSPositive
		lda 	#"-" 						; minus
		jsr 	PrintCharacter
		tya 								; negate YX
		eor 	#$FF
		tay
		txa 	
		eor 	#$FF
		tax
		inx
		bne 	_CDSPositive
		iny
_CDSPositive:
		jsr 	PrintIntegerUnsigned
		lda 	#" " 						; space
		jsr 	PrintCharacter
		plx
		bra 	_CDSLoop
_CDSExit:
		lda 	#"<"
		jsr 	PrintCharacter
		jsr 	PrintCharacter
		lda 	#13 						; CR
		jsr 	PrintCharacter
		ply
		plx
		NextCommand
