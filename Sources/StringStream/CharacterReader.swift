import Foundation

public class CharacterReader {
    public init(handle: FileHandleProtocol) throws {
        self.reader = try UTF8Reader(handle: handle)
        self.buffer = ""
    }
    
    private let reader: UTF8Reader
    
    public var position: Int {
        return reader.position
    }
    
    private var buffer: String

    public func read() throws -> Character? {
        while true {
            if buffer.count >= 2 {
                return takeHeadChar()
            }
            
            precondition(buffer.count <= 1)
            
            let element = try reader.read()
            switch element {
            case .scalar(let scalar):
                buffer.unicodeScalars.append(scalar)
            case .end:
                if buffer.count > 0 {
                    return takeHeadChar()
                }
                
                return nil
            case .invalid:
                if buffer.count > 0 {
                    return takeHeadChar()
                }
            }
        }
    }
    
    private func takeHeadChar() -> Character {
        let startIndex = buffer.startIndex
        let char = buffer[startIndex]
        let nextIndex = buffer.index(after: startIndex)
        buffer = String(buffer[nextIndex...])
        return char
    }
    
    public func seek(to position: Int) throws {
        buffer = ""
        try reader.seek(to: position)
    }
}
