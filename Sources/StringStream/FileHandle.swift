import Foundation

public class FileHandle : FileHandleProtocol {
    public enum Closer {
        case close
        case none
    }
    
    public convenience init(path: URL, mode: String) throws {
        guard let handle = Darwin.fopen(path.path, mode) else {
            throw PosixError.current
        }
        self.init(handle: handle, closer: .close)
    }
    
    public init(handle: UnsafeMutablePointer<FILE>,
                closer: Closer)
    {
        self.handle = handle
        self.closer = closer
    }
    
    public let handle: UnsafeMutablePointer<FILE>
    public let closer: Closer
    
    deinit {
        switch closer {
        case .close:
            do {
                try close()
            } catch {
                print("FileHandle.close() failed")
            }
        case .none: break
        }
    }
    
    public func close() throws {
        guard Darwin.fclose(handle) == 0 else {
            throw PosixError.current
        }
    }
    
    public var isEOF: Bool {
        return Darwin.feof(handle) != 0
    }
    
    public func read(maxSize: Int) throws -> Data {
        var data = Data(count: maxSize)
        let readSize = data.withUnsafeMutableBytes { (bytes) in
            Darwin.fread(bytes, 1, maxSize, handle)
        }
        if readSize < maxSize, !isEOF {
            throw PosixError(code: Darwin.ferror(handle))
        }
        data.count = readSize
        return data
    }
    
    public func write(data: Data) throws {
        let writtenSize = data.withUnsafeBytes { (bytes) in
            Darwin.fwrite(bytes, 1, data.count, handle)
        }
        if writtenSize != data.count {
            throw PosixError(code: Darwin.ferror(handle))
        }
    }
    
    public func position() throws -> Int {
        let position = Darwin.ftell(handle)
        if position == -1 {
            throw PosixError.current
        }
        return position
    }

    public func seek(to position: Int) throws {
        let status = Darwin.fseek(handle, position, SEEK_SET)
        guard status == 0 else {
            throw PosixError.current
        }
    }
}


