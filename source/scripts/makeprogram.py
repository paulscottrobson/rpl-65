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
		self.nextLine = 1000
		self.lineStep = 10
	#
	#		Add a code file.
	#
	def addFile(self,fileName,stripComments = True):
		for s in open(fileName).readlines():
			if stripComments:
				s = s if s.find("//") < 0 else s[:s.find("//")]
			s = s.strip()
			if s != "":
				self.addLine(s)
	#
	#		Add a single line.
	#
	def addLine(self,line):
		lineCode = self.translator.translateLine(line)
		self.code.append(len(lineCode)+3+1)									# 3 for header, 1 for $00
		self.code.append(self.nextLine & 0xFF)								# line number LSB
		self.code.append(self.nextLine >> 8)								# line number MSB
		self.nextLine += self.lineStep
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
