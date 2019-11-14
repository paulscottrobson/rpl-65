; ******************************************************************************
; ******************************************************************************
;
;		Name : 		main.asm
;		Purpose : 	RPL/65 Main Program
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

		.include "data.asm"
		.include "macros.inc"
		
		* = $0E00 							; just for booting.
		jmp 	Start

		* = ProgramStart
		.include "generated/program.inc"

		* = BuildAddress
Start:
		ldx 	#$FF 						; reset the stack.
		txs

		.include "tokenise/test.asm"		; uncomment this to test the tokeniser code.

		jsr 	ExternInitialise		
		jmp 	ExecuteProgram

WarmStart:
		.byte 	$FF
		ldx 	#$55
		.include "generated/rpl.inc"

		.include "core/error.asm"
		.include "core/execute.asm"
		.include "core/extern.asm"
		.include "core/index.asm"
		.include "core/reset.asm"
		.include "core/stack.asm"
		.include "core/tointeger.asm"
		.include "core/tostring.asm"
		.include "core/variables.asm"
		
		.include "tokenise/tokeniser.asm"
		.include "tokenise/tok_const.asm"
		.include "tokenise/tok_def.asm"
		.include "tokenise/tok_cst.asm"
		
		.include "words/list.asm"
		.include "words/memory.asm"
		.include "words/stack.asm"
		.include "words/store.asm"
		.include "words/system.asm"
		
		.include "words/arithmetic/binary.asm"
		.include "words/arithmetic/compare.asm"
		.include "words/arithmetic/divide.asm"
		.include "words/arithmetic/multiply.asm"
		.include "words/arithmetic/unary.asm"		
		
		.include "words/structures/call.asm"
		.include "words/structures/if.asm"
		.include "words/structures/repeat.asm"
		.include "words/structures/for.asm"

