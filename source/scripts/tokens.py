# ****************************************************************************
# ****************************************************************************
#
#		Name:		tokens.py
#		Purpose:	Token lists for RPL/65
#		Author:		Paul Robson (paul@robsons.org.uk)
#		Created:	12th November 2019
#
# ****************************************************************************
# ****************************************************************************

import re 

# ****************************************************************************
#
#									Token Class
#
# ****************************************************************************

class Tokens(object):
	#
	#		Create the static values if required.
	#
	def __init__(self):
		if Tokens.tokenList is None:										# create token list
			Tokens.tokenList = []											
			Tokens.constants = {}
			self.currentToken = 0
			self.addTokens("%eol %const %call %comment %qstring %define")
			self.mark("TOK_NOT_CONTROL")
			self.mark("TOK_STRUCT_INC")
			self.addTokens("if repeat for")
			self.mark("TOK_STRUCT_DEC")
			self.addTokens("endif until next")
			self.mark("TOK_STRUCT_NEUTRAL")
			self.addTokens(self.getStandardTokens())						# get the other tokens
	#
	#		Add tokens to the list
	#
	def addTokens(self,tokens):
		tokens = tokens.upper().split() 									# convert them.
		Tokens.tokenList += tokens 											# add to the token list
		self.currentToken += len(tokens)									# adjust token IDs
	#
	#		Mark the current constant.
	#		
	def mark(self,name):
		Tokens.constants[name.strip().upper()] = self.currentToken
	#
	#		Get the token list
	#
	def getTokens(self):
		return Tokens.tokenList
	#
	#		Get the constants
	#
	def getConstants(self):
		return Tokens.constants
	#
	#		Convert a token to an assemblable label.
	#
	def tokenToText(self,t):
		t = t.replace("+","PLUS").replace("-","MINUS").replace("*","STAR").replace("/","SLASH")
		t = t.replace("<","LESS").replace("=","EQUAL").replace(">","GREATER").replace("|","BAR")
		t = t.replace("!","PLING").replace("?","QMARK").replace("[","LSQPAREN").replace("]","RSQPAREN")
		t = t.replace("$","DOLLAR").replace(",","COMMA").replace(":","COLON").replace("%","SYS_")
		t = t.replace("(","LPAREN").replace(")","RPAREN").replace("&","AMPERSAND").replace("^","HAT")
		t = t.replace(".","DOT").replace("@","AT").replace(";","SEMICOLON").replace("#","HASH")
		#t = t.replace("","").replace("","").replace("","").replace("","").replace("","")
		assert re.match("^[A-Z\\_]+$",t) is not None,"Bad token "+t
		return t
	#
	#		Get the main tokens.
	#
	def getStandardTokens(self):
		return """
			* /	mod	+ -	and	or xor shl shr
			= <> > < >= <=
			c@ c! @ ! d! alloc ^ [ ] sys ? #
			abs negate not ++ -- bswap << >> sgn rnd
			clr drop dup nip over swap
			else index ; assert
			list new old stop run end save load
		"""

Tokens.tokenList = None

if __name__ == "__main__":
		t = Tokens()
		tk = t.getTokens()
		for i in range(0,len(tk)):
			print("${0:02x} {1:12} {2}".format(i,tk[i],t.tokenToText(tk[i])))
		print(t.getTokens())
		print(t.getConstants())
				