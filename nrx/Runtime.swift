// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


/// The Runtime class is used for evaluation of AST nodes. It represents the current state
/// and holds values like variables or globals, serves as a proxy for application specific
/// functionality like lookup and is the delegate for error reporting.

public class Runtime {

	private var stack: [Scope] = [Scope()]
	private var globalScope: Scope = Scope()
	let delegate: RuntimeDelegate

	init(delegate: RuntimeDelegate?) {
		self.delegate = delegate ?? DefaultRuntimeDelegate()
	}

	static func run(source: String, delegate: RuntimeDelegate? = nil) throws {
		let parser = Parser(lexer: Lexer(source: source))
		let program = try parser.parseProgram()
		try run(program, delegate: delegate)
	}

	static func run(program: ASTBlock, delegate: RuntimeDelegate? = nil) throws {
		let runtime = Runtime(delegate: delegate)
		try program.evaluate(runtime: runtime)
	}

	private var currentScope: Scope {
		guard let scope = stack.last else {
			preconditionFailure("stack is empty")
		}
		return scope
	}

	func print(string: String) {
		delegate.print(string)
	}
	
	func lookup(lookup: LookupDescription) throws -> Value {
		if let value = delegate.lookup(lookup) {
			return value
		}

		throw EvaluationError.Exception(reason: "lookup error: not found")
	}

	func resolve(symbol: String) throws -> Value {
		if let value = currentScope[symbol] {
			return value
		}

		if let value = globalScope[symbol] {
			return value
		}

		if let value = delegate.resolve(symbol) {
			return value
		}

		throw EvaluationError.Exception(reason: "could not resolve \"\(symbol)\"")
	}

	func assign(value: Value, toSymbol symbol: String, inGlobalScope: Bool = false) {
		let scope = inGlobalScope ? globalScope : currentScope
		scope[symbol] = value
	}

	func setProperty(parent parent: Value, propertyName: String, value: Value) throws {
		// TODO: implement
	}

	func call(callable: Callable, arguments: [Value], inNestedScope: Bool) throws -> Value {
		// push an empty or copied (nested) scope
		try pushScope(nested: inNestedScope)

		defer {
			popScope()
		}

		// arguments and parameters must match
		guard arguments.count == callable.parameterNames.count else {
			throw EvaluationError.Exception(reason: "number of arguments do not match parameters")
		}

		// assign arguments to parameter names in the new scope
		for (parameterName, argument) in zip(callable.parameterNames, arguments) {
			assign(argument, toSymbol: parameterName)
		}

		do {
			// call the body of the function
			return try callable.body(runtime: self)
		} catch ControlFlow.Return(let value) {
			return value
		} catch ControlFlow.Break {
			throw EvaluationError.Exception(reason: "break without enclosing loop")
		} catch ControlFlow.Continue {
			throw EvaluationError.Exception(reason: "continue without enclosing loop")
		}
	}

	private func pushScope(nested nested: Bool) throws {
		guard stack.count < maxCallDepth else {
			throw EvaluationError.Exception(reason: "call stack exceeded")
		}
		let newScope = nested ? Scope(currentScope) : Scope()
		stack.append(newScope)
	}

	private func popScope() {
		guard stack.count >= 2 else {
			preconditionFailure("call stack push/pop mismatch")
		}
		stack.removeLast()
	}

	class Scope {
		private var symbols: [String: Value]
		private init(_ other: Scope? = nil) {
			symbols = other?.symbols ?? [:]
		}
		subscript (symbol: String) -> Value? {
			get { return symbols[symbol] }
			set { symbols[symbol] = newValue }
		}
	}

	class DefaultRuntimeDelegate : RuntimeDelegate {
	}
}

private let maxCallDepth = 1024


/// The type uesed for all runtime exceptions.
enum EvaluationError : ErrorType {
	case Exception(reason: String)
}


/// The type uesed for all runtime exceptions.
enum ControlFlow : ErrorType {
	case Return(value: Value)
	case Continue
	case Break
}


protocol RuntimeDelegate {
	func resolve(symbol: String) -> Value?
	func lookup(lookup: LookupDescription) -> Value?
	func print(string: String)
}

extension RuntimeDelegate {
	func print(string: String) {
		print(string)
	}
	func resolve(symbol: String) -> Value? {
		return nil
	}
	func lookup(lookup: LookupDescription) -> Value? {
		return nil
	}
}

/// A function like object that takes arguments and returns a value when called.
protocol Callable: class {
	var parameterNames: [String] { get }
	func body(runtime runtime: Runtime) throws -> Value
}


/// To use an application defined object as a value, it must conform to the `Bridgeable`
/// protocol.
protocol Bridgeable: class {
	var nrx_typeString: String { get }
	func nrx_isEqual(other: Bridgeable) -> Bool
	var nrx_debugDescription: String { get }
	func nrx_callable() -> Callable?
}
