# ****************************************************************************
# ****************************************************************************
#
#		Name:		generate.py
#		Purpose:	Creates tables, constants
#		Author:		Paul Robson (paul@robsons.org.uk)
#		Created:	12th November 2019
#
# ****************************************************************************
# ****************************************************************************

from tokens import *
import os,sys,re 

tok = Tokens()
tokList = tok.getTokens()
#
#		Constants
#
const = tok.getConstants()
for k in const.keys():
	print("{0} = ${1:02x}".format(k,const[k]))
print("")
#
for i in range(0,len(tokList)):
	s = "KWD_"+tok.tokenToText(tokList[i])
	print("{0:30} = ${1:04x} ; {2}".format(s,i,tokList[i].lower()))
print("")
#
#		Keyword text tables - length followed by token text.
#
print("KeywordText:")
for i in range(0,len(tokList)):
	b = [ord(x) for x in (chr(0xFF) if tokList[i].startswith("%") else tokList[i].upper()) ]
	b[-1] |= 0x80
	b.insert(0,len(b))
	b = ",".join(["${0:02x}".format(c) for c in b])
	print('\t.text {0:32} ; ${1:04x} {2}'.format(b,i,tokList[i].lower()))
print("\t.byte 0\n")
#
#		Scan for expression and command handlers
#
xHandler = {}
for root,dirs,files in os.walk("."):
	for f in [x for x in files if x.endswith(".asm")]:
		for l in open(root+os.sep+f):
			if l.find(";;") >= 0:	
				m = re.match("^(.*?)\\:\\s*\\;\\;\\s*(\\[)(.*?)\\]\\s*$",l)
				assert m is not None,"Bad marker line "+l
				key = m.group(3).upper().strip()
				assert key not in xHandler,"Duplicate key "+key 
				xHandler[key] = m.group(1).strip()
#
#		Commands. Table is only for +ve
#
print("\t.align 2")
print("DispatchHandler:")
for i in range(0,len(tokList)):
	t = tokList[i]	
	routine = xHandler[t] if t in xHandler else "SyntaxError" 
	print("\t.word {0:24} ; ${1:04x} {2}".format(routine,i,t.lower()))
print("")