# ****************************************************************************
# ****************************************************************************
#
#		Name:		makeprogram.py
#		Purpose:	Program Converter
#		Author:		Paul Robson (paul@robsons.org.uk)
#		Created:	12th November 2019
#
# ****************************************************************************
# ****************************************************************************

import re,sys,os 
from translate import *

# ****************************************************************************
#
#					Basic Program Converter Class
#
# ****************************************************************************

class BasicProgram(object):
	def __init__(self):
		self.translator = Translator()
		self.code = []
		self.lineStart = 1000
		self.lineStep = 10
	#
	#		Add a code file.
	#
	def addFile(self,fileName,stripComments = True):
		self.definitions = {}
		self.src = open(fileName).readlines()								# read and tidy up.
		if stripComments:
			self.src = [s if s.find("//") < 0 else s[:s.find("//")] for s in self.src]
		self.src = [s.strip().upper().replace("\t"," ") for s in self.src if s.strip() != ""]		

		for i in range(0,len(self.src)):									# scan for word definitions.
			if self.src[i].startswith(":"):									# : first ?
				m = re.match("^\\:([A-Z\\.]+)",self.src[i])					# check matching identifier
				if m is not None:											# store the name.
					assert m.group(1) not in self.definitions,"Duplicate "+m.group(1)
					self.definitions[m.group(1)] = self.lineStart+i*self.lineStep
		for i in range(0,len(self.src)):									# output the code.
			self.addLine(self.lineStart+i*self.lineStep,self.src[i])
	#
	#		Add a single line.
	#
	def addLine(self,num,line):
		lineCode = self.translator.translateLine(line,self.definitions)
		self.code.append(len(lineCode)+3+1)									# 3 for header, 1 for $00
		self.code.append(num & 0xFF)										# line number LSB
		self.code.append(num >> 8)											# line number MSB
		for w in lineCode:													# output tokenised code
			self.code.append(w)
		self.code.append(0)													# EOL Marker
	#
	#		Complete
	#
	def complete(self):
		self.code.append(0)													# final offset 0
	#
	#		Write as source
	#
	def writeInclude(self,h = sys.stdout):
		h.write("\t.byte\t{0}\n".format(",".join(["${0:02x}".format(c) for c in self.code])))

if __name__ == "__main__":
	bp = BasicProgram()
	bp.addFile("src.bas")
	bp.writeInclude(open("generated"+os.sep+"program.inc","w"))
