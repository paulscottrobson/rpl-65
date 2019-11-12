; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		divide.asm
;		Purpose :	Divide 16 bit integers
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Date : 		12th November 2019
;
; *******************************************************************************************
; *******************************************************************************************

DivInteger16: ;; [/] 
		StartCommand
		jsr 	IntegerDivide
		NextCommand

IntegerDivide:
		dex 

		lda 	lowStack+1,x 					; check for division by zero.
		ora 	highStack+1,x
		bne 	_BFDOkay
		rerror	"DIVISION BY ZERO"
		;
		;		Reset the interim values
		;
_BFDOkay:
		stz 	zTemp1 						; Q/Dividend/Left in +0
		stz 	zTemp1+1 					; M/Divisor/Right in +4
		stz 	SignCount 					; Count of signs.
		;
		;		Remove and count signs from the integers.
		;
		jsr 	CheckIntegerNegate 			; negate (and bump sign count)
		inx
		jsr 	CheckIntegerNegate
		dex

		phy 								; Y is the counter
		;
		;		Main division loop
		;
		ldy 	#16 						; 16 iterations of the loop.
_BFDLoop:
		asl 	lowStack,x 					; shift AQ left.
		rol 	highStack,x
		rol 	zTemp1
		rol 	zTemp1+1
		;
		sec
		lda 	zTemp1+0 					; Calculate A-M on stack.
		sbc 	lowStack+1,x
		pha
		lda 	zTemp1+1
		sbc 	highStack+1,x
		bcc 	_BFDNoAdd
		;
		sta 	zTemp1+1
		pla
		sta 	zTemp1+0
		;
		lda 	lowStack,x 					; set Q bit 1.
		ora 	#1
		sta 	lowStack,x
		bra 	_BFDNext
_BFDNoAdd:
		pla 								; Throw away the intermediate calculations
_BFDNext:									; do 32 times.
		dey
		bne 	_BFDLoop
		ply 								; restore Y
		;
		lsr 	SignCount 					; if sign count odd,
		bcs		IntegerNegateAlways 		; negate the result
		rts

; *******************************************************************************************
;
;						Check / Negate integer, counting negations
;
; *******************************************************************************************

CheckIntegerNegate:
		lda 	highStack,x 				; is it -ve = MSB set ?
		bmi 	IntegerNegateAlways 		; if so negate it
		rts
IntegerNegateAlways:
		inc 	SignCount 					; bump the count of signs
		jmp 	Unary_Negate
		
; *******************************************************************************************
;
;								Modulus uses the division code
;
; *******************************************************************************************

ModInteger16:	;; [mod]
		StartCommand
		jsr 	IntegerDivide
		lda 	zTemp1
		sta 	lowStack,x
		lda 	zTemp1+1
		sta 	highStack,x
		NextCommand
