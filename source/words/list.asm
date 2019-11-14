; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		list.asm
;		Purpose :	Program Lister
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Date : 		14th November 2019
;
; *******************************************************************************************
; *******************************************************************************************

Cmd_List: 	;; [list]
		stz 	zTemp2						; clear the lowest-number
		stz 	zTemp2+1

_CLNoStartLine:
		set16 	codePtr,programStart
		;
		;		Listing loop
		;
_CLILoop:
		lda 	(codePtr)					; check end of program
		beq 	_CLIEnd
		ldy 	#1 							; compare line# vs the minimum
		sec
		lda 	(codePtr),y
		sbc 	zTemp2
		iny
		lda 	(codePtr),y
		sbc 	zTemp2+1
		bcc 	_CLISkip
		phx
		jsr 	ListCurrent 				; list the line.
		plx
		dec 	zTemp3 						; done all lines
		beq 	_CLIEnd
_CLISkip:
		clc
		lda 	(codePtr) 					; go to next
		adc 	codePtr
		sta 	codePtr
		bcc 	_CLILoop
		inc 	codePtr+1
		bra 	_CLILoop
_CLIEnd:	
		bra 	_CLIEnd
		jmp 	WarmStart
;
;		List current line.
;
ListCurrent:
		lda 	#CTH_LINENO
		jsr 	ExternColour 				; set colour
		ldy 	#1							; print line#
		lda 	(codePtr),y
		tax
		iny
		lda 	(codePtr),y
		tay
		jsr 	PrintIntegerUnsigned
		;
		tay
_LCPadOut:									; pad out to align neatly
		lda 	#' '
		jsr 	ExternPrint
		iny
		cpy 	#6
		bne 	_LCPadOut
		ldy 	#3 							; start here		
		stz 	PrefixCharacter				; no prefix
		;
		;		MAIN LOOP
		;
_LCLoop:lda 	#CTH_LINENO 				; reset colour.
		jsr 	ExternColour
		lda 	(codePtr),y 				; [ ] never have a prefix.
		cmp 	#KWD_LSQPAREN
		beq 	_LCNoPrefix
		cmp 	#KWD_RSQPAREN
		beq 	_LCNoPrefix
		lda 	PrefixCharacter 			; output prefix, reset to space
		beq		_LCNoPrefix
		jsr 	PrintCharacter		
_LCNoPrefix:
		lda 	#32
		sta 	PrefixCharacter
		;		
		lda 	(codePtr),y 				; look at next
		beq 	_LCExit
		bpl 	_LCIsToken 					; +ve goto token.
		cmp 	#$C0 						; C0-FF
		bcs 	_LCIsIdentifier 
		;
		;		Short constant $80-$BF
		;
		and 	#$3F 						; 80-BF 0-63
		tax
		iny
		phy 								; push pos		
		ldy 	#0
		lda 	#CTH_NUMBER
		jsr 	ExternColour
		jsr 	PrintIntegerUnsigned
		ply
		bra 	_LCLoop
		;
		;		Exit $00
		;
_LCExit:		
		lda 	#13
		jsr 	PrintCharacter		
		rts
		;
		;		Handle Identifiers $C0-$FF
		;
_LCIsIdentifier:
		lda 	#CTH_IDENT
		jsr 	ExternColour
_LCIdentLoop:
		lda 	(codePtr),y 				; keep printing 
		jsr 	ListPrintIDChar
		lda 	(codePtr),y 				; get current
		iny	
		cmp 	#$E0 						; was it an end marker
		bcs 	_LCLoop 					; if so, do next
		bra 	_LCIdentLoop				; if not loop round
		;
		;		Print a constant.
		;
_LCConstant:
		iny
		lda 	(codePtr),y 				; get LSB into X
		tax
		iny 								; get MSB into Y
		lda 	(codePtr),y
		iny
		phy
		tay
		phy 								; save sign
		bpl 	_LCNotNegative
		tya 								; YX = |YX|
		eor 	#$FF
		tay
		txa 	
		eor 	#$FF
		tax
		inx
		bne 	_LCNotNegative
		iny
_LCNotNegative:
_LCPrintYX:
		lda 	#CTH_NUMBER
		jsr 	ExternColour
		jsr 	PrintIntegerUnsigned
		pla 								; restore sign
		bpl 	_LCNoTrail
		lda 	#"-"
		jsr 	PrintCharacter
_LCNoTrail:
		ply 								; restore Y
		jmp 	_LCLoop
		;
		;		Token of some sort - includes strings,comments, defines, constants, calls and keywords.
		;
_LCIsToken:
		cmp 	#KWD_SYS_CONST 				; check for constant.
		beq 	_LCConstant
		cmp 	#TOK_NOT_CONTROL
		bcc 	_LCControl
		;
		;		It's a token.
		;
_LCIsKeywordToken:
		sta 	zTemp0 						; save token #
		set16	zTemp1,KeywordText 			; zTemp1 is index into table.
		lda 	#CTH_TOKEN 					; set to token colour
		jsr 	ExternColour
		phy 								; save code offset
