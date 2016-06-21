// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import XCTest
@testable import nrx


class TestRuntimeDelegate : RuntimeDelegate, TestNotation {
	var output: [String] = []
	let symbols = [
		"testVariable": Value("testVariable's value"),
		"testFunction": Value.Callable(TestCallable())
	]
	func print(string: String) {
		output.append(string)
	}
	func resolve(symbol: String) -> Value? {
		return symbols[symbol]
	}
	func lookup(lookup: LookupDescription) -> Value? {
		return Value(lookup.elements.map {
			switch $0 {
			case .Single (let name): return "$"  + name
			case .Multi  (let name): return "$$" + name
			}
		}.joinWithSeparator(""))
	}

	var testNotation: String {
		return output.joinWithSeparator("\n")
	}

	class TestCallable: Callable {
		var parameterNames: [String] { return [] }
		func body(runtime runtime: Runtime) throws -> Value {
			return Value("testFunction's result")
		}
	}
}

extension XCTest {
	var testBundle: NSBundle {
		return NSBundle(forClass: self.dynamicType)
	}

	func readSource(name: String) -> String {
		guard let path = testBundle.URLForResource(name, withExtension: "nrx") else {
			preconditionFailure("no such file: \(name).nrx")
		}
		guard let data = NSData(contentsOfURL: path) else {
			preconditionFailure("could not read file")
		}
		guard let source = NSString(data: data, encoding: NSUTF8StringEncoding) else {
			preconditionFailure("could not decode source")
		}
		return source as String
	}
}
