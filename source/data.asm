; ******************************************************************************
; ******************************************************************************
;
;		Name : 		data.asm
;		Purpose : 	Data Allocation.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	12th November 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;								Default Address Spaces
;
; ******************************************************************************

BuildAddress = $A000 						; Build address
MemoryStart = $0F00 						; Main memory space here
HighMemory = $9F00							; Where memory ends
StackAddress = $0600						; Stack (1/2k bytes)
InputBuffer = $0800							; Input Buffer (must be on a page boundary)
IntStack = $09FF 							; Interpreter Stack
ConvertBuffer = $08E0 						; Conversion buffer (numbers)
TokenBuffer = $0A00 						; Tokenisation Buffer
HashTableSize = 16 							; size of hash table (# entries)

; ******************************************************************************
;
;				Sections so library functions can allocate zero page
;
; ******************************************************************************

		* = $0000
		.dsection zeroPage
		.cerror * > $7F,"Page Zero Overflow"

; ******************************************************************************
;
;							Allocate Zero Page usage
;
; ******************************************************************************

		.section zeroPage

CodePtr: 		.word ? 					; code pointer
zTemp0:			.word ?						; temporary words
zTemp1: 		.word ?
zTemp2: 		.word ?
zTemp3: 		.word ?
zTemp4:			.word ?
zTemp5:			.word ?
iStack:			.word ?						; stack pointer
signCount:		.byte ? 					; divide sign count.
allocPtr:		.word ? 					; memory allocation pointer (down)
memVarPtr:		.word ? 					; pointer for memory variables (up)
randomSeed:		.word ? 					; random number seed
prefixCharacter:.byte ?						; char to print before listed element.
breakCount:		.byte ? 					; counter avoids repeated break checks
tokenOffset:	.byte ? 					; position in output token buffer.

		.send zeroPage

; ******************************************************************************
;
;				Allocate Memory in the current instance space
;
; ******************************************************************************

		* = MemoryStart

FastVariables:	.fill 	64 					; fast variable memory.

VariableHashTable:.fill	HashTableSize * 2 	; hash tables (variables)

ProgramStart	= MemoryStart + $100 		; where code actually goes.

; ******************************************************************************
;
;				Stack - actually two 1/4k stacks, one for each byte.
;
; ******************************************************************************

lowStack = StackAddress 					; low stack bytes
highStack = StackAddress+256				; high stack bytes

; ******************************************************************************
;
;									Other constants
;
; ******************************************************************************

;
;		Colours.
;
COL_BLACK = 0 		
COL_RED = 1
COL_GREEN = 2
COL_YELLOW = 3
COL_BLUE = 4
COL_MAGENTA = 5
COL_CYAN = 6
COL_WHITE = 7
COL_RVS = 8
