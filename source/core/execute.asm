; ******************************************************************************
; ******************************************************************************
;
;		Name : 		execute.asm
;		Purpose : 	Main execution loop.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;								Run a new program
;
; ******************************************************************************

ExecuteProgram:
		set16 	FastVariables+2,$ABCD

		jsr 	StackReset 					; reset the CPU stack.
		jsr 	ResetMemory 				; reset alloc pointers, variables etc.
		ldx 	#$FF 						; empty the data stack
		bra 	ExecuteLoop
		;
		;		Handle short constant
		;
ShortConstant:		
		iny 								; skip short const
		inx 								; space on stack
		and 	#$3F 						; the value
		sta 	lowStack,x 					; put on stack..
		stz 	highStack,x
		;
		;		Main execution loop
		;
ExecuteLoop:
		lda 	(codePtr),y 				; get next character
		bmi 	_ELNotToken
		iny 								; skip the token
		phx 								; save X on the stack
		asl 	a 							; double the token, put into X
		tax
		jmp 	(DispatchHandler,x)
_ELNotToken:		
		cmp 	#$C0 						; is it 80-BF
		bcc 	ShortConstant 				; yes, it's a short constant
		;
		;		Handle variable.
		;
		cmp 	#$E0 						; is it E0-FF - i.e. it is one letter variable.
		bcc 	_ELNotFastVariable
		iny 								; get the next token.
		lda 	(codePtr),y
		dey
		cmp 	#KWD_LSQPAREN 				; if not [ then it is a simple variable
		beq 	_ELNotFastVariable 			; which we can optimise.
		;
		phy 								; save Y
		lda 	(codePtr),y 				; variable E0-FF
		asl 	a 							; it is now C0-FE, steps of 2.
		tay 								; access via Y
		inx 								; make space on the stack.
		lda 	FastVariables-$C0,y 		; copy the fast variable
		sta 	lowStack,x
		lda 	FastVariables-$C0+1,y
		sta 	highStack,x
		ply 								; restore code pointer
		iny 								; skip variable.
		bra 	ExecuteLoop
		;
		;		It is either a single variable indexed, or a long variable name
		;		which may or may not be indexed.
		;
_ELNotFastVariable:		
		clc									; do not autocreate if not found.
		jsr 	VariableFind				; find the variable.
		bcc 	_ELUnknown
		phy 								; copy to stack
		inx
		lda 	(zTemp0)
		sta 	lowStack,x
		ldy 	#1
		lda 	(zTemp0),y
		sta 	highStack,x
		ply
		bra 	ExecuteLoop
_ELUnknown:
		.byte 	$FF
		rerror 	"UNKNOWN?"

; ******************************************************************************
;
;							Advance to next line.
;
; ******************************************************************************

ExecuteNextLine:	;; [%eol]
ExecuteComment:		;; [%comment]
		StartCommand
		clc 								; skip forward
		lda 	(codePtr)
		clc
		adc 	codePtr
		sta 	codePtr
		bcc 	_ENLNoCarry
		inc 	codePtr+1
_ENLNoCarry:				
		ldy 	#3 							; start of next line
		lda 	(codePtr) 					; check offset non zero
		bne 	ExecuteLoop
		jmp	 	Command_End 				; if zero end program.

; ******************************************************************************
;
;								Long Constant
;
; ******************************************************************************

LongConstant:		;; [%const]
		StartCommand
		inx 								; space for constant
		lda 	(codePtr),y 				; copy it in.
		sta 	lowStack,x
		iny
		lda 	(codePtr),y
		sta 	highStack,x
		iny
		NextCommand

; ******************************************************************************
;
;					String. Strings are Length Prefixed
;
; ******************************************************************************

StringConstant:	 ;; [%qstring]
		StartCommand
		inx
		clc 								; copy Y + codePtr in.
		tya
		adc 	codePtr 					
		sta 	lowStack,x
		lda 	codePtr+1
		adc 	#0
		sta 	highStack,x
		;
		tya 								; add 1 + length to Y
		sec
		adc 	(codePtr),y
		tay
		NextCommand

