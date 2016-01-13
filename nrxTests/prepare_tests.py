#!/usr/bin/python

import sys
import os
import re
import urllib

TESTS_DELIMITER_LINE = "// --------- generated tests below this line: do not edit ---------\n"

def swiftStringLiteral(input):
	input = input.replace("\\", "\\\\")
	input = input.replace('"', r'\"')
	input = input.replace("\n", r'\n')
	input = input.replace("\r", r'\r')
	input = input.replace("\t", r'\t')
	input = input.replace("\0", r'\0')
	return '"' + input + '"'

class UnitTest:
	def __init__(self, name, input, expectedOutput):
		self.name = name
		self.input = input
		self.expectedOutput = expectedOutput

	def __str__(self):
		return "%s: %s -> %s" % (self.name, str(self.input), str(self.expectedOutput))

	def identifierName(self):
		result = ""
		for segment in re.split("[^a-zA-Z0-9_]", self.name):
			segment = segment.capitalize()
			result+= segment
		return result

	def swiftSourceCode(self):
		return "\tfunc test%s() {\n\t\tperformTest(input: %s, expectedOutput: %s)\n\t}\n\n" % (self.identifierName(), swiftStringLiteral(self.input), swiftStringLiteral(self.expectedOutput))

def parseTestsFile(inFile):
	for lineNum, line in enumerate(open(inFile)):
		if line.startswith("#"):
			continue
		line = line.strip()
		if len(line) == 0:
			continue
		segments = line.split("#")
		if len(segments) != 3:
			os.write(2, "warning: %s[%d]: bad test definition\n" % (inFile, lineNum))
			continue
		try:
			segments = map(lambda x: urllib.unquote(x.strip()).decode("UTF-8").encode("UTF-8"), segments)
		except UnicodeDecodeError:
			os.write(2, "warning: %s[%d]: bad utf8\n" % (inFile, lineNum))
			continue

		yield UnitTest(segments[0], segments[1], segments[2])


def prepareUnitTestsFile(inFile, outFile):
	# get modification timestamps of in and out files
	inFileModificationTime  = os.path.getmtime(inFile)
	outFileModificationTime = os.path.getmtime(outFile)

	# if they are equal, we expect no changes, so return
	if inFileModificationTime == outFileModificationTime:
		os.write(2, "message: unit tests in and outfile timestamps match\n")
		return True

	# calculate unit tests source code as to be inserted into outFile
	expectedUnitTestsSourceCode = unitTestSourceCode(inFile)

	# check if existing outFile contents ends with generated source code
	fd = open(outFile)
	outFileContents = fd.read()
	fd.close()
	if  outFileContents.endswith(expectedUnitTestsSourceCode):
		os.write(2, "message: unit tests outfile is up to date\n")
		return True

	if outFileModificationTime > inFileModificationTime:
		os.write(2, "warning: unit tests outfile was modified after infile: skipping update\n")
		return False

	pos = outFileContents.find(TESTS_DELIMITER_LINE)
	if pos != -1:
		outFileContents = outFileContents[:pos]
	outFileContents += TESTS_DELIMITER_LINE
	outFileContents += expectedUnitTestsSourceCode

	fd = open(outFile, "w")
	fd.write(outFileContents)
	fd.close()
	os.utime(outFile, (-1, inFileModificationTime))
	os.write(2, "message: updated unit tests outfile\n")
	return True


def unitTestSourceCode(inFile):
	source = "\nextension %s {\n\n" % os.path.splitext(os.path.basename(inFile))[0]
	for test in parseTestsFile(inFile):
		source += test.swiftSourceCode()
	source += "}\n"
	return source

def main():
	if len(sys.argv) != 3:
		os.write(2, "usage: %s <Tests.txt> <Tests.swift>\n" % os.path.basename(sys.argv[0]))
		sys.exit(1)
	prepareUnitTestsFile(sys.argv[1], sys.argv[2])

if __name__ == "__main__":
	main()