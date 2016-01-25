// nrx - https://github.com/NikolaiRuhe/nrx
// copyright 2016, Nikolai Ruhe

import Foundation

/// The `Lexer` applies a simple state machine to transforms a stream of characters
/// into a stream of `Token`s.
///
/// The characters it uses for input are UTF8 code fragments (or "code units"), while
/// all token calculations are done on codes 0-127 (pure ASCII). The only case
/// where high-bit codes are allowed is in string literals, where they are just passed
/// through.
internal struct Lexer {

	private var current: UnsafePointer<UTF8Fragment>
	private let end:     UnsafePointer<UTF8Fragment>
	private let buffer: [ UTF8Fragment ]

	internal init(source: String) {
		var utf8 = Array(source.utf8)
		utf8.append(0)
		self.init(zeroTerminatedUTF8FragmentBuffer: utf8)
	}
	
	internal init(zeroTerminatedUTF8FragmentBuffer buffer: [ UTF8Fragment ]) {
		precondition(buffer.last == 0)
		self.buffer  = buffer
		current = UnsafePointer(self.buffer)
		end     = current + self.buffer.count
	}

	/// Calculate the next `Token` from the input.
	///
	/// The lexer automatically skips over whitespace and comments and returns
	/// the first sematically significant token found in the input stream.
	/// If there are no more tokens, it returns the special `.AtEnd` marker token.
	/// When an error occurs, it is signalled by an `.LexerError` token.
	internal mutating func scanToken() -> Token {

		while true {
			let char = current.memory
			current += 1

			// switch over the first character of a token
			switch char {

			case   0: /* nul */   return _scanNul()
			case   9: /* tab */   continue
			case  10: /* nl */    continue
			case  13: /* cr */    continue
			case  32: /* space */ continue
			case  33: /* ! */     return _switchNextChar(61, token: .NotEqual, otherwise: .Not)
			case  34: /* " */     return _scanQuotedString(quoteChar: char)
			case  36: /* $ */     return _scanLookup()
			case  37: /* % */     return .Modulo
			case  38: /* & */     return _switchNextChar(38, token: .And, otherwise: .LexerError("unexpected character"))
			case  39: /* ' */     return _scanQuotedString(quoteChar: char)
			case  40: /* ( */     return .LeftParen
			case  41: /* ) */     return .RightParen
			case  42: /* * */     return .Star
			case  43: /* + */     return .Plus
			case  44: /* , */     return .Comma
			case  45: /* - */     return .Minus
			case  46: /* . */     return current.memory.isDigit ? _scanFloat(start: current - 1) : Token.Dot
			case  47: /* / */     if let token = _scanDivis() { return token } else { continue }
			case  48, 49, 50, 51, 52, 53, 54, 55, 56, 57:
				      /* 0-9 */   return _scanNumber()
			case  58: /* : */     return _switchNextChar(61, token: .Assign, otherwise: .Colon)
			case  59: /* ; */     return .Semicolon
			case  60: /* < */     return _switchNextChar(61, token: .LessOrEqual, otherwise: .Less)
			case  61: /* = */     return _switchNextChar(61, token: .Equal, otherwise: .Equal)
			case  62: /* > */     return _switchNextChar(61, token: .GreaterOrEqual, otherwise: .Greater)
			case  63: /* ? */     return .Questionmark
			case  65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90:
					  /* A-Z */   return _scanIdentifier()
			case  91: /* [ */     return .LeftBracket
			case  93: /* ] */     return .RightBracket
			case  95: /* _ */     return _scanIdentifier()
			case  97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122:
					  /* a-z */   return _scanIdentifier()
			case 123: /* { */     return .LeftBrace
			case 124: /* | */     return _switchNextChar(124, token: .Or, otherwise: .LexerError("unexpected character"))
			case 125: /* } */     return .RightBrace
			default:              return .LexerError("unexpected character")
			}
		}
	}

}


extension Lexer {

	private mutating func _scanNul() -> Token {
		if (current == end) {
			current -= 1
			return .AtEnd
		}
		return .LexerError("unexpected nul character")
	}

	private mutating func _switchNextChar(nextChar: UTF8Fragment, token: Token, otherwise defaultToken: Token) -> Token {
		if current.memory != nextChar {
			return defaultToken
		}
		current += 1
		return token
	}

	private mutating func _scanDivis() -> Token? {
		switch current.memory {
		case 42: return _skipMultiLineComment()
		case 47: _skipSingleLineComment(); return nil
		default: return .Divis
		}
	}

	private mutating func _skipSingleLineComment() {
		current += 1 // skip over second '/'
		while true {
			let char = current.memory
			current += 1
			if char == 0 || char == 10 {
				break
			}
		}
	}

	private mutating func _skipMultiLineComment() -> Token? {
		current += 1 // skip over '*'
		while true {
			let char = current.memory
			if char == 0 {
				return .LexerError("unterminated mutliline comment")
			}
			current += 1
			if char == 42 && current.memory == 47 {
				break
			}
		}
		current += 1
		return nil
	}

	private mutating func _scanIdentifier() -> Token {
		let start = current - 1
		while true {
			let char = current.memory
			guard char.isIdentTrail else {
				break
			}
			current += 1
		}
		let end = current

		let string = UnsafeUTF8String(start: start, count: end - start)

		return string.keywordToken ?? .Identifier(string)
	}

