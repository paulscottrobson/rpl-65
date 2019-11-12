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
		.byte 	$FF
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
		.byte 	$FF

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

