; ******************************************************************************
; ******************************************************************************
;
;		Name : 		test.asm
;		Purpose : 	Tokeniser test for RPL/65
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th November 2019
;
; ******************************************************************************
; ******************************************************************************
;
;		This file is included, and effectively takes over for testing
;		tokenisation.
;
			jmp 	TokTest1
		;
		;		Code to test: note, this must be upper case.
		;
TokenCode:	

		.text 	"  42 $5A7 4- 32767 :HEL.LO :TEST.DEFINE"
		.text 	'"STRING" ""'
		.text 	"IF ++ + DE.MO REPEAT ORCHID"
		.text 	"'COMMENT"

		.byte 	0			
;
TokTest1:
		ldx 	#255 						; copy to input buffer.
_TT1Copy:
		inx
		lda 	TokenCode,x
		sta	 	InputBuffer,x
		bne 	_TT1Copy
		;
		jsr 	TokeniseInputBuffer
_TT1Halt:
		bra 	_TT1Halt		