	// Scan a integer and float numbers
	private mutating func _scanNumber() -> Token {

		current -= 1
		precondition(current.memory.isDigit)

		var start = current

		intLoop: while true {
			switch current.memory {
			case 48: // 0
				if start == current {
					start += 1
				}
				break

			case 49, 50, 51, 52, 53, 54, 55, 56, 57: // 1-9
				break

			default:
				break intLoop
			}
			current += 1
		}

		if current.memory.isIdentHead {
			return .LexerError("bad float literal")
		}

		if start == current {
			start -= 1
		}

		if current.memory == 46 {
			current += 1
			if current.memory.isDigit {
				return _scanFloat(start: start)
			}
			if current.memory.isIdentHead {
				current -= 1
				return .Int(UnsafeUTF8String(start: start, count: current - start))
			}
			return .Float(UnsafeUTF8String(start: start, count: current - start - 1))
		}

		return .Int(UnsafeUTF8String(start: start, count: current - start))
	}

	// Scan a integer and float numbers
	private mutating func _scanFloat(start start: UnsafePointer<UTF8Fragment>) -> Token {

		precondition(current.memory.isDigit)
		precondition(current[-1] == 46)

		let decimalPointPosition = current - 1

		floatLoop: while true {
			switch current.memory {
			case 48, 49, 50, 51, 52, 53, 54, 55, 56, 57: // 1-9
				current += 1
			default:
				break floatLoop
			}
		}

		if current.memory.isIdentHead {
			return .LexerError("bad float literal")
		}

		var end = current
		while end[-1] == 48 {
			end -= 1
		}

		if end - 1 != decimalPointPosition {
			return .Float(UnsafeUTF8String(start: start, count: end - start))
		}

		if start == decimalPointPosition {
			return .Float(UnsafeUTF8String(start: end, count: 1))
		}

		return .Float(UnsafeUTF8String(start: end, count: decimalPointPosition - start))
	}

	// Scan single or double quoted strings.
	private mutating func _scanQuotedString(quoteChar quoteChar: UTF8Fragment) -> Token {

		// The fast path only succeeds when there are no characters to unescape in the
		// string. Use the slow path otherwise.

		return _scanQuotedStringFastPath(quoteChar: quoteChar)
			?? _scanQuotedStringSlowPath(quoteChar: quoteChar)
	}
	
	private mutating func _scanQuotedStringFastPath(quoteChar quoteChar: UTF8Fragment) -> Token? {

		let start = current

		utf8FragmentLoop: while true {
			let char = current.memory
			current += 1
			switch char {
			case 0:
				if current != end {
					continue
				}
				return .LexerError("unterminated string literal")
			case quoteChar:
				break utf8FragmentLoop
			case 92: // Backslash
				current = start
				return nil
			default:
				continue
			}
		}

		return .String(UnsafeUTF8String(start: start, count: current - start - 1))
	}

	private mutating func _scanQuotedStringSlowPath(quoteChar quoteChar: UTF8Fragment) -> Token {
		var utf8 : [UTF8Fragment] = []

		utf8FragmentLoop: while true {
			let char = current.memory
			current += 1
			switch char {
			case 0:
				if current != end {
					utf8.append(char)
					continue
				}
				return .LexerError("unterminated string literal")
			case quoteChar:
				break utf8FragmentLoop
			case 92: // Backslash
				break
			default:
				utf8.append(char)
				continue
			}

			let nextChar = current.memory
			current += 1
			switch nextChar {
			case quoteChar, 92:
				utf8.append(nextChar)
				continue
			case 110:
				utf8.append(10)
				continue
			default:
				return .LexerError("unknown escaped character in string literal")
			}
		}

		var result = ""
		if transcode(UTF8.self, UTF32.self, utf8.generate(), { result.append(UnicodeScalar($0)) }, stopOnError: true) {
			return .LexerError("bad utf8 sequence in literal")
		}
		return .EscapedString(result)
	}

	private mutating func _scanLookup() -> Token {
		let isMulti = current.memory == 36
		if isMulti {
			current += 1
		}

		if !current.memory.isIdentHead {
			return .LexerError("bad lookup name")
		}

		let start = current
		while current.memory.isIdentTrail {
			current += 1
		}
		let string = UnsafeUTF8String(start: start, count: current - start)

		return isMulti ? Token.MultiLookup(string) : Token.Lookup(string)
	}
}

extension Lexer : GeneratorType {
	typealias Element = Token
	mutating func next() -> Token? {
		let token = self.scanToken()
		switch token {
		case .AtEnd:
			return nil
		case .LexerError:
			self.current = self.end - 1
			return token
		default:
			return token
		}
	}
}

typealias UTF8Fragment = UInt8

extension UTF8Fragment {
	var isDigit:      Bool { return (48...57).contains(self) }
	var isLetter:     Bool { return (65...90).contains(self) || (97...122).contains(self) }
	var isIdentTrail: Bool { return isDigit || isLetter || self == 95 }
	var isIdentHead:  Bool { return isLetter || self == 95 }
}
