; ******************************************************************************
; ******************************************************************************
;
;		Name : 		memory.asm
;		Purpose : 	Memory I/O functions
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;								c@, read a byte
;
; ******************************************************************************

Mem_Peek:	;; [c@]
		StartCommand
		lda 	lowStack,x 					; copy address
		sta 	zTemp0
		lda 	highStack,x
		sta 	zTemp0+1
		lda 	(zTemp0)					; read byte
		sta 	lowStack,x 					; write to stack
		stz 	highStack,x 				
		NextCommand

; ******************************************************************************
;
;								@ read a word
;
; ******************************************************************************

Mem_WPeek:	;; [@]
		StartCommand
		lda 	lowStack,x 					; copy address
		sta 	zTemp0
		lda 	highStack,x
		sta 	zTemp0+1
		lda 	(zTemp0)					; read byte
		sta 	lowStack,x 					; write to stack
		phy 								; read msb
		ldy 	#1
		lda 	(zTemp0),y
		ply
		sta 	highStack,x 				; write to stack
		NextCommand

; ******************************************************************************
;
;								c! write a byte
;
; ******************************************************************************

Mem_Poke:	;; [c!]
		StartCommand
		lda 	lowStack,x 					; copy address
		sta 	zTemp0
		lda 	highStack,x
		sta 	zTemp0+1
		;
		lda 	lowStack-1,x 				; byte to write
		sta 	(zTemp0)
		dex
		dex
		NextCommand

; ******************************************************************************
;
;								! write a word
;
; ******************************************************************************

Mem_WPoke:	;; [!]
		StartCommand
		lda 	lowStack,x 					; copy address
		sta 	zTemp0
		lda 	highStack,x
		sta 	zTemp0+1
		;
		lda 	lowStack-1,x 				; byte to write
		sta 	(zTemp0)
		phy 
		ldy 	#1
		lda 	highStack-1,x 				; byte to write
		sta 	(zTemp0),y
		ply
		dex
		dex	
		NextCommand

; ******************************************************************************
;
;						d! write a word to the same address
;
; ******************************************************************************

Mem_DWPoke:	;; [d!]
		StartCommand
		lda 	lowStack,x 					; copy address
		sta 	zTemp0
		lda 	highStack,x
		sta 	zTemp0+1
		;
		lda 	lowStack-1,x 				; byte to write
		sta 	(zTemp0)
		lda 	highStack-1,x 				; byte to write
		sta 	(zTemp0)
		dex
		dex	
		NextCommand

; ******************************************************************************
;
;								Allocate memory
;
; ******************************************************************************

Mem_Alloc:	;; [alloc]
		StartCommand
		;
		sec 								; subtract count from alloc ptr
		lda 	allocPtr
		sbc 	lowStack,x
		sta 	allocPtr
		pha 								; save low.
		lda 	allocPtr+1
		sbc 	highStack,x
		sta 	allocPtr+1
		;
		bcc 	_MAError 					; borrow ?
		cmp 	memVarPtr+1 				; if <= memVarPtr then error ?
		bcc 	_MAError
		beq 	_MAError
		;
		sta 	highStack,x 				; update address
		pla
		sta 	lowStack,x
		NextCommand
_MAError:
		rerror	"MEMORY?"