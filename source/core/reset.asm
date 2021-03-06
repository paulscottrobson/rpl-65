; ******************************************************************************
; ******************************************************************************
;
;		Name : 		reset.asm
;		Purpose : 	Reset Storage
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;						Reset memory to YX for running
;
; ******************************************************************************

ResetMemory:
		phx									; save run address
		phy 	
		;
		;		Reset allocation pointer
		;
		set16 	allocPtr,highMemory
		;
		;		Find end of program, set variable allocation pointer.
		;
		jsr 	ResetVarMemory
		;
		;		Erase hash table.
		;
		ldx 	#HashTableSize*2-1 			; bytes to erase
_RMEraseHash:
		stz 	VariableHashTable,x
		dex
		bpl 	_RMEraseHash
		;
		;		Reset code pointer
		;
		ply 								; restore and set run address
		plx
		sty 	codePtr+1
		stx 	codePtr
		ldy 	#3
		rts

; ******************************************************************************
;
;				Reset memVarPtr to point to end of program + 1
;
; ******************************************************************************

ResetVarMemory:
		set16 	memVarPtr,ProgramStart
_RMFindEnd:
		lda 	(memVarPtr)					; offset 0, found end.
		beq 	_RMFoundEnd 				; advance to next.
		clc
		adc 	memVarPtr
		sta 	memVarPtr
		bcc 	_RMFindEnd
		inc 	memVarPtr+1
		bra 	_RMFindEnd
_RMFoundEnd:
		inc 	memVarPtr 					; advance past last offset $00
		bne 	_RMNoCarry
		inc 	memVarPtr+1
_RMNoCarry:		
		rts