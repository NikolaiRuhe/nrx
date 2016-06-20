// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


class ASTNoOp: ASTStatement {
	internal static let instance: ASTNoOp = ASTNoOp()
}

class ASTContinue: ASTStatement {
	internal static let instance: ASTContinue = ASTContinue()

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		throw ControlFlow.Continue
	}
}

class ASTBreak: ASTStatement {
	internal static let instance: ASTBreak = ASTBreak()

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		throw ControlFlow.Break
	}
}


class ASTBlock: ASTStatement {
	private let _statements: [ASTStatement]

	required init(statements: [ASTStatement]) {
		_statements = statements
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		for statement in _statements {
			try statement.evaluate(runtime: runtime)
		}
		return Value.Null
	}
}

class ASTSingleExpressionStatement: ASTStatement {
	private let _expression: ASTExpression

	required init(expression: ASTExpression) {
		_expression = expression
	}
}

class ASTPrint: ASTSingleExpressionStatement {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let value = try _expression.evaluate(runtime: runtime)
		runtime.print(value.description)
		return Value.Null
	}
}

class ASTAssert: ASTSingleExpressionStatement {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		guard try _expression.evaluate(runtime: runtime).boolValue() else {
			throw EvaluationError.Exception(reason: "assert failed")
		}
		return Value.Null
	}
}

class ASTError: ASTSingleExpressionStatement {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let message = try _expression.evaluate(runtime: runtime).stringValue()
		throw EvaluationError.Exception(reason: message)
	}
}

class ASTReturn: ASTSingleExpressionStatement {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let value = try _expression.evaluate(runtime: runtime)
		throw ControlFlow.Return(value: value)
	}
}

class ASTWhile: ASTStatement {
	private let _condition: ASTExpression
	private let _body: ASTStatement

	init(condition: ASTExpression, body: ASTStatement) {
		_condition = condition
		_body = body
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		while try _condition.evaluate(runtime: runtime).boolValue() {
			do {
				try _body.evaluate(runtime: runtime)
			} catch ControlFlow.Continue {
				continue
			} catch ControlFlow.Break {
				break
			}
		}
		return Value.Null
	}
}

class ASTIfElse: ASTStatement {
	private let _condition: ASTExpression
	private let _statement: ASTStatement
	private let _elseStatement: ASTStatement

	init(condition: ASTExpression, statement: ASTStatement, elseStatement: ASTStatement) {
		_condition = condition
		_statement = statement
		_elseStatement = elseStatement
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		if try _condition.evaluate(runtime: runtime).boolValue() {
			try _statement.evaluate(runtime: runtime)
		} else {
			try _elseStatement.evaluate(runtime: runtime)
		}
		return Value.Null
	}
}

class ASTTryCatch: ASTStatement, Callable {
	private let _body: ASTBlock
	private let _variable: String
	private let _catchBlock: ASTBlock

	init(body: ASTBlock, variable: String, catchBlock: ASTBlock) {
		_body = body
		_variable = variable
		_catchBlock = catchBlock
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		do {
			try _body.evaluate(runtime: runtime)
		} catch EvaluationError.Exception(let message) {
			try runtime.call(self, arguments: [Value(message)], inNestedScope: true)
		}
		return Value.Null
	}

	var parameterNames: [String] { return [_variable] }
	func body(runtime runtime: Runtime) throws -> Value {
		return try _catchBlock.evaluate(runtime: runtime)
	}
}

class ASTForIn: ASTStatement, Callable {
	private let _variable: String
	private let _iterable: ASTExpression
	private let _body: ASTStatement

	init(variable: String, iterable: ASTExpression, body: ASTStatement) {
		_variable = variable
		_iterable = iterable
		_body = body
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let iterable = try _iterable.evaluate(runtime: runtime).sequence()
		for element in iterable {
			do {
				try runtime.call(self, arguments: [element], inNestedScope: true)
			} catch ControlFlow.Continue {
				continue
			} catch ControlFlow.Break {
				break
			}
		}
		return Value.Null
	}

	var parameterNames: [String] { return [_variable] }
	func body(runtime runtime: Runtime) throws -> Value {
		return try _body.evaluate(runtime: runtime)
	}
}

class ASTPropertyAssignment: ASTStatement {
	private let _lhs: ASTExpression
	private let _name: String
	private let _rhs: ASTExpression

	init(lhs: ASTExpression, name: String, rhs: ASTExpression) {
		_lhs = lhs
		_name = name
		_rhs = rhs
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let lhs = try _lhs.evaluate(runtime: runtime)
		let rhs = try _rhs.evaluate(runtime: runtime)
		try runtime.setProperty(parent: lhs, propertyName: _name, value: rhs)
		return Value.Null
	}
}

class ASTAssignment: ASTStatement {
	private let _name: String
	private let _rhs: ASTExpression

	init(name: String, rhs: ASTExpression) {
		_name = name
		_rhs = rhs
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let rhs = try _rhs.evaluate(runtime: runtime)
		runtime.assign(rhs, toSymbol: _name)
		return Value.Null
	}
}

class ASTCallStatement: ASTStatement {
	private let _callExpression: ASTCall

	init(callExpression: ASTCall) {
		_callExpression = callExpression
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		try _callExpression.evaluate(runtime: runtime)
		return Value.Null
	}
}

class ASTFunctionDefinitionStatement: ASTStatement, Callable {
	private let _name: String
	let parameterNames: [String]
	private let _body: ASTBlock

	init(name: String, parameterNames: [String], body: ASTBlock) {
		_name = name
		self.parameterNames = parameterNames
		_body = body
	}

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		runtime.assign(Value.Callable(self), toSymbol: _name, inGlobalScope:true)
		return Value.Null
	}

	func body(runtime runtime: Runtime) throws -> Value {
		return try _body.evaluate(runtime: runtime)
	}
}
