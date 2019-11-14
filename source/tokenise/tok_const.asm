; ******************************************************************************
; ******************************************************************************
;
;		Name : 		tok_const.asm
;		Purpose : 	Constant Tokeniser for RPL/65
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;		Convert integer constant either <dec> or $<hex> with optional
;		postfix - character.
;
; ******************************************************************************

TOKConvertConstant:
		ldy 	#InputBuffer >> 8 			; the buffer must be on a $00 page.
		phx 								; save X position
		jsr 	StringToInt 				; try to convert
		bcc 	_TKCCError
		;
		sty 	zTemp0+1 					; save result in zTemp0 						
		stx 	zTemp0
		sta 	zTemp1 						; save count 			
		pla 								; restore X position, add the count
		clc
		adc 	zTemp1
		tax
		lda 	InputBuffer,x 				; followed by - ?
		cmp 	#"-"
		bne 	_TKCCNotNegative
		inx 								; consume the -
		sec
		lda 	#0 							; negate the constant.
		sbc 	zTemp0
		sta 	zTemp0
		lda 	#0
		sbc 	zTemp0+1
		sta 	zTemp0+1
_TKCCNotNegative:
		lda 	zTemp0+1 					; check short/long const ?
		bne 	_TKCCLongConstant
		lda 	zTemp0
		cmp 	#$40
		bcs 	_TKCCLongConstant
		ora 	#$80 						; write the short token out with bit 7 set
		jsr 	TOKWriteToken
		rts
		;
_TKCCLongConstant:
		lda 	#KWD_SYS_CONST 				; write out long constant
		jsr 	TOKWriteToken
		lda 	zTemp0
		jsr 	TOKWriteToken
		lda 	zTemp0+1
		jsr 	TOKWriteToken
		rts				
_TKCCError:		
		rerror 	"CONST?"