_LCForward:
		lda 	zTemp0 						; done if token number is zero.
		beq 	_LCFoundToken
		dec 	zTemp0						; dec count.
		;
		sec 								; go to next keyword.
		lda 	(zTemp1)
		adc 	zTemp1
		sta 	zTemp1
		bcc 	_LCForward
		inc 	zTemp1+1
		bra 	_LCForward
		;
_LCFoundToken:  							; found a token.		
		ldy 	#1 							; output the token.
_LCOutToken:		
		lda 	(zTemp1),y 					; print character
		and 	#$7F
		jsr 	PrintCharacter
		lda 	(zTemp1),y 					; reget, put bit 7 in C
		iny		
		asl 	a 
		bcc 	_LCOutToken
		ply 								; restore code offset
		lda 	(codePtr),y 				; what did we print ?
		iny
		cmp 	#KWD_HAT 					; for ^ and [, do not print space following.
		beq 	_LCCancelPrefix
		cmp 	#KWD_LSQPAREN
		bne 	_LCGoLoop
_LCCancelPrefix:
		stz 	PrefixCharacter
_LCGoLoop:
		jmp 	_LCLoop
		;
		;		Control token : comment, define, string or call (already done constant)
		;
_LCControl:
		cmp 	#KWD_SYS_CALL
		beq 	_LCDecodeCall
		cmp 	#KWD_SYS_DEFINE
		beq 	_LCDecodeDefine
		phy 								; save Y
		ldy 	#'"'						; setup for String
		ldx 	#CTH_STRING 	
		cmp 	#KWD_SYS_QSTRING
		beq 	_LCDecodeString
		ldy 	#"'"						; setup for comment
		ldx 	#CTH_COMMENT
_LCDecodeString
		txa 								; set colour
		jsr 	ExternColour
		tya 					
		jsr 	PrintCharacter
		ply 								; restore Y pos
		pha 								; save end character on stack.
		iny 								; get count into X
		lda 	(codePtr),y
		tax
_LCOutString:								; output the string
		iny 
		cpx		#0 							; reached the end
		beq 	_LCEndDecode
		lda 	(codePtr),y
		jsr 	PrintCharacter
		dex
		bra 	_LCOutString
_LCEndDecode:
		pla
		cmp 	#"'"						; don't print last
		beq 	_LCEDNoQuote
		jsr 	PrintCharacter
_LCEDNoQuote:		
		jmp 	_LCLoop
		;
		;		Decide a definition
		;
_LCDecodeDefine:
		lda 	#CTH_DEFINITION
		jsr 	ExternColour
		lda 	#":"
		jsr 	PrintCharacter
_LCCPrintDef:		
		iny
		lda 	(codePtr),y
		tax
_LCCOutDefine:
		iny
		cpx 	#0
		beq 	_LCEDNoQuote
		lda 	(codePtr),y
		jsr 	ListPrintIDChar
		dex
		bra 	_LCCOutDefine
		;
		;		Decode a CALL.
		;
_LCDecodeCall:
		iny 								; get line number into XA
		lda 	(codePtr),y
		pha
		iny
		lda 	(codePtr),y
		iny
		tax
		pla
		jsr 	ListFindLine 				; find that line.
		bcc 	_LCNoDefinition
		phy
		ldy 	#3 							; look at first character
		lda 	(zTemp0),y
		cmp 	#KWD_SYS_DEFINE
		bne 	_LCNoDefinition 			; not define
		;
		lda 	#CTH_CALLWORD
		jsr 	ExternColour
		iny
		lda 	(zTemp0),y
		tax
_LCCOutCall:
		iny
		cpx 	#0
		beq 	_LCEDEndCall
		lda 	(zTemp0),y
		jsr 	ListPrintIDChar
		dex
		bra 	_LCCOutCall
_LCEDEndCall:
		ply
		jmp 	_LCLoop		

_LCNoDefinition:
		.byte 	$FF 						; definition is missing.

;
;		Print identifier character (C0-FF) in A
;
ListPrintIDChar:
		and 	#$1F 						; 1-26 A-Z 27 .
		ora 	#$40 						; ASCII except .
		cmp 	#$40+27
		bne 	_LCNotDot
		lda 	#"."
_LCNotDot:
		jsr 	PrintCharacter
		rts
;
;		Find Line XA, put pointer to line into zTemp0
;
ListFindLine:
		phy
		stx 	zTemp1+1
		sta 	zTemp1
		set16 	zTemp0,ProgramStart		
_LFLSearch:
		clc									; reached the end.
		lda 	(zTemp0)
		beq 	_LFLExit 					; exit with CC
		ldy 	#1
		lda 	zTemp1
		cmp 	(zTemp0),y
		bne 	_LFLNext
		iny
		lda 	zTemp1+1
		cmp 	(zTemp0),y
		beq 	_LFLFound
_LFLNext:
		clc
		lda 	(zTemp0)
		adc 	zTemp0
		sta 	zTemp0
		bcc 	_LFLSearch
		inc 	zTemp0+1
		bra 	_LFLSearch
_LFLFound:
		sec
_LFLExit:
		ply
		rts