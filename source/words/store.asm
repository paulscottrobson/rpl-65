; ******************************************************************************
; ******************************************************************************
;
;		Name : 		store.asm
;		Purpose : 	Store to Memory 
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	13th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;								Store to memory
;
; ******************************************************************************

Command_Store: ;; [^]
		StartCommand
		lda 	(codePtr),y 				; next character
		cmp 	#$E0 						; is it a single letter variable ?
		bcc 	_CSLongVariable
		;
		;		Single variable
		;
		iny 								; get the next
		lda 	(codePtr),y
		dey
		cmp 	#KWD_LSQPAREN 				; followed by indexing, use long variable
		beq 	_CSLongVariable
		;
		lda 	(codePtr),y 				; get variable back.
		iny 								; skip over it and push on stack		
		phy
		asl 	a 							; double it, now C0-FE
		tay 								; put in Y
		;
		lda 	lowStack,x 					; copy TOS into it
		sta 	FastVariables-$C0,y
		lda 	highStack,x
		sta 	FastVariables-$C0+1,y
		dex 								; pop off stack
		ply 								; restore position and do next 
		NextCommand
		;
		;		Long named variable
		;
_CSLongVariable:		
		sec 								; create variable if not found.
		jsr 	VariableFind 				; find it - create if not - is in zTemp0
		jsr 	IndexCheck 					; check indexing.
		;
		lda 	lowStack,x					; write it out.
		sta 	(zTemp0)
		phy
		ldy 	#1
		lda 	highStack,x
		sta 	(zTemp0),y
		ply
		dex 								; pop off stack
		NextCommand 						; do next command.
