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

	case Identifier    (Swift.String)
	case Int           (Swift.String)
	case Float         (Swift.String)
	case String        (Swift.String)
	case Lookup        (Swift.String)
	case MultiLookup   (Swift.String)

	// Special Tokens

	case LexerError    (Swift.String)
	case AtEnd
}

extension Token {
	var testNotation: Swift.String {
		switch self {
		case let .Identifier (name):   return "Ident(\(name))"
		case let .Int        (value):  return "Int(\(value))"
		case let .Float      (value):  return "Float(\(value))"
		case let .String     (value):  return "String(\(value))"
		case let .Lookup     (name):   return "Lookup(\(name))"
		case let .MultiLookup(name):   return "MultiLookup(\(name))"
		case     .LexerError:          return "LEXER_ERROR"
		default:                       return "\(self)"
		}
	}
}

