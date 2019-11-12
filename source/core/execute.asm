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
		.byte 	$FF
		bra 	ExecuteLoop

ExecuteToken:

ExecuteLoop:




ShortReadHandler:
LongReadHandler:
