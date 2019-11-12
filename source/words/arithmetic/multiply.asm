; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		multiply.asm
;		Purpose :	Multiply 16 bit integers
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; *******************************************************************************************
; *******************************************************************************************

MulInteger16: ;; [*]
		StartCommand
		dex

		lda 	lowStack,x					; copy to workspace
		sta 	zTemp1
		lda 	highStack,x			
		sta 	zTemp1+1
		;
		stz 	lowStack,x 					; zero where the result goes.
		stz 	highStack,x
		;
_BFMMultiply:
		lda 	zTemp1 						; get LSBit 
		and 	#1
		beq 	_BFMNoAdd

		clc 								; add old tos to current tos.
		lda		lowStack,x
		adc 	lowStack+1,x
		sta 	lowStack,x
		;
		lda		highStack,x
		adc 	highStack+1,x
		sta 	highStack,x

_BFMNoAdd:
		;
		asl 	lowStack+1,x 				; shift left
		rol 	highStack+1,x
		;
		lsr 	zTemp1+1 					; shift right
		ror 	zTemp1+0
		;
		lda 	zTemp1 						; continue if is nonzero
		ora 	zTemp1+1
		bne 	_BFMMultiply
		;
		NextCommand
