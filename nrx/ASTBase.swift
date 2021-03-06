// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


/// The ASTNode class is the base class for types in the abstract syntax tree (AST).
/// Subclasses serve as a hierarchical representation of the source code (compile time), and,
/// implement the means for evaluation of the code (runtime).
class ASTNode {
	func evaluate(runtime runtime: Runtime) throws -> Value {
		preconditionFailure("evaluate must be implemented in concrete subclasses")
	}
}


/// Base class for all expressions and operators.
/// Calling evaluate always returns a value or an exception.
class ASTExpression: ASTNode {
}


/// Base class for literals.
class ASTLiteral: ASTExpression {
}


/// Base class for prefix operators with a single operand.
class ASTUnaryOperator: ASTExpression {
	let _operand: ASTExpression

	required init(operand: ASTExpression) {
		_operand = operand
	}
}


/// Base class for infix operators with two operands.
class ASTBinaryOperator: ASTExpression {
	let _lhs: ASTExpression
	let _rhs: ASTExpression

	required init(lhs: ASTExpression, rhs: ASTExpression) {
		_lhs = lhs
		_rhs = rhs
	}
}


/// Base class for statements.
///
/// Statements always return `Null` or throw when evaluating.
class ASTStatement: ASTNode {

	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return Value.Null
	}
}
