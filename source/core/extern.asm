; ******************************************************************************
; ******************************************************************************
;
;		Name : 		extern.asm
;		Purpose : 	External functionality
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;							Extern Initialise
;
; ******************************************************************************

ExternInitialise:
		lda 	#$02 						; set colour
		sta 	646
		lda 	#14							; lower case
		jsr 	$FFD2		
		lda 	#147 						; clear screen
		jsr 	$FFD2
		lda 	#COL_WHITE 					; white text.
		jmp 	ExternColour

; ******************************************************************************
;
;								Break Check
;
; ******************************************************************************

ExternCheckBreak:
		phx 								; make sure we keep XY
		phy
		jsr 	$FFE1						; STOP check on CBM KERNAL
		beq		_ECBExit 					; stopped
		ply 								; restore and exit.
		plx
		rts

_ECBExit:
		rerror 	"ESCAPE"

; ******************************************************************************
;
;									Print A
;
; ******************************************************************************

ExternPrint:
		pha
		phx
		phy
		jsr 	$FFD2
		ply
		plx
		pla
		rts

; ******************************************************************************
;
;								 Switch colours
;
; ******************************************************************************

ExternColour:
		pha
		phx
		pha
		and 	#8
		asl 	a
		asl 	a
		asl 	a
		asl 	a
		eor 	#$92
		jsr 	ExternPrint

		pla
		and 	#7
		tax 	
		lda 	_ECTable,x
		jsr 	ExternPrint
		plx
		pla
		rts

_ECTable:
		.byte 	144
		.byte 	28
		.byte 	30
		.byte 	158
		.byte 	31
		.byte 	156
		.byte 	159
		.byte 	5

; ******************************************************************************
;
;			  Input a command, ASCII U/C String in InputBuffer
;
; ******************************************************************************

ExternInput:
		lda 	#(InputBuffer & $FF)
		sta 	zTemp0
		lda 	#(InputBuffer >> 8)
		sta 	zTemp0+1
		lda 	#COL_WHITE
		jsr 	ExternColour
_EIRead:jsr 	$FFCF
		and 	#$7F
		cmp 	#13
		beq 	_EIExit
		sta 	(zTemp0)
		inc 	zTemp0
		bne 	_EIRead
		inc 	zTemp0+1
		bra 	_EIRead
_EIExit:lda 	#0
		sta 	(zTemp0)
		lda 	#13
		jsr 	ExternPrint
		rts

; ******************************************************************************
;
;						Save a file from YA to zTemp1
;
; ******************************************************************************

ExternSave:
		phx
		phy

		sta 	zTemp2 						; save start
		sty 	zTemp2+1

		jsr 	EXGetLength 				; get length of file into A
		ldx 	zTemp0
		ldy 	zTemp0+1
		jsr 	$FFBD 						; set name
		;
		lda 	#1
		ldx 	#1	 						; device #1
		ldy 	#0
		jsr 	$FFBA 						; set LFS
		;
		ldx 	zTemp1 						; end address
		ldy 	zTemp1+1
		;
		lda 	#zTemp2
		jsr 	$FFD8 						; save
		bcs 	_ESSave

		ply
		plx
		rts

_ESSave:
		rerror 	"SAVE FAILED"

; ******************************************************************************
;
;							  Load a file to YA
;
; ******************************************************************************

ExternLoad:
		phx 								; save XY
		phy

		pha 								; save target
		phy

		jsr 	EXGetLength 				; get length of file into A
		ldx 	zTemp0
		ldy 	zTemp0+1
		jsr 	$FFBD 						; set name
		;
		lda 	#1
		ldx 	#1	 						; device #1
		ldy 	#0
		jsr 	$FFBA 						; set LFS		

		ply 								; restore target to YX and call load
		plx
		lda 	#0 							; load command
		jsr 	$FFD5
		bcs 	_ESLoad

		ply
		plx
		rts

_ESLoad:
		rerror 	"LOAD FAILED"

; ******************************************************************************
;
;						Get length of filename in zTemp0
;
; ******************************************************************************

EXGetLength:
		ldy 	#255
_EXGL:	iny
		lda 	(zTemp0),y
		bne 	_EXGL
		tya
		rts
