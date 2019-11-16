# ****************************************************************************
# ****************************************************************************
#
#		Name:		assembler.py
#		Purpose:	Creates assembler information
#		Author:		Paul Robson (paul@robsons.org.uk)
#		Created:	12th November 2019
#
# ****************************************************************************
# ****************************************************************************

import re
#
#		This is obtained by converting the table in 65c02.odt to text with
#		comma seperators.
#
opcodes = """
brk ,ora ix ,,,tsb zp ,ora zp ,asl zp ,,php ,ora # ,asl a,,tsb  ab ,ora  ab ,asl  ab ,
bpl rl ,ora iy ,ora in ,,trb zp ,ora zx ,asl zx ,,clc ,ora  ay ,inc a,,trb  ab ,ora  ax ,asl  ax ,
jsr  a ,and ix ,,,bit zp ,and zp ,rol zp ,,plp ,and # ,rol a,,bit  ab ,and  ab ,rol  ab ,
bmi rl ,and iy ,and in ,,bit zx ,and zx ,rol zx ,,sec ,and  ay ,dec a ,,bit  ax ,and  ax ,rol  ax ,
rti ,eor ix ,,,,eor zp ,lsr zp ,,pha ,eor # ,lsr a ,,jmp  ab ,eor  ab ,lsr  ab ,
bvc rl ,eor iy ,eor in ,,,eor zx ,lsr zx ,,cli ,eor  ay ,phy ,,,eor  ax ,lsr  ax ,
rts ,adc ix ,,,stz zp ,adc zp ,ror zp ,,pla ,adc # ,ror a ,,jmp ia ,adc  ab ,ror  ab ,
bvs rl ,adc iy ,adc in ,,stz zx ,adc zx ,ror zx ,,sei ,adc  ay ,ply ,,jmp iax ,adc  ax ,ror  ax ,
bra rl ,sta ix ,,,sty zp ,sta zp ,stx zp ,,dey ,bit # ,txa ,,sty  ab ,sta  ab ,stx  ab ,
bcc rl ,sta iy ,sta in ,,sty zx ,sta zx ,stx zy ,,tya ,sta  ay ,txs ,,stz  ab ,sta  ax ,stz  ax ,
ldy # ,lda ix ,ldx # ,,ldy zp ,lda zp ,ldx zp ,,tay ,lda # ,tax ,,ldy  ab ,lda  ab ,ldx  ab ,
bcs rl ,lda iy ,lda in ,,ldy zx ,lda zx ,ldx zy ,,clv ,lda  ay ,tsx ,,ldy  ax ,lda  ax ,ldx  ay ,
cpy # ,cmp ix ,,,cpy zp ,cmp zp ,dec zp ,,iny ,cmp # ,dex ,,cpy  ab ,cmp  ab ,dec  ab ,
bne rl ,cmp iy ,cmp in ,,,cmp zx ,dec zx ,,cld ,cmp  ay ,phx ,,,cmp  ax ,dec  ax ,
cpx # ,sbc ix ,,,cpx zp ,sbc zp ,inc zp ,,inx ,sbc # ,nop ,,cpx  ab ,sbc  ab ,inc  ab ,
beq rl ,sbc iy ,sbc in ,,,sbc zx ,inc zx ,,sed ,sbc  ay ,plx ,,,sbc  ax ,inc  ax ,
"""
#
#		Pre process. Check then end : inc ax is $FE
#
opcodes = [x.strip() for x in opcodes.strip().replace("\n",",").strip().lower().split(",")]
assert len(opcodes) == 256
#
#		Supported addressing modes.
#
modes = ",a,#,rl,zp,zx,zy,ix,iy,in,ab,ax,ay,ia,iax".split(",")
#
#		Analyse the above table.
#
mnemonics = { }
for i in range(0,256):			
	if opcodes[i] != "":
		parts = opcodes[i].split()
		if len(parts) == 1:
			parts.append("")
		assert len(parts[0]) == 3 and parts[1] in modes,"Error {0} {1}".format(parts[0],parts[1])
		mnemonics[i] = { "opcode":parts[0].upper(),"operand":modes.index(parts[1])}
#
#	Output constants. # and implied are made into assembleable identifiers
#
print("ASM_FIRST_2BYTE = {0}".format(modes.index("#")))
print("ASM_FIRST_3BYTE = {0}".format(modes.index("ab")))
#
modes[2] = "imm"
modes[0] = "imp"
for i in range(0,len(modes)):
	print("ASM_MODE_{0} = {1}".format(modes[i].upper(),i))
#
#	Convert each mnemonic to A-Z = 1..26, pack 3 per byte, first char
#	is 14..10 2nd is 9..5 3rd is 4..0. No operation is $00
#	
#	They are stored in two halves so they can be accessed using an
#	index register.
#
lowBytes = []
highBytes = []
for i in range(0,256):
	n = 0
	if i in mnemonics:
		s = [(ord(x) & 0x1F) for x in mnemonics[i]["opcode"]]
		s[-1] |= 0xE0
		#print(i,s,mnemonics[i])
		n = (s[0] << 10)+(s[1] << 5)+s[2]
	lowBytes.append(n & 0xFF)
	highBytes.append(n >> 8)
assert len(lowBytes) == 256 and len(highBytes) == 256
print("LowBytes:")
print("\t.byte {0}".format(",".join(["${0:02x}".format(n) for n in lowBytes])))
print("HighBytes:")
print("\t.byte {0}".format(",".join(["${0:02x}".format(n) for n in highBytes])))
#
#	Modes for each opcode is packed into 2 x 4 bit nibbles, with the first
#	opcode (even) in bit 7..4, the second in bits 0..3
#
modes = [ 0xF ] * 256
for i in range(0,256):
	if i in mnemonics:
		modes[i] = mnemonics[i]["operand"]
compactModes = []		
for i in range(0,255,2):				
	compactModes.append((modes[i] << 4) + modes[i+1])
assert len(compactModes) == 128
print("ModeNibbles:")
print("\t.byte {0}".format(",".join(["${0:02x}".format(n) for n in compactModes])))
