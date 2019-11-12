# ****************************************************************************
# ****************************************************************************
#
#		Name:		translate.py
#		Purpose:	Program/Line translator.
#		Author:		Paul Robson (paul@robsons.org.uk)
#		Created:	8th November 2019
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
		self.tokenLookup = {}												# convert to hash
		for i in range(0,len(self.tokenList)):
			assert self.tokenList[i] not in self.tokenLookup,"Token "+self.tokenList[i]+" dup	"
			self.tokenLookup[self.tokenList[i]] = i + self.tokens.getBaseToken()
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
		m = re.match("^\\&([0-9A-Fa-f]+)(.*)",s)	
		if m is not None:
			self.appendConstant(int(m.group(1),16))
			return m.group(2)
		#
		#		Check comment and string
		#
		m = re.match('^\\"(.*?)\\"(.*)$',s)
		if m is not None:
			self.appendString(0x0100,m.group(1))
			return m.group(2)
		if s.startswith("'"):
			self.appendString(0x0200,s[1:].strip())
			return ""
		#
		#		Check for tokens
		#
		for sz in range(self.longest,0,-1):
			if s[:sz].upper() in self.tokenLookup:
				self.code.append(self.tokenLookup[s[:sz].upper()])
				return s[sz:]
		#
		#		Finally identifiers
		#
		m = re.match("^([A-Za-z\\.]+)(.*)$",s)
		if m is not None:
			ident = m.group(1)[:3]
			self.code.append(self.convertIdentifier(ident))
			return s[len(ident):]

		assert False,"Can't process '"+s+"'"
	#
	#		Append a single constant
	#
	def appendConstant(self,n):
		n = n & 0xFFFF 														# into range
		if (n & 0x8000) != 0:												# in range 8000-FFFF
			self.code.append(self.tokenLookup["HCONST"])					# that marker
		self.code.append(n | 0x8000)										# force into 8000-FFFF
	#
	#		Append a string.
	#
	def appendString(self,base,s):
		s = s.upper() + chr(0)												# Make ASCIIZ
		if len(s) % 2 != 0:													# if even add $FF
			s = s + chr(0xFF)												# so there is no $0000 word.
		self.code.append(base+len(s)+2)										# base + total length in bytes
		for i in range(0,len(s),2):			
			self.code.append(ord(s[i])*0x100+ord(s[i+1]))					
	#
	#		Convert an identifier to a token
	#
	def convertIdentifier(self,ident):
		ident = ident.upper()
		assert len(ident) <= 3 and ident != "" and re.match("^[A-Z\\.]+$",ident) is not None
		mult = 1
		result = 0
		for c in ident:
			result = result + mult * ((ord(c)-ord('@')) if c != "." else 27)
			mult *= 28
		return result+self.tokens.getBaseIdentifierToken()
	#
	#		Translator test.
	#
	def test(self,txt):
		print(" --- "+txt+" ---")
		print("\t["+",".join(["${0:04x}".format(n) for n in self.translateLine(txt)])+"]")
		
if __name__ == "__main__":
	t = Translator()
	t.test("42 43 &2A7 'comment")
	t.test('"qstring" "" "abcd"')
	t.test("+ and[] <= = ==")
	t.test("a z aa and ana xa.bcde.xx z..")