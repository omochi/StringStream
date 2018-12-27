import Foundation

public class LTSVWriter {
    public init(handle: FileHandleProtocol) {
        self.handle = handle
    }
    
    private let handle: FileHandleProtocol
    
    public func write(row: LTSV.Row) throws {
        let line = row.cells.map { (cell) in
            cell.label + ":" + cell.value
        }.joined(separator: "\t") + "\n"
        
        let data = line.data(using: .utf8)!
        try handle.write(data: data)
    }
}

extension LTSVWriter {
    public convenience init(path: URL) throws {
        try self.init(handle: FileHandle(path: path, mode: "w"))
    }

    public func writeAll(rows: [LTSV.Row]) throws {
        for row in rows {
            try write(row: row)
        }
    }
}
