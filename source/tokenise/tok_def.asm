; ******************************************************************************
; ******************************************************************************
;
;		Name : 		tok_def.asm
;		Purpose : 	Tokenise Definition.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	14th November 2019
;
; ******************************************************************************
; ******************************************************************************

TOKConvertDefinition:
		inx 								; skip over :
		lda 	#KWD_SYS_DEFINE 			; output define token
		jsr 	TOKWriteToken
TOKConvertIdentifierOnly:
		;
		stz 	zTemp0 						; count how many identifiers.
		phx
_TKCDCount:
		lda 	InputBuffer,x
		jsr 	TOKConvertIdentifier
		bcc 	_TKCDCounted
		inx
		inc 	zTemp0
		bra 	_TKCDCount
		;
_TKCDCounted:
		lda 	zTemp0 						; get count
		beq 	_TKCDFail 					; can't be none
		jsr 	TOKWriteToken 				; write count
		plx 								; restore X
		;
_TKCDLoop:
		lda 	InputBuffer,x 				; output that many tokens.
		inx
		jsr 	TOKConvertIdentifier
		jsr 	TOKWriteToken 				
		dec 	zTemp0
		bne 	_TKCDLoop
		jsr 	TOKFixUpLast 				; set bit for last character.
		rts

_TKCDFail:
		rerror 	"IDENTIFIER?"		

; ******************************************************************************
;
;						Copy an identifier
;
; ******************************************************************************

TOKCopyIdentifier:
		lda 	InputBuffer,x
		jsr 	TOKConvertIdentifier
		bcc 	_TKCIError
_TKCILoop:
		lda 	InputBuffer,x 				; get and output token till not found
		inx
		jsr 	TOKConvertIdentifier
		bcc 	_TKCIEnd
		jsr 	TOKWriteToken 				
		bra 	_TKCILoop
_TKCIEnd:
		dex
		jsr 	TOKFixUpLast 				; set bit for last character.
		rts
_TKCIError:
		rerror 	"PARSE?"