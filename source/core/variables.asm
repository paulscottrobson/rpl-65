; ******************************************************************************
; ******************************************************************************
;
;		Name : 		variables.asm
;		Purpose : 	Variable management
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;		Find the variable at (codePtr),y. On entry the carry is set if 
;		you want the variable created if it is not found. In this case
;		codePtr must be in the program area.
;
;		Returns the calculated address in zTemp0. The stack is at X on entry.
;
; ******************************************************************************

VariableFind:
		phx 								; save the stack position
		php 								; save the create flag
		lda 	(codePtr),y 				; get the first identifier character
		cmp 	#$E0						; if it is E0-FF the first is the last
		bcc		_VFIsNotFastVariable 		; so it is a fast variable.
		;
		and 	#$1F 						; make it an offset
		asl 	a 							; double clear carry
		adc 	#FastVariables & $FF 		; put the final address in zTemp0
		sta 	zTemp0
		lda		#FastVariables >>8
		sta 	zTemp0+1
		plp 								; create flag is irrelevant.
		plx									; restore the old stack position
		iny 								; skip over the single identifier character
		rts
		;
		;		It's not A-Z. So look it up in the hash tables
		;
_VFIsNotFastVariable:
		jsr 	VFSetupHashPointer 			; set up the hash pointer
		jsr 	VFSearch 					; try to find the variable.
		.byte 	$FF
		bcs 	_VFEndSearch 				; found it, so exit
		;
		;		The identifier is not known
		;
		plp 								; do we want autocreate
		bcs 	_VFCreate
		rerror 	"VARIABLE?"					; no, then we have no idea.
_VFCreate:
		jsr 	VFSetupHashPointer 			; reset the hash pointer
		jsr 	VFCreate 					; create a new record and link it in.
		php 								; save a dummy P to be popped.
		;
		;		Exit. zTemp1 points to the variable record, so set zTemp0 to
		;		point to the data. Drop the flag, skip the identifier and exit.
		;
_VFEndSearch:
		clc 								; the data is at offset + 4
		lda 	zTemp1 					
		adc 	#4
		sta 	zTemp0
		lda 	zTemp1+1
		adc 	#0
		sta 	zTemp0+1
		;		
		plp 								; dump the create flag
		;
		;		Skip over identifier and exit
		;
_VFSkipExit:
		lda 	(codePtr),y 				; keep read and skip until end-identifier.
		iny
		cmp 	#$E0
		bcc 	_VFSkipExit
		plx 								; restore X
		rts

; ******************************************************************************
;
;		Search the linked list starting at (zTemp1) for the identifier
;		at (codePtr),y. Return CS and zTemp1 pointing to record if succeeded
;		CC if failed.
;
; ******************************************************************************

VFSearch:
		pha 								; save AXY.
		phx
		phy
		;
		tya									; add Y to codePtr, put in zTemp2
		clc 								; so it points to the identifier.
		adc 	codePtr
		sta 	zTemp2
		lda 	codePtr+1
		adc 	#0
		sta 	zTemp2+1
		;
		;		Check next link.
		;
_VFSLoop:
		ldy 	#1 							; get MSB of next.
		lda 	(zTemp1),y 					; if this is zero, then end link (0)
		beq 	_VFSFailed 					; failed.
		tax 								; MSB in X
		lda 	(zTemp1) 					; LSB in A
		sta 	zTemp1 						; and update to the next record.
		stx 	zTemp1+1
		;
		ldy 	#2 							; put the name pointer in zTemp3
		lda 	(zTemp1),y
		sta 	zTemp3
		iny
		lda 	(zTemp1),y
		sta 	zTemp3+1
		;
		ldy 	#255 						; now compare the identifiers.		
_VFSCheckName:		
		iny
		lda 	(zTemp2),y 					; if different, try next
		cmp 	(zTemp3),y
		bne 	_VFSLoop 
		cmp 	#$E0 						; is it the ending identifier token
		bcc 	_VFSCheckName
		sec 								; return with Carry set, and zTemp1 set up
		bra		_VFSExit

_VFSFailed: 								; return carry clear/fail.
		clc
_VFSExit:
		ply 								; restore registers and exit.
		plx
		pla
		rts

; ******************************************************************************
;
;		Create a new variable & initialise ; identifier at (codePtr),y.
;		Initialise it, link it into the hash table.
;
; ******************************************************************************

VFCreate:
		pha 								; save registers
		phx
		phy
		clc 								; add 6 to memVarPtr, saving its
		lda 	memVarPtr 					; address in zTemp1 as we go.
		sta 	zTemp1
		adc 	#6
		sta 	memVarPtr
		lda 	memVarPtr+1
		sta 	zTemp1+1
		adc 	#0
		sta 	memVarPtr+1
		;
		ply
		plx
		pla
		rts

; ******************************************************************************
;
;					Set up the Hash table address in zTemp1.
;
; ******************************************************************************

VFSetupHashPointer:
		pha
		lda 	(codePtr),y 				; get first character
		and 	#(HashTableSize-1) 			; make it in range 0..hash-1
		asl 	a 							; double it, also clears carry
		adc 	#VariableHashTable & $FF 	; add to the base and store in zTemp1
		sta 	zTemp1
		lda 	#VariableHashTable >> 8
		sta 	zTemp1+1
		pla
		rts