# ****************************************************************************
# ****************************************************************************
#
#		Name:		generate.py
#		Purpose:	Creates tables, constants
#		Author:		Paul Robson (paul@robsons.org.uk)
#		Created:	8th November 2019
#
# ****************************************************************************
# ****************************************************************************

from tokens import *
import os,sys,re 

tok = Tokens()
tokList = tok.getTokens()
base = tok.getBaseToken()
#
#		Constants
#
print("{0:30} = ${1:x}".format("TOKEN_BASE",tok.getBaseToken()))
print("{0:30} = ${1:x}".format("TOKEN_FIRSTCMD",tok.getFirstCommandToken()))
print("{0:30} = ${1:x}".format("TOKEN_BASEIDENTIFIER",tok.getBaseIdentifierToken()))
print("")
#
for i in range(0,len(tokList)):
	s = "KWD_"+tok.tokenToText(tokList[i])
	print("{0:30} = ${1:04x} ; {2}".format(s,i+base,tokList[i].lower()))
print("")
#
#		Keyword text tables - length followed by token text.
#
print("KeywordText:")
for i in range(0,len(tokList)):
	b = [ord(x) for x in tokList[i].upper()]
	b[-1] |= 0x80
	b.insert(0,len(b))
	b = ",".join(["${0:02x}".format(c) for c in b])
	print('\t.text {0:32} ; ${1:04x} {2}'.format(b,i+base,tokList[i].lower()))
print("\t.byte 0\n")
#
#		Scan for expression and command handlers
#
xHandler = {}
cHandler = {}
for root,dirs,files in os.walk("."):
	for f in [x for x in files if x.endswith(".asm")]:
		for l in open(root+os.sep+f):
			if l.find(";;") >= 0:	
				m = re.match("^(.*?)\\:\\s*\\;\\;\\s*(\\[)(.*?)\\]\\s*$",l)
				if m is None:
					m = re.match("^(.*?)\\:\\s*\\;\\;\\s*(\\<)(.*?)\\>\\s*$",l)
				assert m is not None,"Bad marker line "+l
				chash = xHandler if m.group(2) == "[" else cHandler
				key = m.group(3).upper().strip()
				assert key not in chash,"Duplicate key "+key 
				chash[key] = m.group(1).strip()
#
#		Expressions
#
print("ExpressionHandler:")
for i in range(0,tok.getFirstCommandToken()-base):
	t = tokList[i]
	routine = "ExitExpression" if t not in xHandler else xHandler[t]
	print("\t.word {0:24} ; ${1:04x} {2}".format(routine,i+base,t.lower()))
print("")
#
#		Commands
#
print("CommandHandler:")
for i in range(0,len(tokList)):
	t = tokList[i]
	routine = "SyntaxError" if t not in cHandler else cHandler[t]
	print("\t.word {0:24} ; ${1:04x} {2}".format(routine,i+base,t.lower()))
print("")