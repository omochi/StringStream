import Foundation

public struct PosixError : Error, CustomStringConvertible {
    public var code: Int32
    
    public init(code: Int32) {
        self.code = code
    }
    
    public var description: String {
        let str = String(cString: strerror(code), encoding: .utf8) ?? ""
        return "\(str)(\(code))"
    }
    
    public static var current: PosixError {
        return PosixError(code: Darwin.errno)
    }
}
