import XCTest
import StringStream

final class UTF8ReaderTests: XCTestCase {
    func test1() throws {
        try test(string: "Cafe\u{301}")
        try test(string: "Café")
        try test(string: "Cafe\u{301} du 🌍")
        try test(string: "🇵🇷")
    }
    
    private func test(string: String, file: StaticString = #file, line: UInt = #line) throws {
        let expected: [UTF8Reader.Element] =
            string.unicodeScalars.map { .scalar($0) } + [.end]
        
        let data = string.data(using: .utf8)!
        let reader = try UTF8Reader(handle: MemoryFileHandle(data: data))
        let actual = try reader.readAll()
        XCTAssertEqual(actual, expected, file: file, line: line)
    }
}

extension UTF8Reader {
    fileprivate func readAll() throws -> [UTF8Reader.Element] {
        var ret = [UTF8Reader.Element]()
        while true {
            let elem = try self.read()
            ret.append(elem)
            if case .end = elem {
                break
            }
        }
        return ret
    }
}

