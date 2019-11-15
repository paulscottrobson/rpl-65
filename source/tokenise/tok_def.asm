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
TOKConvertIdentifierOnly:		
		lda 	InputBuffer,x 				; get first and check there's at least one.
		jsr 	TOKConvertIdentifier
		bcc 	_TKCDFail
		;
_TKCDLoop:
		jsr 	TOKWriteToken 				; write last one out
		inx									; skip over it, get next and check
		lda 	InputBuffer,x
		jsr 	TOKConvertIdentifier
		bcs 	_TKCDLoop 					; keep going while identifier present.
		jsr 	TOKFixUpLast 				; set bit for last character.
		rts

_TKCDFail:
		rerror 	"IDENTIFIER?"		

