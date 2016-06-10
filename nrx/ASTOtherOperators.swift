// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


final class ASTConditionalOperator: ASTExpression {
	let _condition: ASTExpression
	let _positiveExpression: ASTExpression
	let _negativeExpression: ASTExpression

	required init(condition: ASTExpression, positiveExpression: ASTExpression, negativeExpression: ASTExpression) {
		_condition = condition
		_positiveExpression = positiveExpression
		_negativeExpression = negativeExpression
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let condition = try _condition.evaluate(runtime: runtime).boolValue()
		let branch = condition ? _positiveExpression : _negativeExpression
		return try branch.evaluate(runtime: runtime)
	}
}


final class ASTLookup: ASTExpression {
	let _lookup: LookupDescription

	init(elements: [LookupDescription.Element]) {
		_lookup = LookupDescription(elements: elements)
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try runtime.lookup(_lookup)
	}
}

final class ASTIdentifier: ASTExpression {
	let _name: String

	init(name: String) {
		_name = name
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try runtime.resolve(_name)
	}
}

final class ASTAccess: ASTExpression {
	let _object: ASTExpression
	let _name: String

	init(object: ASTExpression, name: String) {
		_object = object
		_name = name
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try _object.evaluate(runtime: runtime).performAccess(_name)
	}
}

final class ASTWhereOperator: ASTExpression, Callable {
	let _iterableExpression: ASTExpression
	let _identifier: String
	let _predicateExpression: ASTExpression

	init(iterableExpression: ASTExpression, identifier: String, predicateExpression: ASTExpression) {
		_iterableExpression = iterableExpression
		_identifier = identifier
		_predicateExpression = predicateExpression
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let iterable = try _iterableExpression.evaluate(runtime: runtime)
		let filteredElements = try iterable.sequence().filter {
			(element: Value) -> Bool in
			return try runtime.call(self, arguments: [element], inNestedScope: true).boolValue()
		}
		return Value.List(filteredElements)
	}

	var name: String { return "where" }
	var parameterNames: [String] { return [_identifier] }
	var body: (runtime: Runtime) throws -> Value {
		return {
			(runtime: Runtime) -> Value in
			return try self._predicateExpression.evaluate(runtime: runtime)
		}
	}
}

final class ASTMapOperator: ASTExpression, Callable {
	let _iterableExpression: ASTExpression
	let _identifier: String
	let _transformExpression: ASTExpression

	init(iterableExpression: ASTExpression, identifier: String, transformExpression: ASTExpression) {
		_iterableExpression = iterableExpression
		_identifier = identifier
		_transformExpression = transformExpression
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let iterable = try _iterableExpression.evaluate(runtime: runtime)
		let transformedElements = try iterable.sequence().map {
			(element: Value) -> Value in
			return try runtime.call(self, arguments: [element], inNestedScope: true)
		}
		return Value.List(transformedElements)
	}

	var name: String { return "map" }
	var parameterNames: [String] { return [_identifier] }
	var body: (runtime: Runtime) throws -> Value {
		return {
			(runtime: Runtime) -> Value in
			return try self._transformExpression.evaluate(runtime: runtime)
		}
	}
}

final class ASTCall: ASTExpression {
	let _callable: ASTExpression
	let _arguments: [ASTExpression]

	init(callable: ASTExpression, arguments: [ASTExpression]) {
		_callable = callable
		_arguments = arguments
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let callable = try _callable.evaluate(runtime: runtime).callable()
		let arguments = try _arguments.map {
			(argument: ASTExpression) -> Value in
			return try argument.evaluate(runtime: runtime)
		}
		return try runtime.call(callable, arguments: arguments, inNestedScope: false)
	}
}

final class ASTSubscript: ASTExpression {
	let _container: ASTExpression
	let _key: ASTExpression

	init(container: ASTExpression, key: ASTExpression) {
		_container = container
		_key = key
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let container = try _container.evaluate(runtime: runtime)
		let key = try _key.evaluate(runtime: runtime)
		return try container.performSubscript(key)
	}
}
