import Foundation

public class MemoryFileHandle : FileHandleProtocol {
    public enum Error : Swift.Error {
        case overflow
        case outOfBounds
    }
    
    public var isEOF: Bool {
        return _position == data.count
    }
    
    public func read(maxSize: Int) -> Data {
        let rem = data.count - _position
        let size = min(rem, maxSize)
        let chunk = data[_position..<(_position + size)]
        _position += size
        return chunk
    }
    
    public func write(data chunk: Data) throws {
        let rem = data.count - _position
        guard chunk.count <= rem else {
            throw Error.overflow
        }
        let size = chunk.count
        data[_position..<(_position + size)] = chunk
        _position += size
    }
    
    public func position() -> Int {
        return _position
    }
    
    public func seek(to position: Int) throws {
        guard 0 <= position && position < data.count else {
            throw Error.outOfBounds
        }
        self._position = position
    }
    
    public init(data: Data) {
        self.data = data
        self._position = 0
    }
    
    public var data: Data
    public var _position: Int
    
    
}
