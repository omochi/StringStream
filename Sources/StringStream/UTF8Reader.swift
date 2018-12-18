import Foundation

public class UTF8Reader {
    public init(handle: FileHandleProtocol) throws {
        self.handle = handle
        let position = try handle.position()
        self.buffer = Buffer(start: position, position: 0, data: Data())
    }
    
    private let handle: FileHandleProtocol
    
    public var position: Int {
        return buffer.start + buffer.position
    }
    
    private struct Buffer {
        public var start: Int
        public var end: Int { return start + data.count }
        public var position: Int
        public var data: Data
    }
    
    private var buffer: Buffer
    
    public enum Element : Equatable {
        case scalar(Unicode.Scalar)
        case end
        case invalid
        
        public static func ==(a: Element, b: Element) -> Bool {
            switch a {
            case .scalar(let a):
                if case .scalar(let b) = b { return a == b }
            case .end:
                if case .end = b { return true }
            case .invalid:
                if case .invalid = b { return true }
            }
            return false
        }
    }
    
    public func read() throws -> Element {
        guard let headByte = try readByte() else {
            return .end
        }
        
        switch UTF8.ByteKind(byte: headByte) {
        case .head(length: let length):
            switch length {
            case 1:
                return .scalar(Unicode.Scalar(headByte))
            case 2, 3, 4:
                var value: UInt32 = UInt32((headByte << length) >> length)
                for _ in 0..<(length - 1) {
                    let pos = self.position
                    guard let bodyByte = try readByte() else {
                        return .invalid
                    }
                    switch UTF8.ByteKind(byte: bodyByte) {
                    case .head:
                        try seek(to: pos)
                        return .invalid
                    case .body:
                        value = (value << 6) + UInt32(bodyByte & 0b0011_1111)
                    case .invalid:
                        return .invalid
                    }
                }
                guard let scalar = Unicode.Scalar(value) else {
                    return .invalid
                }
                return .scalar(scalar)
            default:
                return .invalid
            }
        case .body, .invalid:
            return .invalid
        }
    }
    
    public func seek(to position: Int) throws {
        if buffer.start <= position && position < buffer.end {
            buffer.position = position - buffer.start
            return
        }
        
        buffer = Buffer(start: position, position: 0, data: Data())
        try handle.seek(to: position)
    }
    
    private func readByte() throws -> UInt8? {
        if buffer.position == buffer.data.count {
            let position = try handle.position()
            let data = try handle.read(maxSize: 1024)
            self.buffer = Buffer(start: position,
                                 position: 0,
                                 data: data)
            if buffer.data.count == 0 {
                return nil
            }
        }
        
        let byte = buffer.data[buffer.position]
        buffer.position += 1
        return byte
    }
}
