import Foundation

public class CharacterReader {
    public init(handle: FileHandleProtocol) throws {
        self.reader = try UTF8Reader(handle: handle)
        self.buffer = Buffer(start: reader.position,
                             tokens: [],
                             string: "")
    }
    
    private let reader: UTF8Reader
    
    public var position: Int {
        return buffer.start
    }
    
    private struct Token {
        public var length: Int
        public var scalar: Unicode.Scalar
    }
    
    private struct Buffer {
        public var start: Int
        public var tokens: [Token]
        public var string: String
    }
    
    private var buffer: Buffer

    public func read() throws -> Character? {
        while true {
            if buffer.string.count >= 2 {
                return takeHeadChar()
            }
            
            precondition(buffer.string.count <= 1)
            
            let pos = reader.position
            let element = try reader.read()
            switch element {
            case .scalar(let scalar):
                let length = reader.position - pos
                buffer.tokens.append(Token(length: length, scalar: scalar))
                buffer.string.unicodeScalars.append(scalar)
            case .end:
                if buffer.string.count > 0 {
                    return takeHeadChar()
                }
                
                return nil
            case .invalid:
                if buffer.string.count > 0 {
                    return takeHeadChar()
                }
            }
        }
    }
    
    private func takeHeadChar() -> Character {
        let string = buffer.string
        
        let startIndex = string.startIndex
        let char = string[startIndex]
        let nextIndex = string.index(after: startIndex)
        buffer.string = String(string[nextIndex...])
        
        let n = char.unicodeScalars.count
        for i in 0..<n {
            buffer.start += buffer.tokens[i].length
        }
        buffer.tokens.removeFirst(n)

        return char
    }
    
    public func seek(to position: Int) throws {
        buffer = Buffer(start: position,
                        tokens: [],
                        string: "")
        try reader.seek(to: position)
    }
}

extension CharacterReader {
    public convenience init(path: URL) throws {
        try self.init(handle: FileHandle(path: path, mode: "r"))
    }

    public func readAll() throws -> [Character] {
        var ret = [Character]()
        while true {
            guard let char = try self.read() else {
                break
            }
            ret.append(char)
        }
        return ret
    }
}

