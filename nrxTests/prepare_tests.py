#!/usr/bin/python

# nrx - https://github.com/NikolaiRuhe/nrx
# copyright 2016, Nikolai Ruhe


import sys
import os
import re
import urllib


class SourceCodeGenerator(object):

	@staticmethod
	def updateUnitTestsFile(inFile, outFile):
		if outFile.endswith(".swift"):
			SwiftSourceCodeGenerator(inFile, outFile).updateOutFile()
		elif outFile.endswith(".m"):
			ObjcSourceCodeGenerator(inFile, outFile).updateOutFile()
		elif outFile.endswith(".java"):
			JavaSourceCodeGenerator(inFile, outFile).updateOutFile()
		else:
			os.write(2, "error: could not detect language: unknown extension\n")


	def __init__(self, inFile, outFile):
		self.inFile    = inFile
		self.outFile   = outFile
		self.testsName = os.path.splitext(os.path.basename(outFile))[0]

	def delimiterLine(self):
		return "// --------- generated tests below this line: do not edit ---------\n"

	def unitTestSourceCode(self):
		source = self.sourceHeader()
		for test in parseTestsFile(self.inFile):
			source += self.sourceForTest(test)
		source += self.sourceFooter()
		return source

	def updateOutFile(self):
		# get modification timestamps of in and out files
		inFileModificationTime  = os.path.getmtime(self.inFile)
		outFileModificationTime = os.path.getmtime(self.outFile)

		# if they are equal, we expect no changes, so return
		if inFileModificationTime == outFileModificationTime:
			os.write(2, "message: unit tests in and outfile timestamps match\n")
			return

		# calculate unit tests source code as to be inserted into outFile
		expectedUnitTestsSourceCode = self.unitTestSourceCode()
#		os.write(1, expectedUnitTestsSourceCode)
#		return

		# check if existing outFile contents ends with generated source code
		fd = open(self.outFile)
		outFileContents = fd.read()
		fd.close()
		if  outFileContents.endswith(expectedUnitTestsSourceCode):
			os.write(2, "message: unit tests outfile is up to date\n")
			return

		if outFileModificationTime > inFileModificationTime:
			os.write(2, "warning: unit tests outfile was modified after infile: skipping update\n")
			return

		pos = outFileContents.find(self.delimiterLine())
		if pos != -1:
			outFileContents = outFileContents[:pos]
		outFileContents += self.delimiterLine()
		outFileContents += expectedUnitTestsSourceCode

		fd = open(self.outFile, "w")
		fd.write(outFileContents)
		fd.close()
		os.utime(self.outFile, (-1, inFileModificationTime))
		os.write(2, "message: updated unit tests outfile\n")


class SwiftSourceCodeGenerator(SourceCodeGenerator):

	def sourceHeader(self):
		return "\nextension %s {\n\n" % self.testsName

	def sourceForTest(self, test):
		context = ""
		if test.context != "":
			context = ", context: \"" + test.context + '"'
		return "\tfunc test%s() {\n\t\tperformTest(input: %s, expectedOutput: %s%s)\n\t}\n\n" % (test.identifierName(), self.stringLiteral(test.input), self.stringLiteral(test.expectedOutput), context)

	def sourceFooter(self):
		return "}\n"

	def stringLiteral(self, input):
		input = input.replace("\\", "\\\\")
		input = input.replace('"', r'\"')
		input = input.replace("\n", r'\n')
		input = input.replace("\r", r'\r')
		input = input.replace("\t", r'\t')
		input = input.replace("\0", r'\0')
		return '"' + input + '"'


class ObjcSourceCodeGenerator(SourceCodeGenerator):

	def sourceHeader(self):
		return """
@interface %s(GeneratedTests) @end

@implementation %s(GeneratedTests)

""" % (self.testsName, self.testsName)

	def sourceForTest(self, test):
		context = ""
		if test.context != "":
			context = " context: \"" + test.context + '"'
		return """- (void)test%s
{
	[self performTestWithInput:@%s expectedOutput:@%s %sfile:__FILE__ line:__LINE__];
}

""" % (test.identifierName(), self.stringLiteral(test.input), self.stringLiteral(test.expectedOutput), context)

	def sourceFooter(self):
		return "@end\n"

	def stringLiteral(self, input):
		input = input.replace("\\", "\\\\")
		input = input.replace('"', r'\"')
		input = input.replace("\n", r'\n')
		input = input.replace("\r", r'\r')
		input = input.replace("\t", r'\t')
		input = input.replace("\0", r'\0')
		return '"' + input + '"'


class JavaSourceCodeGenerator(SourceCodeGenerator):

	def sourceHeader(self):
		return ""

	def sourceForTest(self, test):
		context = ""
		if test.context != "":
			context = ", \"" + test.context + '"'
		return """	@Test
	public void test%s() {
		performTest(%s, %s%s);
	}

""" % (test.identifierName(), self.stringLiteral(test.input), self.stringLiteral(test.expectedOutput), context)

	def sourceFooter(self):
		return ""

	def stringLiteral(self, input):
		input = input.replace("\\", "\\\\")
		input = input.replace('"', r'\"')
		input = input.replace("\n", r'\n')
		input = input.replace("\r", r'\r')
		input = input.replace("\t", r'\t')
		input = input.replace("\0", r'\0')
		return '"' + input + '"'


class UnitTest:
	def __init__(self, context, name, input, expectedOutput):
		self.context = context
		self.name = name
		self.input = input
		self.expectedOutput = expectedOutput

	def __str__(self):
		return "%s.%s: %s -> %s" % (self.context, self.name, str(self.input), str(self.expectedOutput))

	def identifierName(self):
		result = ""
		for segment in re.split("[^a-zA-Z0-9_]", self.name):
			segment = segment.capitalize()
			result += segment
		return result


def parseTestsFile(inFile):
	uniqueNames = set()
	globalContext = ""
	for lineNum, line in enumerate(open(inFile)):
		if line.startswith("#"):
			continue
		line = line.strip()
		if len(line) == 0:
			continue
		if line.startswith("context:"):
			globalContext = line[8:].strip()
			continue
		segments = line.split("#")
		if len(segments) == 3:
			segments.insert(0, globalContext)
		elif len(segments) != 4:
			os.write(2, "warning: %s[%d]: bad test definition\n" % (inFile, lineNum))
			continue
		try:
			segments = map(lambda x: urllib.unquote(x.strip()).decode("UTF-8").encode("UTF-8"), segments)
		except UnicodeDecodeError:
			os.write(2, "warning: %s[%d]: bad utf8\n" % (inFile, lineNum))
			continue

		(context, name, input, output) = (segments[0], segments[1], segments[2], segments[3])

		if name in uniqueNames:
			count = 1
			while True:
				newName = name + "_" + str(count)
				if newName not in uniqueNames:
					name = newName
					break
				count += 1
		uniqueNames.add(name)
		yield UnitTest(context, name, input, output)


def main():
	if len(sys.argv) != 3:
		os.write(2, "usage: %s <Tests.txt> <Tests.swift>\n       %s <Tests.txt> <Tests.m>\n       %s <Tests.txt> <Tests.java>\n" % (os.path.basename(sys.argv[0]), os.path.basename(sys.argv[0])))
		sys.exit(1)
	SourceCodeGenerator.updateUnitTestsFile(sys.argv[1], sys.argv[2])

if __name__ == "__main__":
	main()
