// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


final class ASTExcept: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		do {
			return try _lhs.evaluate(context: context)
		} catch EvaluationError.Exception {
			return try _rhs.evaluate(context: context)
		}
	}
}

final class ASTContains: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		let lhs = try _lhs.evaluate(context: context)
		let rhs = try _rhs.evaluate(context: context)
		return try Value(lhs.sequence().contains {
			(element: Value) -> Bool in
			return element == rhs
		})
	}
}

final class ASTLogicOr: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try Value(_lhs.evaluate(context: context).boolValue() || _rhs.evaluate(context: context).boolValue())
	}
}

final class ASTLogicAnd: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try Value(_lhs.evaluate(context: context).boolValue() && _rhs.evaluate(context: context).boolValue())
	}
}

final class ASTEqual: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try Value(_lhs.evaluate(context: context) == _rhs.evaluate(context: context))
	}
}

final class ASTNotEqual: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try Value(_lhs.evaluate(context: context) != _rhs.evaluate(context: context))
	}
}

final class ASTGreaterThan: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try Value(_lhs.evaluate(context: context) > _rhs.evaluate(context: context))
	}
}

final class ASTGreaterOrEqual: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try Value(_lhs.evaluate(context: context) >= _rhs.evaluate(context: context))
	}
}

final class ASTLessThan: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try Value(_lhs.evaluate(context: context) < _rhs.evaluate(context: context))
	}
}

final class ASTLessOrEqual: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try Value(_lhs.evaluate(context: context) <= _rhs.evaluate(context: context))
	}
}

final class ASTAddition: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try _lhs.evaluate(context: context) + _rhs.evaluate(context: context)
	}
}

final class ASTSubtraction: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try _lhs.evaluate(context: context) - _rhs.evaluate(context: context)
	}
}

final class ASTMultiplication: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try _lhs.evaluate(context: context) * _rhs.evaluate(context: context)
	}
}

final class ASTDivision: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try _lhs.evaluate(context: context) / _rhs.evaluate(context: context)
	}
}

final class ASTModulo: ASTBinaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try _lhs.evaluate(context: context) % _rhs.evaluate(context: context)
	}
}
