// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


final class ASTArithmeticNegation: ASTUnaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try -(_operand.evaluate(runtime: runtime))
	}
}

final class ASTLogicalNegation: ASTUnaryOperator {
	override func evaluate(runtime runtime: Runtime) throws -> Value {
		return try !(_operand.evaluate(runtime: runtime))
	}
}
