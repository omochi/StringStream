import Foundation

public protocol FileHandleProtocol {
    var isEOF: Bool { get }
    func read(maxSize: Int) throws -> Data
    func write(data: Data) throws
    func position() throws -> Int
    func seek(to position: Int) throws
}
