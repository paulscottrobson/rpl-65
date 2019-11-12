TOK_QSTRING = $01
TOK_COMMENT = $02
TOK_DEFINE = $03
TOK_LARGE_CONSTANT = $04
TOK_CALL = $05
TOK_SMALL_CONSTANT = $10
TOK_BASE = $50
TOK_VAR_BODY = $50
TOK_VAR_ENDIDENT = $6b
TOK_FIRST = $86
TOK_STRUCT_INC = $86
TOK_STRUCT_DEC = $89
TOK_STRUCT_NEUTRAL = $8c

KWD_IF                         = $0086 ; if
KWD_REPEAT                     = $0087 ; repeat
KWD_FOR                        = $0088 ; for
KWD_ENDIF                      = $0089 ; endif
KWD_UNTIL                      = $008a ; until
KWD_NEXT                       = $008b ; next
KWD_STAR                       = $008c ; *
KWD_SLASH                      = $008d ; /
KWD_MOD                        = $008e ; mod
KWD_PLUS                       = $008f ; +
KWD_MINUS                      = $0090 ; -
KWD_AND                        = $0091 ; and
KWD_OR                         = $0092 ; or
KWD_XOR                        = $0093 ; xor
KWD_SHL                        = $0094 ; shl
KWD_SHR                        = $0095 ; shr
KWD_EQUAL                      = $0096 ; =
KWD_LESSGREATER                = $0097 ; <>
KWD_GREATER                    = $0098 ; >
KWD_LESS                       = $0099 ; <
KWD_GREATEREQUAL               = $009a ; >=
KWD_LESSEQUAL                  = $009b ; <=
KWD_CAT                        = $009c ; c@
KWD_CPLING                     = $009d ; c!
KWD_AT                         = $009e ; @
KWD_PLING                      = $009f ; !
KWD_DPLING                     = $00a0 ; d!
KWD_ALLOC                      = $00a1 ; alloc
KWD_LSQPAREN                   = $00a2 ; [
KWD_RSQPAREN                   = $00a3 ; ]
KWD_ABS                        = $00a4 ; abs
KWD_NEGATE                     = $00a5 ; negate
KWD_NOT                        = $00a6 ; not
KWD_PLUSPLUS                   = $00a7 ; ++
KWD_MINUSMINUS                 = $00a8 ; --
KWD_BSWAP                      = $00a9 ; bswap
KWD_LESSLESS                   = $00aa ; <<
KWD_GREATERGREATER             = $00ab ; >>
KWD_SGN                        = $00ac ; sgn
KWD_RND                        = $00ad ; rnd
KWD_CLR                        = $00ae ; clr
KWD_DROP                       = $00af ; drop
KWD_DUP                        = $00b0 ; dup
KWD_NIP                        = $00b1 ; nip
KWD_OVER                       = $00b2 ; over
KWD_SWAP                       = $00b3 ; swap
KWD_ELSE                       = $00b4 ; else
KWD_INDEX                      = $00b5 ; index
KWD_SEMICOLON                  = $00b6 ; ;
KWD_ASSERT                     = $00b7 ; assert
KWD_LIST                       = $00b8 ; list
KWD_NEW                        = $00b9 ; new
KWD_OLD                        = $00ba ; old
KWD_STOP                       = $00bb ; stop
KWD_RUN                        = $00bc ; run
KWD_END                        = $00bd ; end
KWD_SAVE                       = $00be ; save
KWD_LOAD                       = $00bf ; load

