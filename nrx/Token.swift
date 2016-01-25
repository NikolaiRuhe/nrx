// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation

enum Token {

	// Punctuation Tokens

	case Dot
	case Not
	case Equal
	case NotEqual
	case GreaterOrEqual
	case Greater
	case LessOrEqual
	case Less
	case Assign
	case Minus
	case Plus
	case Comma
	case Star
	case Divis
	case Modulo
	case LeftParen
	case RightParen
	case Semicolon
	case LeftBrace
	case RightBrace
	case LeftBracket
	case RightBracket
	case Questionmark
	case Colon
	case And
	case Or

	// Keyword Tokens

	case Assert
	case Break
	case Catch
	case Contains
	case Continue
	case Else
	case Error
	case Except
	case False
	case For
	case If
	case In
	case Map
	case Null
	case Print
	case Return
	case True
	case Try
	case Where
	case While

	// Tokens with associated data

	case Identifier    (UnsafeUTF8String)
	case Int           (UnsafeUTF8String)
	case Float         (UnsafeUTF8String)
	case String        (UnsafeUTF8String)
	case EscapedString (Swift.String)
	case Lookup        (UnsafeUTF8String)
	case MultiLookup   (UnsafeUTF8String)

	// Special Tokens

	case LexerError    (Swift.String)
	case AtEnd
}


extension Token {
	var testNotation: Swift.String {
		switch self {
		case let .Identifier    (value):  return "Ident(\(value))"
		case let .Int           (value):  return "Int(\(value))"
		case let .Float         (value):  return "Float(\(value))"
		case let .String        (value):  return "String(\(value))"
		case let .EscapedString (value):  return "String(\(value))"
		case let .Lookup        (value):  return "Lookup(\(value))"
		case let .MultiLookup   (value):  return "MultiLookup(\(value))"
		case     .LexerError:             return "LEXER_ERROR"
		default:                          return "\(self)"
		}
	}
}


/// The `UnsafeUTF8String` is basically a string which references characters from a foreign buffer.
///
/// As it maintains no ownership over the referenced buffer one has to take precautions that the
/// external buffer lives longer than any `UnsafeUTF8String` instances.
internal struct UnsafeUTF8String {
	let bufferPointer: UnsafeBufferPointer<UTF8Fragment>

	init(start: UnsafePointer<UTF8Fragment>, count: Int) {
		bufferPointer = UnsafeBufferPointer(start: start, count: count)
	}
}


extension UnsafeUTF8String : CustomStringConvertible {
	var description: String {
		var result = ""
		if transcode(UTF8.self, UTF32.self, bufferPointer.generate(), { result.append(UnicodeScalar($0)) }, stopOnError: true) {
			return "decoding error " + bufferPointer.debugDescription
		}
		return result
	}
}

extension UnsafeUTF8String : Equatable {
}

func ==(lhs: UnsafeUTF8String, rhs: UnsafeUTF8String) -> Bool {
	let count = lhs.bufferPointer.count
	guard count == rhs.bufferPointer.count else {
		return false
	}

	return memcmp(lhs.bufferPointer.baseAddress, rhs.bufferPointer.baseAddress, count) == 0
}

func ==(lhs: UnsafeUTF8String, rhs: StaticString) -> Bool {
	precondition(rhs.hasPointerRepresentation)

	let count = lhs.bufferPointer.count
	guard count == rhs.byteSize else {
		return false
	}

	return memcmp(lhs.bufferPointer.baseAddress, rhs.utf8Start, count) == 0
}

extension UnsafeUTF8String {
	var keywordToken: Token? {
		// switch over first character, check for keywords, return nil otherwise
		switch self.bufferPointer[0] {
		case  78: return self == "NULL"   ? .Null                                                                     : nil
		case  97: return self == "and"    ? .And    : self == "assert" ? .Assert                                      : nil
		case  98: return self == "break"  ? .Break                                                                    : nil
		case  99: return self == "catch"  ? .Catch  : self == "contains" ? .Contains : self == "continue" ? .Continue : nil
		case 101: return self == "else"   ? .Else   : self == "error" ? .Error       : self == "except"   ? .Except   : nil
		case 102: return self == "false"  ? .False  : self == "for" ? .For                                            : nil
		case 105: return self == "if"     ? .If     : self == "in" ? .In                                              : nil
		case 109: return self == "map"    ? .Map                                                                      : nil
		case 111: return self == "or"     ? .Or                                                                       : nil
		case 112: return self == "print"  ? .Print                                                                    : nil
		case 114: return self == "return" ? .Return                                                                   : nil
		case 116: return self == "true"   ? .True   : self == "try" ? .Try                                            : nil
		case 119: return self == "where"  ? .Where  : self == "while" ? .While                                        : nil
		default:  return                                                                                                nil
		}
	}
}
