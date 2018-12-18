import Foundation

public extension UTF8 {
    public enum ByteKind {
        case head(length: Int8)
        case body
        case invalid
        
        public init(byte: UInt8) {
            if byte & 0b1000_0000 == 0b0000_0000 {
                self = .head(length: 1)
            } else if byte & 0b1100_0000 == 0b1000_0000 {
                self = .body
            } else if byte & 0b1110_0000 == 0b1100_0000 {
                self = .head(length: 2)
            } else if byte & 0b1111_0000 == 0b1110_0000 {
                self = .head(length: 3)
            } else if byte & 0b1111_1000 == 0b1111_0000 {
                self = .head(length: 4)
            } else {
                self = .invalid
            }
        }
    }
}
