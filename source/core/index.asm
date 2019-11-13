; ******************************************************************************
; ******************************************************************************
;
;		Name : 		index.asm
;		Purpose : 	Index Checking / Calculations
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	13th November 2019
;
; ******************************************************************************
; ******************************************************************************

IndexCheck:
		lda 	(codePtr),y 			; do we have a [
		cmp 	#KWD_LSQPAREN
		beq 	_ICFound
		rts
		;
_ICFound:
		iny 							; get next
		lda 	(codePtr),y
		cmp 	#KWD_RSQPAREN 			; is it ], then stack value index.
		beq 	_ICStackIndex
		sec
		sbc 	#$80 					; this will shift 00-3F into that range
		cmp 	#$40
		bcs 	_ICError
		;
		;		This is the constant indexing code [x] x = 0..63
		;
		asl 	a 						; double index clear carry
		phy 							; put into Y
		adc 	(zTemp0) 				; follow the vector adding the index
		pha
		ldy 	#1	
		lda 	(zTemp0),y
		adc 	#0
		sta 	zTemp0+1
		pla
		sta 	zTemp0
		ply 							; restore position.
		iny								; skip index
		;
		lda 	(codePtr),y 			; get & skip next
		iny
		cmp 	#KWD_RSQPAREN 			; should be ]
		bne 	_ICError
		rts
		;
_ICError:
		rerror	"INDEX?"
		;
		;		This uses TOS.
		;
_ICStackIndex:
		iny 							; skip the ]
		lda 	lowStack,x 				; get tos -> zTemp1 doubled
		asl 	a
		sta 	zTemp1
		lda 	highStack,x
		rol 	a
		sta 	zTemp1+1
		dex 							; throw TOS.
		;
		phy
		ldy 	#1 						; calculate new address
		lda 	(zTemp0)
		adc 	zTemp1
		pha
		lda 	(zTemp0),y
		adc 	zTemp1+1
		sta 	zTemp0+1
		pla
		sta 	zTemp0
		ply 							; restore pos and exit.		
		rts
