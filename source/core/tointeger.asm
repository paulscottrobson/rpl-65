; ******************************************************************************
; ******************************************************************************
;
;		Name : 		tointeger.asm
;		Purpose : 	Try to convert string to a constant integer.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;			Convert String YX to Integer in YX. CS = Okay, CC = Failed.
;
; ******************************************************************************

StringToInt:
		stx 	zTemp3 						; save string
		sty 	zTemp3+1

		ldx 	#16 						; base to use.
		ldy 	#1 							; character offset.
		;
		lda 	(zTemp3) 					; first character
		cmp 	#"$"						; is it hexadecimal
		beq 	_STIConvert 				; convert from character 1, base 16.
		;
		dey 								; from character 0
		ldx 	#10 						; base 10.
		cmp 	#"-"						; first char is unary minus ?
		bne 	_STIConvert 				; no, convert as +ve decimal
		;
		iny 								; skip the minus
		jsr 	_STIConvert 				; convert the unsigned part.
		bcc 	_STIExit 					; failed
		;
		txa 								; 1's complement YX
		eor 	#$FF
		tax
		tya
		eor 	#$FF
		tay
		;
		inx 								; +1 to make it negative
		sec
		bne 	_STIExit
		iny
_STIExit:
		rts		
;
;		Offset in token buffer in X, base to use in Y.
;
_STIConvert:		
		stx 	zTemp1 						; save base in zTemp1
		lda 	(zTemp3),y 					; get first character
		beq 	_STIFail 					; if zero, then it has failed anyway.
		;
		stz 	zTemp0 						; clear the result.
		stz 	zTemp0+1
		;
_STILoop:
		lda 	zTemp0 						; copy current to zTemp2
		sta 	zTemp2
		lda 	zTemp0+1
		sta 	zTemp2+1
		stz 	zTemp0 						; clear result
		stz 	zTemp0+1
		ldx 	zTemp1 						; X contains the base.
		;
_STIMultiply:
		txa 								; shift Y right into carry.
		lsr 	a
		tax
		bcc 	_STINoAdd 					; skip if CC, e.g. LSB was zero
		;
		clc
		lda 	zTemp2 						; add zTemp2 into zTemp0
		adc 	zTemp0
		sta 	zTemp0
		lda 	zTemp2+1
		adc 	zTemp0+1
		sta 	zTemp0+1
		;
_STINoAdd:
		asl 	zTemp2 						; shift zTemp2 left e.g. x 2
		rol 	zTemp2+1
		cpx 	#0 							; multiply finished ?
		bne 	_STIMultiply
		;
		lda 	(zTemp3),y 					; check in range 0-9 A-F
		and 	#$7F 						; remove End of Token bit if set
		cmp 	#"0"
		bcc 	_STIFail
		cmp 	#"9"+1
		bcc 	_STIOkay
		cmp 	#"A"
		bcc 	_STIFail
		cmp 	#"F"+1
		bcs 	_STIFail
		;
		sec 								; hex adjust
		sbc 	#7
_STIOkay:
		sec
		sbc 	#48
		cmp 	zTemp1  					; if >= base then fail.
		bcs 	_STIFail
		;
		cld
		adc 	zTemp0 						; add into the current value		
		sta 	zTemp0
		bcc 	_STINoCarry
		inc 	zTemp0+1
_STINoCarry:
		;
		lda 	(zTemp3),y					; get character just done.
		iny 								; point to next
		asl 	a 							; shift bit 7 into carry
		bcc 	_STILoop 					; not reached the end.
		;
		ldx 	zTemp0 						; return result
		ldy 	zTemp0+1
		sec
		rts

_STIFail:		
		clc
		rts

