; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		call.asm
;		Purpose :	Call/Return code
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Date : 		14th November 2019
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									Call routine
;
; *******************************************************************************************

Command_Call: ;; [%call]
		StartCommand
		jsr 	StackPushPosition 				; save stack position
		lda 	#KWD_SYS_CALL 					; push call marker
		jsr 	StackPushByte
		lda 	(codePtr),y 					; copy target address into zTemp0
		sta 	zTemp0
		iny
		lda 	(codePtr),y
		sta 	zTemp0+1
		set16 	codePtr,ProgramStart			; back to the program start
		ldy 	#1 								
		;
		;		Search the code for line in zTemp0
		;
_CCSearch:
		lda 	(codePtr)						; end of program
		beq		_CCFail
		lda 	(codePtr),y 					; compare line number LSB.
		cmp 	zTemp0 							; if equal, go check the next.
		beq 	_CCCheckMSB 					
		;
		clc 									; forward to next line.
		lda 	(codePtr)
		adc 	codePtr
		sta 	codePtr
		bcc 	_CCSearch
		inc 	codePtr+1
		bra 	_CCSearch
		;
_CCCheckMSB:
		iny 									; get MSB, keeping Y as 1
		lda 	(codePtr),y
		dey
		cmp 	zTemp0+1						; not found go back.
		bne 	_CCSearch		
		;
		ldy 	#3 								; start running from here.
		lda 	(codePtr),y 					; check it's a define
		cmp 	#KWD_SYS_DEFINE
		bne 	_CCFail
		iny 									; get the length of this.
		lda 	(codePtr),y
		clc
		adc 	#5 								; move to the end of the definition
		tay
		NextCommand
_CCFail:
		rerror 	"CALL?"

; *******************************************************************************************
;
;								   Return routine
;
; *******************************************************************************************

Command_Return: ;; [;]
		StartCommand
		lda 	#KWD_SYS_CALL 					; check it's a call
		jsr 	StackCheckTop
		bcc 	_CRFail
		ldy		#1								; return. Add 2 to skip call address
		jsr 	StackRestorePosition		
		iny
		iny
		lda 	#4 								; pop off stack
		jsr 	StackPop
		NextCommand

_CRFail:rerror	 "CALL?"