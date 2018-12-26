import XCTest
import StringStream

class CSVReaderTests: XCTestCase {

    func test1() throws {
        let csv = """
🌍,🇵🇷,"hello
world",
"😀",,"",🧒🏼👩🏾‍🦱
"""
                
        let expected: [CSVReader.Row] = [
            CSVReader.Row(columns: ["🌍", "🇵🇷", "hello\nworld", ""]),
            CSVReader.Row(columns: ["😀", "", "", "🧒🏼👩🏾‍🦱"])
        ]
        
        let data = csv.data(using: .utf8)!
        let reader = try CSVReader(handle: MemoryFileHandle(data: data))
        let actual = try reader.readAll()
        
        XCTAssertEqual(actual, expected)
    }
    
    func testCRLF() throws {
        let csv = "a,b\r\nc,d"
        
        let expected: [CSVReader.Row] = [
            CSVReader.Row(columns: ["a", "b"]),
            CSVReader.Row(columns: ["c", "d"]),
        ]
        
        let data = csv.data(using: .utf8)!
        let reader = try CSVReader(handle: MemoryFileHandle(data: data))
        let actual = try reader.readAll()
        
        XCTAssertEqual(actual, expected)
    }

}
