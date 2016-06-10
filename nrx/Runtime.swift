// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


/// The Runtime protocol represents the current state during evaluation.
/// It holds values like variables or globals, serves as a proxy for application specific
/// functionality like lookup and is the delegate for error reporting.
protocol Runtime: class {}


/// The type uesed for all runtime exceptions.
enum EvaluationError : ErrorType {
	case Exception(reason: String)
}


/// To use an application defined object as a value, it must conform to the `Bridgeable`
/// protocol.
protocol Bridgeable: class {
	var nrx_typeString: String { get }
	func nrx_isEqual(other: Bridgeable) -> Bool
	var nrx_debugDescription: String { get }
}
