// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation


/// The `Value` type implements all built-in or bridged types and their values.
enum Value {
	case Null
	case Bool(Swift.Bool)
	case Number(Float64)
	case Date(Float64)
	case String(StringValue)
	case List(Array<Value>)
	case Dictionary(Swift.Dictionary<Swift.String, Value>)
	case Object(Bridgeable)

	class StringValue {
		let value: Swift.String
		init(_ value: Swift.String) {
			self.value = value
		}
	}
}


/// The type uesed for all runtime exceptions.
enum EvaluationError : ErrorType {
	case Exception(reason: String)
}


/// To use an application defined object as a value, it must conform to the `Bridgeable`
/// protocol.
protocol Bridgeable: class {
	var nrx_typeString: String { get }
	static var nrx_typeString: String { get }
	func nrx_isEqual(other: Bridgeable) -> Bool
	var nrx_debugDescription: String { get }
}


extension Value {

	init(_ bool: Swift.Bool) {
		self = Value.Bool(bool)
	}

	func boolValue() throws -> Swift.Bool {
		switch self {
		case .Bool(let boolValue): return boolValue
		case .Null:                return false
		default:                   throw EvaluationError.Exception(reason: "Bool type expected")
		}
	}

	init(_ number: Float64) {
		self = Value.Number(number)
	}

	func numberValue() throws -> Float64 {
		if case .Number(let numberValue) = self {
			return numberValue
		}
		throw EvaluationError.Exception(reason: "Number type expected")
	}

	init(_ string: Swift.String) {
		self = Value.String(StringValue(string))
	}

	func stringValue() throws -> Swift.String {
		if case .String(let stringValue) = self {
			return stringValue.value
		}
		throw EvaluationError.Exception(reason: "String type expected")
	}
}

extension Value {
	func sequence() throws -> AnySequence<Value> {
		switch self {

		case let .List(list):
			return AnySequence(list)

		case let .Dictionary(dictionary):
			let keys = dictionary.keys.map { Value($0) }
			return AnySequence(keys)

		default:
			throw EvaluationError.Exception(reason: "type does not support iteration")
		}
	}
}


extension Value : Equatable {}

@warn_unused_result func ==(lhs: Value, rhs: Value) -> Bool {
	switch lhs {

	case .Null:
		guard case .Null = rhs else { return false }
		return true

	case let .Bool(left):
		guard case .Bool(let right) = rhs else { return false }
		return left == right

	case let .Number(left):
		guard case .Number(let right) = rhs else { return false }
		return left == right

	case let .Date(left):
		guard case .Number(let right) = rhs else { return false }
		return left == right

	case let .String(left):
		guard case .String(let right) = rhs else { return false }
		return left.value == right.value

	case let .List(left):
		guard case .List(let right) = rhs else { return false }
		return left == right

	case let .Dictionary(left):
		guard case .Dictionary(let right) = rhs else { return false }
		return left == right

	case let .Object(left):
		guard case .Object(let right) = rhs else { return false }
		return left.nrx_isEqual(right)
	}
}


extension Value {
	enum ComparisonResult: Int {
		case OrderedAscending = -1
		case OrderedSame = 0
		case OrderedDescending = 1
		case Unrelated = 2
	}

	func compare(rhs: Value) throws -> ComparisonResult {
		switch (self, rhs) {

		case let (.Number(left), .Number(right)):
			return left < right ? .OrderedAscending : left == right ? .OrderedSame : .OrderedDescending

		case let (.Date(left), .Date(right)):
			return left < right ? .OrderedAscending : left == right ? .OrderedSame : .OrderedDescending

		case let (.String(left), .String(right)):
			return left.value < right.value ? .OrderedAscending : left.value == right.value ? .OrderedSame : .OrderedDescending

		default:
			throw EvaluationError.Exception(reason: "types do not support comparison")
		}
	}
}


@warn_unused_result prefix func -(operand: Value) throws -> Value {
	return Value(-(try operand.numberValue()))
}

@warn_unused_result prefix func !(operand: Value) throws -> Value {
	return Value(!(try operand.boolValue()))
}

@warn_unused_result func +(lhs: Value, rhs: Value) throws -> Value {
	switch lhs {
	case .Number(let number):
		return Value(try number + rhs.numberValue())
	case .String(let string):
		return Value(try string.value + rhs.stringValue())
	default:
		throw EvaluationError.Exception(reason: "type does not support + operator")
	}
}

@warn_unused_result func -(lhs: Value, rhs: Value) throws -> Value {
	guard case .Number(let number) = lhs else {
		throw EvaluationError.Exception(reason: "type does not support - operator")
	}
	return Value(try number - rhs.numberValue())
}

@warn_unused_result func *(lhs: Value, rhs: Value) throws -> Value {
	guard case .Number(let number) = lhs else {
		throw EvaluationError.Exception(reason: "type does not support * operator")
	}
	return Value(try number * rhs.numberValue())
}

@warn_unused_result func /(lhs: Value, rhs: Value) throws -> Value {
	guard case .Number(let number) = lhs else {
		throw EvaluationError.Exception(reason: "type does not support / operator")
	}
	let divisor = try rhs.numberValue()
	if divisor == 0 {
		throw EvaluationError.Exception(reason: "division by zero")
	}
	return Value(number / divisor)
}

@warn_unused_result func %(lhs: Value, rhs: Value) throws -> Value {
	guard case .Number(let number) = lhs else {
		throw EvaluationError.Exception(reason: "type does not support % operator")
	}
	let divisor = try rhs.numberValue()
	if divisor == 0 {
		throw EvaluationError.Exception(reason: "modulo by zero")
	}
	return Value(number % divisor)
}
