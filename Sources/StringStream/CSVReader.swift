import Foundation

public class CSVReader {
    public enum Error : Swift.Error {
        case unexceptedEnd
        case unexceptedToken
        case unclosedQuotedText
    }
    
    public init(handle: FileHandleProtocol) throws {
        self.handle = handle
        self.reader = try CharacterReader(handle: handle)
    }
    
    private let handle: FileHandleProtocol
    private let reader: CharacterReader
    
    public struct Row : Equatable {
        public var columns: [String]
        
        public init(columns: [String]) {
            self.columns = columns
        }
    }
    
    public func readRow() throws -> Row? {
        let pos0 = reader.position
        let token0 = try readToken()
    
        var columns: [String] = []
        
        switch token0 {
        case .end: return nil
        case .newLine:
            return Row(columns: columns)
        default:
            try reader.seek(to: pos0)
            let column = try readColumn()
            columns.append(column)
        }
        
        while true {
            let token = try readToken()
            switch token {
            case .end, .newLine:
                return Row(columns: columns)
            case .comma:
                break
            default:
                throw Error.unexceptedToken
            }
            
            let column = try readColumn()
            columns.append(column)
        }
    }
    
    public func readAll() throws -> [Row] {
        var rows = [Row]()
        while true {
            guard let row = try readRow() else {
                return rows
            }
            rows.append(row)
        }
    }
    
    private func readColumn() throws -> String {
        let pos = reader.position
        let token = try readToken()
        switch token {
        case .end:
            throw Error.unexceptedEnd
        case .comma, .newLine:
            try reader.seek(to: pos)
            return ""
        case .doubleQuote:
            try reader.seek(to: pos)
            let text = try readQuotedText()
            while true {
                let pos2 = reader.position
                let token2 = try readToken()
                switch token2 {
                case .end, .comma, .newLine:
                    try reader.seek(to: pos2)
                    return text
                default:
                    break
                }
            }
        case .character:
            try reader.seek(to: pos)
            return try readText()
        }
    }
    
    private func readQuotedText() throws -> String {
        let q1 = try readToken()
        guard case .doubleQuote = q1 else {
            throw Error.unexceptedToken
        }
        
        var text = ""
        while true {
            let token = try readToken()
            switch token {
            case .end:
                throw Error.unclosedQuotedText
            case .character(let c):
                text.append(c)
            case .comma, .newLine:
                text.append(token.description)
            case .doubleQuote:
                let pos2 = reader.position
                let token2 = try readToken()
                switch token2 {
                case .doubleQuote:
                    text.append(token.description)
                default:
                    try reader.seek(to: pos2)
                    return text
                }
            }
        }
    }
    
    private func readText() throws -> String {
        var text = ""
        while true {
            let pos = reader.position
            let token = try readToken()
            switch token {
            case .end, .comma, .newLine:
                try reader.seek(to: pos)
                return text
            case .doubleQuote:
                text.append(token.description)
            case .character(let c):
                text.append(c)
            }
        }
    }
    
    private enum Token : CustomStringConvertible {
        case end
        case doubleQuote
        case comma
        case newLine(String)
        case character(Character)
        
        public var description: String {
            switch self {
            case .end: return ""
            case .doubleQuote: return "\""
            case .comma: return ","
            case .newLine(let s): return s
            case .character(let c): return String(c)
            }
        }
    }
    
    private func readToken() throws -> Token {
        guard let char = try reader.read() else {
            return .end
        }
        
        switch char {
        case Character("\""):
            return .doubleQuote
        case Character(","):
            return .comma
        case Character("\r\n"):
            return .newLine(String(char))
        case Character("\n"):
            return .newLine(String(char))
        case Character("\r"):
            return .newLine(String(char))
        default:
            return .character(char)
        }
    }
}
