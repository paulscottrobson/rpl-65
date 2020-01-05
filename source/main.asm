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

		;.include "tokenise/test.asm"		; uncomment this to test the tokeniser code.

		jsr 	ExternInitialise			; set up external stuff.

		ldx 	#BootPrompt & $FF 			; print start up.
		ldy 	#BootPrompt >> 8
		jsr 	PrintStringXY
		ldx 	#(HighMemory-ProgramStart) & $FF
		ldy 	#(HighMemory-ProgramStart) >> 8
		jsr 	PrintIntegerUnsigned
		ldx 	#BootPrompt2 & $FF
		ldy 	#BootPrompt2 >> 8
		jsr 	PrintStringXY

		;jmp 	ExecuteProgram 				; uncomment to run included program straight off.

		;
		;		Main Warm Start loop
		;
WarmStart:
		ldx 	#$FF 						; reset the stack.
		txs
		jsr 	ExternInput					; input a line.
		pha
		jsr 	TokeniseInputBuffer 		; tokenise it
		pla 
		cmp 	#" "						; if the first character is space always execute it
		beq 	ExecuteLine
		;
		lda 	TokenBuffer+3 				; is the first thing a line number
		cmp 	#KWD_SYS_CONST
		beq 	LineNumber
		and 	#$C0
		cmp 	#$80
		beq 	LineNumber
		;
		;		Execute the tokenised line.
		;
ExecuteLine:
		ldx 	#TokenBuffer & $FF
		ldy 	#TokenBuffer >> 8
		jmp 	ExecuteFromXY		
		;
		;		Line number.
		;
LineNumber:
		lda 	TokenBuffer+3 				; set up for short constant line#
		ldx 	#0
		ldy 	#4
		sec
		sbc 	#$80
		cmp 	#$40
		bcc 	_HaveLineNumber
		;
		lda 	TokenBuffer+4
		ldx 	TokenBuffer+5
		ldy 	#6
		;
		;		Have a line number. At this point XA is the number and
		;		Y is the index into the buffer of the code.
		;
_HaveLineNumber:
		pha 								; a fudge. Because you use
		lda 	TokenBuffer,y 				; nnn list so much, this forces
		cmp 	#KWD_LIST 					; this to be executed and not
		beq 	ExecuteLine 				; to be code. 
		pla
		jmp 	EditProgram
		
BootPrompt:
		.text 	"*** RPL/65 (19-NOV-19) ***",13,13
		.byte 	0
BootPrompt2:
		.text 	" BYTES AVAILABLE.",13,13,0

		.include "generated/rpl.inc"
		.include "generated/assembler.inc"
		
		.include "core/error.asm"
		.include "core/execute.asm"
		.include "core/extern.asm"
		.include "core/index.asm"
		.include "core/program.asm"
		.include "core/reset.asm"
		.include "core/stack.asm"
		.include "core/tointeger.asm"
		.include "core/tostring.asm"
		.include "core/variables.asm"
		
		.include "tokenise/tokeniser.asm"
		.include "tokenise/tok_check_call.asm"
		.include "tokenise/tok_const.asm"
		.include "tokenise/tok_def.asm"
		.include "tokenise/tok_cst.asm"
		.include "tokenise/tok_token.asm"

		.include "words/list.asm"
		.include "words/memory.asm"
		.include "words/saveload.asm"
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
