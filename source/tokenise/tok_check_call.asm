; ******************************************************************************
; ******************************************************************************
;
;		Name : 		tok_check_call.asm
;		Purpose : 	Check to see if a tokenised identifier is a call.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	16th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;		On entry, A is an offset in the token buffer which points to an
;		identifier. Check to see if this identifier is in fact a call,
;		and if so convert it.
;
; ******************************************************************************

TOKCheckIdentifierIsCall:
		pha
		phx
		phy
		sta 	zTemp1
		set16 	zTemp0,ProgramStart
		;
		;		Check Loop
		;
_TKCIILoop:
		lda 	(zTemp0) 					; reached the end
		beq 	_TKCIIExit
		ldy 	#3							; check if definition
		lda 	(zTemp0),y
		cmp 	#KWD_SYS_DEFINE
		bne 	_TKCIINext 					; if not skip.
		ldx 	zTemp1 						; position of identifier.
		iny 								; skip count
_TKCIICheck:
		iny
		lda 	TokenBuffer,x 				; compare identifiers
		cmp 	(zTemp0),y
		bne 	_TKCIINext
		inx
		cmp 	#$E0						; go back if not end identifier.
		bcc 	_TKCIICheck 					
		;
		lda 	zTemp1 						; get identifier position
		sta 	TokenOffset 				; reset it.
		lda 	#KWD_SYS_CALL 				; write call 
		jsr 	TOKWriteToken
		ldy 	#1
		lda 	(zTemp0),y
		jsr 	TOKWriteToken
		iny
		lda 	(zTemp0),y
		jsr 	TOKWriteToken
		bra 	_TKCIIExit 					; and exit.
		
_TKCIINext:									; go to next program line.
		clc
		lda 	(zTemp0)		
		adc 	zTemp0
		sta 	zTemp0
		bcc 	_TKCIILoop
		inc 	zTemp0+1
		bra 	_TKCIILoop

_TKCIIExit:		
		ply
		plx
		pla
		rts
