; ******************************************************************************
; ******************************************************************************
;
;		Name : 		compare.asm
;		Purpose : 	Simple Compare Functions
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;							Equal/NotEqual check.
;
; ******************************************************************************

Comp_Equal: 	;; [=]
		StartCommand
		sec
		bra 	Comp_CheckEqual

Comp_NotEqual:	;; [<>]
		StartCommand
		clc
		;
		;		$FF if not equal, $00 if equal, CS flips that.
		;
Comp_CheckEqual:
		php 		
		dex

		lda		lowStack,x
		eor 	lowStack+1,x
		bne 	_CCENonZero
		;
		lda		highStack,x
		eor 	highStack+1,x
_CCENonZero:	
		beq 	_CCENotSet
		lda 	#$FF 						; $FF if not-equal
_CCENotSet:
		;
		;		At this point, A is $00 or $FF. Popping P off the stack flips that
		;		if the carry flag is set.
		;
CompCheckFlip:		
		plp 								; if carry set, we want $FF if equal
		bcc 	CompReturn
		eor 	#$FF
CompReturn:
		sta 	lowStack,x 					; save result on stack.
		sta 	highStack,x
		NextCommand


; ******************************************************************************
;
;							Less/Greater Equal check.
;
; ******************************************************************************
				
Comp_Less:	;; [<]
		StartCommand
		clc
		bra 	Comp_LessCont
Comp_GreaterEqual: ;; [>=]
		StartCommand
		sec

Comp_LessCont:
		php
		dex
		sec
		lda 	lowStack,x 					; do a subtraction w/o storing the result
		sbc 	lowStack+1,x
		lda 	highStack,x
		sbc 	highStack+1,x
		;
		bvc 	_CLNoFlip 					; unsigned -> signed
		eor 	#$80
_CLNoFlip:
		and 	#$80 						; 0 if >= here, so flip if CS.
		beq 	CompCheckFlip
		lda 	#$FF 						; -1 if < here, so flip if CS.
		bra 	CompCheckFlip

; ******************************************************************************
;
;							Less Equal/Greater check.
;
; ******************************************************************************
				
Comp_LessEqual:	;; [<=]
		StartCommand
		sec
		bra 	Comp_LessEqualCont
Comp_Greater:	;; [>]
		StartCommand
		clc

Comp_LessEqualCont:
		php
		dex
		sec
		lda 	lowStack+1,x 					; do a subtraction w/o storing the result, backwards
		sbc 	lowStack,x
		lda 	highStack+1,x
		sbc 	highStack,x
		;
		bvc 	_CLENoFlip 					; unsigned -> signed
		eor 	#$80
_CLENoFlip:
		and 	#$80 						; 0 if > here, so flip if CS
		beq 	CompCheckFlip
		lda 	#$FF 						; -1 if >= here, so flip if CS
		bra 	CompCheckFlip

