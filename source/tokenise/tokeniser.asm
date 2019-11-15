; ******************************************************************************
; ******************************************************************************
;
;		Name : 		tokeniser.asm
;		Purpose : 	Tokeniser for RPL/65
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;		Tokenises the string in the input buffer, to the output buffer.
;		After removing trailing spaces (because of comment)
;
;		In order :-
;			1) 	If it begins with 0-9 or $ it is a decimal/hexadecimal
;				constant (note Postfix -)
;			2)	If it begins with : it is a definition
;			3)  If it begins with " or ' it is a string or a comment.
;			4)	If it starts with a token, then it is that token.
;			5)  If it is an identifier (A-Z or :) see if it is a definition
;				if so compile a call to it, otherwise compile the identifier.
;			6) 	An error occurs.
;
; ******************************************************************************

TokeniseInputBuffer:
		pha
		phx
		phy
		stz 	TokenOffset					; reset index into TokenBuffer
		stz 	TokenBuffer 				; empty that buffer
		lda 	#0 							; create faux line by writing 3 bytes out.
		jsr 	TokWriteToken
		jsr 	TokWriteToken
		jsr 	TokWriteToken
		;
		;		Remove any trailing spaces
		;
		ldx 	#255 						; find the end.
_TIBForward:
		inx
		lda 	InputBuffer,x
		bne 	_TIBForward
_TIBBackward:
		dex 								; back one.
		cpx 	#255 						; gone too far.
		beq 	_TIBExit					; return empty buffer
		lda 	InputBuffer,x
		cmp 	#" "
		beq 	_TIBBackward
		stz 	InputBuffer+1,x 			; truncate at last non space.
		ldx		#0 							; start of the input bufferr.
		;
		;		Main Tokenising Loop.
		;
_TIBMainLoop:
		lda 	InputBuffer,x 				; next character
		beq 	_TIBExit 					; done the buffer if zero.
		inx
		cmp 	#" " 						; skip over spaces
		beq 	_TIBMainLoop
		dex 								; undo the last inx.
		;
		;		Check for hexadecimal/decimal constant.
		;
		cmp 	#"$"						; is it $ ?
		beq 	_TIBConstant
		cmp 	#"0"						; check 0-9
		bcc 	_TIBNotConstant
		cmp 	#"9"+1
		bcs 	_TIBNotConstant
_TIBConstant:		
		jsr 	TOKConvertConstant
		bra 	_TIBMainLoop
		;
		;		Check for definition
		;		
_TIBNotConstant:
		cmp 	#":"						; definition
		bne 	_TIBNotDefinition
		jsr 	TOKConvertDefinition
		bra 	_TIBMainLoop
		;
		;		Check for comment and string.
		;
_TIBNotDefinition:
		cmp 	#"'"
		beq 	_TIBIsCommentString
		cmp 	#'"'
		bne 	_TIBNotCommentString
_TIBIsCommentString:
		jsr 	TOKConvertCommentString
		bra 	_TIBMainLoop
		;
		;		Check for a token here.
		;
_TIBNotCommentString:
		jsr 	TOKCheckIsToken 			; check if a token.
		bcs 	_TIBMainLoop
		;
		;		Finally output an identifier (same code as definition)
		;
		jsr 	TOKConvertIdentifierOnly
		bra 	_TIBMainLoop
_TIBExit: 							
		ply
		plx
		pla
		rts

; ******************************************************************************
;
;						Write a byte to the token buffer
;
; ******************************************************************************

TOKWriteToken:
		phx
		ldx 	TokenOffset
		sta 	TokenBuffer,x
		stz 	TokenBuffer+1,x
		inc 	TokenOffset
		plx
		rts

; ******************************************************************************
;
;		Marks the last identifier written - doesn't check this - as last.
;
; ******************************************************************************

TOKFixUpLast:
		phx
		ldx 	TokenOffset
		lda 	TokenBuffer-1,x
		ora 	#$E0
		sta 	TokenBuffer-1,x
		plx
		rts
		
; ******************************************************************************
;
;		Convert A (ASCII) to tokenised (C1-DA = A-Z DB = .) CS Okay CC Fail
;
; ******************************************************************************

TOKConvertIdentifier:
		cmp 	#"."						; dot is special case.
		beq 	_TKCIDot
		sec 								; A-Z -> 1-27
		sbc 	#64
		beq 	_TKCIFail
		cmp 	#27
		bcs 	_TKCIFail
		ora 	#$C0 						; fix up
		sec
		rts
;
_TKCIFail:
		clc
		rts
_TKCIDot: 									; return .
		lda 	#$C0+27
		sec
		rts

