// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


final class ASTNullLiteral: ASTLiteral {
	internal static let null: ASTNullLiteral = ASTNullLiteral()
}

final class ASTBoolLiteral: ASTLiteral {
	let _value: Bool

	init(_ value: Bool) {
		_value = value
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
}

final class ASTStringLiteral: ASTLiteral {
	let _value: String

	init(_ value: String) {
		_value = value
	}
}

final class ASTListLiteral: ASTLiteral {
	let _elements: [ASTExpression]

	init(elements: [ASTExpression]) {
		_elements = elements
	}
}

final class ASTDictLiteral: ASTLiteral {
	let _pairs: [(ASTExpression, ASTExpression)]

	init(pairs: [(ASTExpression, ASTExpression)]) {
		_pairs = pairs
	}
}