KeywordText:
	.text $02,$49,$c6                      ; $0086 if
	.text $06,$52,$45,$50,$45,$41,$d4      ; $0087 repeat
	.text $03,$46,$4f,$d2                  ; $0088 for
	.text $05,$45,$4e,$44,$49,$c6          ; $0089 endif
	.text $05,$55,$4e,$54,$49,$cc          ; $008a until
	.text $04,$4e,$45,$58,$d4              ; $008b next
	.text $01,$aa                          ; $008c *
	.text $01,$af                          ; $008d /
	.text $03,$4d,$4f,$c4                  ; $008e mod
	.text $01,$ab                          ; $008f +
	.text $01,$ad                          ; $0090 -
	.text $03,$41,$4e,$c4                  ; $0091 and
	.text $02,$4f,$d2                      ; $0092 or
	.text $03,$58,$4f,$d2                  ; $0093 xor
	.text $03,$53,$48,$cc                  ; $0094 shl
	.text $03,$53,$48,$d2                  ; $0095 shr
	.text $01,$bd                          ; $0096 =
	.text $02,$3c,$be                      ; $0097 <>
	.text $01,$be                          ; $0098 >
	.text $01,$bc                          ; $0099 <
	.text $02,$3e,$bd                      ; $009a >=
	.text $02,$3c,$bd                      ; $009b <=
	.text $02,$43,$c0                      ; $009c c@
	.text $02,$43,$a1                      ; $009d c!
	.text $01,$c0                          ; $009e @
	.text $01,$a1                          ; $009f !
	.text $02,$44,$a1                      ; $00a0 d!
	.text $05,$41,$4c,$4c,$4f,$c3          ; $00a1 alloc
	.text $01,$db                          ; $00a2 [
	.text $01,$dd                          ; $00a3 ]
	.text $03,$41,$42,$d3                  ; $00a4 abs
	.text $06,$4e,$45,$47,$41,$54,$c5      ; $00a5 negate
	.text $03,$4e,$4f,$d4                  ; $00a6 not
	.text $02,$2b,$ab                      ; $00a7 ++
	.text $02,$2d,$ad                      ; $00a8 --
	.text $05,$42,$53,$57,$41,$d0          ; $00a9 bswap
	.text $02,$3c,$bc                      ; $00aa <<
	.text $02,$3e,$be                      ; $00ab >>
	.text $03,$53,$47,$ce                  ; $00ac sgn
	.text $03,$52,$4e,$c4                  ; $00ad rnd
	.text $03,$43,$4c,$d2                  ; $00ae clr
	.text $04,$44,$52,$4f,$d0              ; $00af drop
	.text $03,$44,$55,$d0                  ; $00b0 dup
	.text $03,$4e,$49,$d0                  ; $00b1 nip
	.text $04,$4f,$56,$45,$d2              ; $00b2 over
	.text $04,$53,$57,$41,$d0              ; $00b3 swap
	.text $04,$45,$4c,$53,$c5              ; $00b4 else
	.text $05,$49,$4e,$44,$45,$d8          ; $00b5 index
	.text $01,$bb                          ; $00b6 ;
	.text $06,$41,$53,$53,$45,$52,$d4      ; $00b7 assert
	.text $04,$4c,$49,$53,$d4              ; $00b8 list
	.text $03,$4e,$45,$d7                  ; $00b9 new
	.text $03,$4f,$4c,$c4                  ; $00ba old
	.text $04,$53,$54,$4f,$d0              ; $00bb stop
	.text $03,$52,$55,$ce                  ; $00bc run
	.text $03,$45,$4e,$c4                  ; $00bd end
	.text $04,$53,$41,$56,$c5              ; $00be save
	.text $04,$4c,$4f,$41,$c4              ; $00bf load
	.byte 0

