; ******************************************************************************
; ******************************************************************************
;
;		Name : 		tok_cst.asm
;		Purpose : 	Tokenise Comment or String
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;					Tokenise comment string or quoted string
;
; ******************************************************************************

TOKConvertCommentString:
		cmp 	#"'"						; is it a comment
		beq 	_TKCCSComment
		lda 	#KWD_SYS_QSTRING 			; token
		ldy 	#'"'						; match character
		bra 	_TKCCSContinue
_TKCCSComment:
		lda 	#KWD_SYS_COMMENT 			; token
		ldy 	#0 							; match character
_TKCCSContinue:
		jsr 	TOKWriteToken 				; write initial token
		;
		inx 								; skip over ' or "
		sty 	zTemp0 						; closing token to search for.
		ldy 	#0 							; count of characters
		phx 								; save start position
		;
_TKCCSFindSize:								; work out size.
		lda 	InputBuffer,x 				; found the end
		cmp 	zTemp0
		beq 	_TKCCSFoundEnd
		inx 								; bump pos, count
		iny
		cmp 	#0 							; if end of line error - quote unmatched
		bne 	_TKCCSFindSize
		rerror 	"QUOTE?"
		;
_TKCCSFoundEnd:
		tya 								; length of element in Y
		jsr 	TOKWriteToken
		plx 								; restore start position and copy out
		;
_TKCCSCopyOut:
		cpy 	#0 							; complete ?
		beq 	_TKCCSExit
		lda 	InputBuffer,x
		jsr 	TOKWriteToken
		inx
		dey
		bra 	_TKCCSCopyOut
_TKCCSExit:
		lda 	zTemp0 						; if closing token was non-zero, it's a quote so skip it
		beq 	_TKCSSNotComment
		inx
_TKCSSNotComment:
		rts
