// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


final class ASTArithmeticNegation: ASTUnaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try -(_operand.evaluate(context: context))
	}
}

final class ASTLogicalNegation: ASTUnaryOperator {
	override func evaluate(context context: EvaluationContext) throws -> Value {
		return try !(_operand.evaluate(context: context))
	}
}
