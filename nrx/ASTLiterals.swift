// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


final class ASTNullLiteral: ASTLiteral {
	internal static let instance: ASTNullLiteral = ASTNullLiteral()

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return Value.Null
	}
}

final class ASTBoolLiteral: ASTLiteral {
	let _value: Bool

	init(_ value: Bool) {
		_value = value
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return Value(_value)
	}
}

final class ASTNumberLiteral: ASTLiteral {
	let _value: Float64

	init?(fromString: String) {
		guard let value = Float64(fromString) else {
			return nil
		}
		_value = value
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return Value(_value)
	}
}

final class ASTStringLiteral: ASTLiteral {
	let _value: String

	init(_ value: String) {
		_value = value
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return Value(_value)
	}
}

final class ASTListLiteral: ASTLiteral {
	let _elements: [ASTExpression]

	init(elements: [ASTExpression]) {
		_elements = elements
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let elements: [Value] = try _elements.map { try $0.evaluate(runtime: runtime) }
		return Value.List(elements)
	}
}

final class ASTDictLiteral: ASTLiteral {
	let _pairs: [(ASTExpression, ASTExpression)]

	init(pairs: [(ASTExpression, ASTExpression)]) {
		_pairs = pairs
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		var dictionary: [String: Value] = [:]
		for tuple in _pairs {
			let key = try tuple.0.evaluate(runtime: runtime).stringValue()
			let value = try tuple.1.evaluate(runtime: runtime)
			guard dictionary[key] == nil else {
				throw EvaluationError.Exception(reason: "duplicate key in Dictionary literal")
			}
			dictionary[key] = value
		}
		return Value.Dictionary(dictionary)
	}
}
