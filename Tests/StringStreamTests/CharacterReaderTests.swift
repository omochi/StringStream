import XCTest
import StringStream

final class CharacterReaderTests: XCTestCase {
    func test1() throws {
        try test(string: "Cafe\u{301}")
        try test(string: "Café")
        try test(string: "Cafe\u{301} du 🌍")
        try test(string: "🇵🇷")
    }
    
    private func test(string: String, file: StaticString = #file, line: UInt = #line) throws {
        let expected: [Character] = string.map { $0 }
        
        let data = string.data(using: .utf8)!
        let reader = try CharacterReader(handle: MemoryFileHandle(data: data))
        let actual = try reader.readAll()
        XCTAssertEqual(actual, expected, file: file, line: line)
    }
}

extension CharacterReader {
    fileprivate func readAll() throws -> [Character] {
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

