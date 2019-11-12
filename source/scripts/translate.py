# ****************************************************************************
# ****************************************************************************
#
#		Name:		translate.py
#		Purpose:	Program/Line translator.
#		Author:		Paul Robson (paul@robsons.org.uk)
#		Created:	12th November 2019
#
# ****************************************************************************
# ****************************************************************************

import re 
from tokens import *

# ****************************************************************************
#
#					Code translator worker class
#
# ****************************************************************************

class Translator(object):
	#
	#		Create the static values if required.
	#
	def __init__(self):
		self.tokens = Tokens()												# create token info
		self.tokenList = self.tokens.getTokens() 							# get the list.
		self.longest = max([len(x) for x in self.tokenList])				# Longest tokens.
		self.const = self.tokens.getConstants()
		self.tokenLookup = {}												# convert to hash
		for i in range(0,len(self.tokenList)):
			assert self.tokenList[i] not in self.tokenLookup,"Token "+self.tokenList[i]+" dup	"
			self.tokenLookup[self.tokenList[i]] = i
	#
	#		Translate a single line.
	#
	def translateLine(self,line):
		self.code = []														# code words here.
		while line.strip() != "":											# while more
			line =self.translateOne(line).strip()							# translate one element
		return self.code
	#
	#		Translate a single element.
	#
	def translateOne(self,s):
		#
		#		Constants first
		#
		m = re.match("^([0-9]+)(.*)",s)	
		if m is not None:
			self.appendConstant(int(m.group(1)))
			return m.group(2)
		m = re.match("^\\$([0-9A-Fa-f]+)(.*)",s)	
		if m is not None:
			self.appendConstant(int(m.group(1),16))
			return m.group(2)
		#
		#		Check comment,define and string
		#
		m = re.match('^\\"(.*?)\\"(.*)$',s)
		if m is not None:
			self.appendString(self.tokenLookup["%QSTRING"],m.group(1))
			return m.group(2)
		if s.startswith("'"):
			self.appendString(self.tokenLookup["%COMMENT"],s[1:].strip())
			return ""
		m = re.match("^\\:([A-Za-z\\.]+)(.*)",s)
		if m is not None:
			self.code.append(self.tokenLookup["%DEFINE"])
			self.code.append(len(m.group(1)))
			self.code += self.convertIdentifier(m.group(1))
			return m.group(2)
		#
		#		Check for tokens
		#
		for sz in range(self.longest,0,-1):
			w = s[:sz].upper()
			if w in self.tokenLookup and re.match("^[A-Z]$",w) is None:
				self.code.append(self.tokenLookup[w])
				return s[sz:]
		#
		#		Finally identifiers
		#
		m = re.match("^([A-Za-z\\.]+)(.*)$",s)
		if m is not None:
			self.code += self.convertIdentifier(m.group(1))
			return m.group(2).strip()

		assert False,"Can't process '"+s+"'"
	#
	#		Append a single constant
	#
	def appendConstant(self,n):
		if n < 63:
			self.code.append(0x80+n)
		else:
			self.code.append(self.tokenLookup["%CONST"])
			n = n & 0xFFFF
			self.code.append(n & 0xFF)
			self.code.append(n >> 8)
	#
	#		Append a string.
	#
	def appendString(self,base,s):		
		self.code.append(base)												# base + total length in bytes
		self.code.append(len(s))		
		self.code += [ord(x) for x in s.upper()]
	#
	#		Convert an identifier to a token
	#
	def convertIdentifier(self,ident):
		ident = ident.upper().replace(".",chr(ord('Z')+1))
		ident = [ord(x)-ord('A')+0xC0 for x in ident]
		ident[-1] += 0x20
		return ident
	#
	#		Translator test.
	#
	def test(self,txt):
		print(" --- "+txt+" ---")
		print("\t["+",".join(["${0:02x}".format(n) for n in self.translateLine(txt)])+"]")
		
if __name__ == "__main__":
	t = Translator()
	t.test("42 43 $2A7 'comment")
	t.test('"qstring" "" "abcd"')
	t.test("+ and [ ] <= = ==")
	t.test("a z aacd and ana xa.bcde.xx z..")
	t.test(":hello.world 42 ;")
	t.test("hello.world")
