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
	case Lookup        (UnsafeUTF8String)
	case MultiLookup   (UnsafeUTF8String)

	// Special Tokens

	case LexerError    (Swift.String)
	case AtEnd
}


extension Token: Equatable {
}

@warn_unused_result func ==(lhs: Token, rhs: Token) -> Bool {
	switch lhs {
	case .Dot:            if case .Dot            = rhs { return true } else { return false }
	case .Not:            if case .Not            = rhs { return true } else { return false }
	case .Equal:          if case .Equal          = rhs { return true } else { return false }
	case .NotEqual:       if case .NotEqual       = rhs { return true } else { return false }
	case .GreaterOrEqual: if case .GreaterOrEqual = rhs { return true } else { return false }
	case .Greater:        if case .Greater        = rhs { return true } else { return false }
	case .LessOrEqual:    if case .LessOrEqual    = rhs { return true } else { return false }
	case .Less:           if case .Less           = rhs { return true } else { return false }
	case .Assign:         if case .Assign         = rhs { return true } else { return false }
	case .Minus:          if case .Minus          = rhs { return true } else { return false }
	case .Plus:           if case .Plus           = rhs { return true } else { return false }
	case .Comma:          if case .Comma          = rhs { return true } else { return false }
	case .Star:           if case .Star           = rhs { return true } else { return false }
	case .Divis:          if case .Divis          = rhs { return true } else { return false }
	case .Modulo:         if case .Modulo         = rhs { return true } else { return false }
	case .LeftParen:      if case .LeftParen      = rhs { return true } else { return false }
	case .RightParen:     if case .RightParen     = rhs { return true } else { return false }
	case .Semicolon:      if case .Semicolon      = rhs { return true } else { return false }
	case .LeftBrace:      if case .LeftBrace      = rhs { return true } else { return false }
	case .RightBrace:     if case .RightBrace     = rhs { return true } else { return false }
	case .LeftBracket:    if case .LeftBracket    = rhs { return true } else { return false }
	case .RightBracket:   if case .RightBracket   = rhs { return true } else { return false }
	case .Questionmark:   if case .Questionmark   = rhs { return true } else { return false }
	case .Colon:          if case .Colon          = rhs { return true } else { return false }
	case .And:            if case .And            = rhs { return true } else { return false }
	case .Or:             if case .Or             = rhs { return true } else { return false }
	case .Assert:         if case .Assert         = rhs { return true } else { return false }
	case .Break:          if case .Break          = rhs { return true } else { return false }
	case .Catch:          if case .Catch          = rhs { return true } else { return false }
	case .Contains:       if case .Contains       = rhs { return true } else { return false }
	case .Continue:       if case .Continue       = rhs { return true } else { return false }
	case .Else:           if case .Else           = rhs { return true } else { return false }
	case .Error:          if case .Error          = rhs { return true } else { return false }
	case .Except:         if case .Except         = rhs { return true } else { return false }
	case .False:          if case .False          = rhs { return true } else { return false }
	case .For:            if case .For            = rhs { return true } else { return false }
	case .If:             if case .If             = rhs { return true } else { return false }
	case .In:             if case .In             = rhs { return true } else { return false }
	case .Map:            if case .Map            = rhs { return true } else { return false }
	case .Null:           if case .Null           = rhs { return true } else { return false }
	case .Print:          if case .Print          = rhs { return true } else { return false }
	case .Return:         if case .Return         = rhs { return true } else { return false }
	case .True:           if case .True           = rhs { return true } else { return false }
	case .Try:            if case .Try            = rhs { return true } else { return false }
	case .Where:          if case .Where          = rhs { return true } else { return false }
	case .While:          if case .While          = rhs { return true } else { return false }

	case .Identifier(let value):  if case .Identifier(let rhsValue)  = rhs where value == rhsValue { return true } else { return false }
	case .Int(let value):         if case .Int(let rhsValue)         = rhs where value == rhsValue { return true } else { return false }
	case .Float(let value):       if case .Float(let rhsValue)       = rhs where value == rhsValue { return true } else { return false }
	case .String(let value):      if case .String(let rhsValue)      = rhs where value == rhsValue { return true } else { return false }
	case .Lookup(let value):      if case .Lookup(let rhsValue)      = rhs where value == rhsValue { return true } else { return false }
	case .MultiLookup(let value): if case .MultiLookup(let rhsValue) = rhs where value == rhsValue { return true } else { return false }
	case .LexerError(let value):  if case .LexerError(let rhsValue)  = rhs where value == rhsValue { return true } else { return false }

	case .AtEnd:          if case .AtEnd          = rhs { return true } else { return false }
	}
}

/// The `UnsafeUTF8String` is basically a string which references characters from a foreign buffer.
///
/// As it maintains no ownership over the referenced buffer one has to take precautions that the
/// external buffer lives longer than any `UnsafeUTF8String` instances.
/// As a special case it can store a strong reference to a buffer if needed. This is used when the
/// Lexer has to actually transform the input and can't use the original buffer's contents.
internal struct UnsafeUTF8String {
	let buffer: [UTF8Fragment]?
	let isASCII: Bool
	let bufferPointer: UnsafeBufferPointer<UTF8Fragment>

	init(start: UnsafePointer<UTF8Fragment>, count: Int, isASCII: Bool) {
		buffer = nil
		self.isASCII = isASCII
		bufferPointer = UnsafeBufferPointer(start: start, count: count)
	}
	init(buffer: [UTF8Fragment], isASCII: Bool) {
		self.buffer = buffer
		self.isASCII = isASCII
		bufferPointer = UnsafeBufferPointer(start: buffer, count: buffer.count)
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
