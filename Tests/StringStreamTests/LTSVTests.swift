import XCTest
import StringStream

class LTSVTests: XCTestCase {
    func test1() throws {
        let rows: [LTSV.Row] = [
            LTSV.Row(cells: [
                LTSV.Cell(label: "t", value: "2018-12-27 14:54:16"),
                LTSV.Cell(label: "d", value: "hello world")]),
            LTSV.Row(cells: [
                LTSV.Cell(label: "t", value: "2018-12-27 14:55:03"),
                LTSV.Cell(label: "d", value: "byebyte")])
        ]
        
        let handle = MemoryFileHandle(data: Data())
        let writer = LTSVWriter(handle: handle)
        try writer.writeAll(rows: rows)
        try handle.seek(to: 0)
        let reader = LTSVReader(reader: try CharacterReader(handle: handle))
        let actual: [LTSV.Row] = try reader.readAll()
        XCTAssertEqual(rows, actual)
    }

}
