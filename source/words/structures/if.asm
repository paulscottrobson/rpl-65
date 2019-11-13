; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		if.asm
;		Purpose :	If/Else/Endif
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Date : 		13th November 2019
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;										If
;
; *******************************************************************************************

Structure_If: ;; [if]
		StartCommand
		lda 	#KWD_IF 						; push if marker.
		jsr 	StackPushByte
		clc
		lda 	lowStack,x 						; check TOS is zero
		ora 	highStack,x
		dex 									; drop TOS
		cmp 	#0 								; if zero, skip forward to ELSE or ENDIF
		bne 	_SIFNoSkip 						; at this level.
		phx
		lda 	#KWD_ELSE 								
		ldx 	#KWD_ENDIF
		jsr 	StructSkipForward
		plx 									; restore X
		cmp 	#KWD_ELSE 						; if it was ELSE skip over that and run ELSE
		bne 	_SIFNoSkip 						; clause.
		iny
_SIFNoSkip:
		NextCommand

; *******************************************************************************************
;
;										Else
;
; *******************************************************************************************

Structure_Else: ;; [else]
		StartCommand
		lda 	#KWD_IF 						; check IF on top
		jsr 	StackCheckTop
		bcc 	SIFail
		;
		phx 									; got here by executing IF clause so skip
		lda 	#KWD_ENDIF 						; forward to ENDIF
		tax
		jsr 	StructSkipForward
		plx
		NextCommand
SIFail:	rerror 	"IF?"

; *******************************************************************************************
;
;										Endif
;
; *******************************************************************************************

Structure_Endif: ;; [endif]
		StartCommand
		lda 	#KWD_IF 						; check IF on top
		jsr 	StackCheckTop
		bcc 	SIFail
		;
		lda 	#1 								; throw it.
		jsr 	StackPop 		
		NextCommand

; *******************************************************************************************
;
;			Advance forward looking for tokens A or X at the current level. 
;			Returns with found token in A.
;
; *******************************************************************************************

StructSkipForward:
		sta 	zTemp0 							; save the tokens to test
		stx 	zTemp0+1
		stz 	zTemp1 							; zero the level counter.
_SSFLoop:		
		lda 	(codePtr),y 					; get current
		ldx 	zTemp1 							; if the structure level is non zero must fail
		bne		_SSFFail
		;
		cmp 	zTemp0 							; check for match.
		beq 	_SSFEnd
		cmp 	zTemp0+1
		beq 	_SSFEnd
		;
_SSFFail:		
		jsr 	AdvanceInCode 					; skip over in code.
		bcs 	_SSFLoop 						; if not end of program, keep going.
		rerror	"STRUCTURE?"					; didn't match up.
		;
_SSFEnd:
		rts

; *******************************************************************************************
;
;			Skip forward to the next element. If the current element is zero, go to
;			the next line. Carry set if okay, Carry clear if at the end.
;
;			Adjusts zTemp1 (structure depth)
;
; *******************************************************************************************

AdvanceInCode:
		lda 	(codePtr),y 					; look at current
		beq 	_AICEndOfLine 					; end of line.
		iny 									; advance one.
		cmp 	#TOK_NOT_CONTROL 				; is it a control
		bcc 	_AICControl
		;
		cmp 	#TOK_STRUCT_NEUTRAL 			; neutral token ?
		bcs 	_AICExit
		inc 	zTemp1 							; bump the structure count.
		cmp 	#TOK_STRUCT_DEC 				; if decrement
		bcc 	_AICExit
		dec 	zTemp1
		dec 	zTemp1
_AICExit:
		sec
		rts
		;
		;		One of the non standard words.
		;
_AICControl:		
		cmp 	#KWD_SYS_CONST 					; constant and call advance +3
		beq 	_AICThree
		cmp 	#KWD_SYS_CALL	
		beq 	_AICThree
		;
		tya										; skip over a string/comment/define.
		sec
		adc 	(codePtr),y
		tay
		sec
		rts
		;
_AICThree:										; skip over a constant or call.
		iny
		iny
		sec
		rts		
		;
		;		Handle end of line.
		;
_AICEndOfLine:
		clc 									; forward to next line.
		lda 	(codePtr)
		adc 	codePtr
		sta 	codePtr
		bcc 	_AICNoCarry
		inc 	codePtr+1
_AICNoCarry:
		ldy 	#3 								; start of new line
		lda 	(codePtr) 						; check offset is non zero
		bne 	_AICExit
		clc 									; program end.
		rts
