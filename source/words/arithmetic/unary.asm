; ******************************************************************************
; ******************************************************************************
;
;		Name : 		unary.asm
;		Purpose : 	Unary functions
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;									Unary Absolute
;
; ******************************************************************************

Unary_Absolute: 	;; [abs]
		StartCommand
		lda 	highStack,x
		bmi 	Unary_Negate_Code
		NextCommand
		
; ******************************************************************************
;
;									Unary Negation
;
; ******************************************************************************

Unary_Negate: 	;; [negate]
		StartCommand
Unary_Negate_Code:		
		sec
		lda		#0
		sbc 	lowStack,x
		sta 	lowStack,x
		;
		lda		#0
		sbc 	highStack,x
		sta 	highStack,x
		NextCommand

; ******************************************************************************
;
;									Unary 1's Complement
;
; ******************************************************************************

Unary_Not: 	;; [not]
		StartCommand
		lda 	lowStack,x
		eor 	#$FF
		sta 	lowStack,x
		;
		lda 	highStack,x
		eor 	#$FF
		sta 	highStack,x
		NextCommand

; ******************************************************************************
;
;									Unary Increment
;
; ******************************************************************************

Unary_Increment: ;; [++]
		StartCommand
		inc 	lowStack,x
		bne 	_UIExit
		inc 	highStack,x
_UIExit:
		NextCommand		

; ******************************************************************************
;
;									Unary Increment
;
; ******************************************************************************

Unary_Decrement: ;; [--]
		StartCommand
		lda 	lowStack,x
		bne 	_UDNoBorrow
		dec 	highStack,x
_UDNoBorrow:	
		dec 	lowStack,x
		NextCommand

; ******************************************************************************
;
;								  		Byte Swap
;
; ******************************************************************************

Unary_BSwap: ;; [bswap]
		StartCommand
		lda 	lowStack,x
		pha
		lda 	highStack,x
		sta 	lowStack,x
		pla
		sta 	highStack,x
		NextCommand		

; ******************************************************************************
;
;								  Left Shift Logical
;
; ******************************************************************************

Unary_Shl: ;; [<<]
		StartCommand
		asl 	lowStack,x
		rol 	highStack,x
		NextCommand		

; ******************************************************************************
;
;								  Right Shift Logical
;
; ******************************************************************************

Unary_Shr: ;; [>>]
		StartCommand
		lsr 	highStack,x
		ror 	lowStack,x
		NextCommand		

; ******************************************************************************
;
;								  	Sign of TOS
;
; ******************************************************************************

Unary_Sgn: ;; [sgn]
		StartCommand
		lda 	highStack,x 				; check bit 7.
		bpl 	_USNotNeg
		lda 	#$FF 						; if -ve set to -1
		sta 	lowStack,x
		sta 	highStack,x
		bra 	_USExit
;
_USNotNeg:
		ora 	lowStack,x 					; A = Low|High
		stz 	lowStack,x 					; Zero result
		stz 	highStack,x
		cmp 	#0 							; if 0 return 0
		beq 	_USExit
		inc 	lowStack,x 					; else return 1.
_USExit:
		NextCommand

; ******************************************************************************
;
;						  Unary Random Number Generator
;
; ******************************************************************************

Random_Handler: ;; [rnd]
		StartCommand
		lda 	randomSeed
		ora 	randomSeed+1
		bne 	_RH_NoInit
		lda 	#$7C
		sta 	randomSeed
		lda 	#$A1
		sta 	randomSeed+1
_RH_NoInit:
		lda 	randomSeed
        lsr		a
        rol 	randomSeed+1  
        bcc 	_RH_NoEor
        eor 	#$B4 
_RH_NoEor: 
        sta 	randomSeed
        eor 	randomSeed+1  
        ;
        inx
        sta 	highStack,x
        lda 	randomSeed
        sta 	lowStack,x
		NextCommand
