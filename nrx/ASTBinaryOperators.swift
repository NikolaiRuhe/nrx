// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


final class ASTExcept: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		do {
			return try _lhs.evaluate(runtime: runtime)
		} catch EvaluationError.Exception {
			return try _rhs.evaluate(runtime: runtime)
		}
	}
}

final class ASTContains: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let lhs = try _lhs.evaluate(runtime: runtime)
		let rhs = try _rhs.evaluate(runtime: runtime)
		return try Value(lhs.sequence().contains {
			(element: Value) -> Bool in
			return element == rhs
		})
	}
}

final class ASTLogicOr: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try Value(_lhs.evaluate(runtime: runtime).boolValue() || _rhs.evaluate(runtime: runtime).boolValue())
	}
}

final class ASTLogicAnd: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try Value(_lhs.evaluate(runtime: runtime).boolValue() && _rhs.evaluate(runtime: runtime).boolValue())
	}
}

final class ASTEqual: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try Value(_lhs.evaluate(runtime: runtime) == _rhs.evaluate(runtime: runtime))
	}
}

final class ASTNotEqual: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try Value(_lhs.evaluate(runtime: runtime) != _rhs.evaluate(runtime: runtime))
	}
}

final class ASTGreaterThan: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let lhs = try _lhs.evaluate(runtime: runtime)
		let rhs = try _rhs.evaluate(runtime: runtime)
		let order = try lhs.compare(rhs)
		return Value(order == .OrderedDescending)
	}
}

final class ASTGreaterOrEqual: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let lhs = try _lhs.evaluate(runtime: runtime)
		let rhs = try _rhs.evaluate(runtime: runtime)
		let order = try lhs.compare(rhs)
		return Value(order == .OrderedDescending || order == .OrderedSame)
	}
}

final class ASTLessThan: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let lhs = try _lhs.evaluate(runtime: runtime)
		let rhs = try _rhs.evaluate(runtime: runtime)
		let order = try lhs.compare(rhs)
		return Value(order == .OrderedAscending)
	}
}

final class ASTLessOrEqual: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		let lhs = try _lhs.evaluate(runtime: runtime)
		let rhs = try _rhs.evaluate(runtime: runtime)
		let order = try lhs.compare(rhs)
		return Value(order == .OrderedAscending || order == .OrderedSame)
	}
}

final class ASTAddition: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try _lhs.evaluate(runtime: runtime) + _rhs.evaluate(runtime: runtime)
	}
}

final class ASTSubtraction: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try _lhs.evaluate(runtime: runtime) - _rhs.evaluate(runtime: runtime)
	}
}

final class ASTMultiplication: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try _lhs.evaluate(runtime: runtime) * _rhs.evaluate(runtime: runtime)
	}
}

final class ASTDivision: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try _lhs.evaluate(runtime: runtime) / _rhs.evaluate(runtime: runtime)
	}
}

final class ASTModulo: ASTBinaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try _lhs.evaluate(runtime: runtime) % _rhs.evaluate(runtime: runtime)
	}
}