DispatchHandler:
	.word LongReadHandler          ; $0050 a
	.word LongReadHandler          ; $0051 b
	.word LongReadHandler          ; $0052 c
	.word LongReadHandler          ; $0053 d
	.word LongReadHandler          ; $0054 e
	.word LongReadHandler          ; $0055 f
	.word LongReadHandler          ; $0056 g
	.word LongReadHandler          ; $0057 h
	.word LongReadHandler          ; $0058 i
	.word LongReadHandler          ; $0059 j
	.word LongReadHandler          ; $005a k
	.word LongReadHandler          ; $005b l
	.word LongReadHandler          ; $005c m
	.word LongReadHandler          ; $005d n
	.word LongReadHandler          ; $005e o
	.word LongReadHandler          ; $005f p
	.word LongReadHandler          ; $0060 q
	.word LongReadHandler          ; $0061 r
	.word LongReadHandler          ; $0062 s
	.word LongReadHandler          ; $0063 t
	.word LongReadHandler          ; $0064 u
	.word LongReadHandler          ; $0065 v
	.word LongReadHandler          ; $0066 w
	.word LongReadHandler          ; $0067 x
	.word LongReadHandler          ; $0068 y
	.word LongReadHandler          ; $0069 z
	.word SyntaxError              ; $006a .
	.word ShortReadHandler         ; $006b a
	.word ShortReadHandler         ; $006c b
	.word ShortReadHandler         ; $006d c
	.word ShortReadHandler         ; $006e d
	.word ShortReadHandler         ; $006f e
	.word ShortReadHandler         ; $0070 f
	.word ShortReadHandler         ; $0071 g
	.word ShortReadHandler         ; $0072 h
	.word ShortReadHandler         ; $0073 i
	.word ShortReadHandler         ; $0074 j
	.word ShortReadHandler         ; $0075 k
	.word ShortReadHandler         ; $0076 l
	.word ShortReadHandler         ; $0077 m
	.word ShortReadHandler         ; $0078 n
	.word ShortReadHandler         ; $0079 o
	.word ShortReadHandler         ; $007a p
	.word ShortReadHandler         ; $007b q
	.word ShortReadHandler         ; $007c r
	.word ShortReadHandler         ; $007d s
	.word ShortReadHandler         ; $007e t
	.word ShortReadHandler         ; $007f u
	.word ShortReadHandler         ; $0080 v
	.word ShortReadHandler         ; $0081 w
	.word ShortReadHandler         ; $0082 x
	.word ShortReadHandler         ; $0083 y
	.word ShortReadHandler         ; $0084 z
	.word SyntaxError              ; $0085 .
	.word SyntaxError              ; $0086 if
	.word SyntaxError              ; $0087 repeat
	.word SyntaxError              ; $0088 for
	.word SyntaxError              ; $0089 endif
	.word SyntaxError              ; $008a until
	.word SyntaxError              ; $008b next
	.word MulInteger16             ; $008c *
	.word DivInteger16             ; $008d /
	.word ModInteger16             ; $008e mod
	.word Stack_Add                ; $008f +
	.word Stack_Sub                ; $0090 -
	.word Stack_And                ; $0091 and
	.word Stack_Or                 ; $0092 or
	.word Stack_Xor                ; $0093 xor
	.word Stack_Shl                ; $0094 shl
	.word Stack_Shr                ; $0095 shr
	.word Comp_Equal               ; $0096 =
	.word Comp_NotEqual            ; $0097 <>
	.word Comp_Greater             ; $0098 >
	.word Comp_Less                ; $0099 <
	.word Comp_GreaterEqual        ; $009a >=
	.word Comp_LessEqual           ; $009b <=
	.word Mem_Peek                 ; $009c c@
	.word Mem_Poke                 ; $009d c!
	.word Mem_WPeek                ; $009e @
	.word Mem_WPoke                ; $009f !
	.word Mem_DWPoke               ; $00a0 d!
	.word Mem_Alloc                ; $00a1 alloc
	.word SyntaxError              ; $00a2 [
	.word SyntaxError              ; $00a3 ]
	.word Unary_Absolute           ; $00a4 abs
	.word Unary_Negate             ; $00a5 negate
	.word Unary_Not                ; $00a6 not
	.word Unary_Increment          ; $00a7 ++
	.word Unary_Decrement          ; $00a8 --
	.word Unary_BSwap              ; $00a9 bswap
	.word Unary_Shl                ; $00aa <<
	.word Unary_Shr                ; $00ab >>
	.word Unary_Sgn                ; $00ac sgn
	.word Random_Handler           ; $00ad rnd
	.word Stack_Empty              ; $00ae clr
	.word Stack_Drop               ; $00af drop
	.word Stack_Dup                ; $00b0 dup
	.word Stack_Nip                ; $00b1 nip
	.word Stack_Over               ; $00b2 over
	.word Stack_Swap               ; $00b3 swap
	.word SyntaxError              ; $00b4 else
	.word SyntaxError              ; $00b5 index
	.word SyntaxError              ; $00b6 ;
	.word SyntaxError              ; $00b7 assert
	.word SyntaxError              ; $00b8 list
	.word SyntaxError              ; $00b9 new
	.word SyntaxError              ; $00ba old
	.word SyntaxError              ; $00bb stop
	.word SyntaxError              ; $00bc run
	.word SyntaxError              ; $00bd end
	.word SyntaxError              ; $00be save
	.word SyntaxError              ; $00bf load
