import Foundation

public class LTSVReader {
    public init(reader: CharacterReader) {
        self.reader = reader
    }
    
    private let reader: CharacterReader
    
    public func read() throws -> LTSV.Row? {
        guard let line = try readLine() else {
            return nil
        }
        
        let cellStrs = line.components(separatedBy: "\t")
        
        let cells = cellStrs.map { (cell) -> LTSV.Cell in
            guard let pos0 = cell.firstIndex(of: ":") else {
                return LTSV.Cell(label: "", value: cell)
            }
            
            let pos1 = cell.index(after: pos0)
            
            return LTSV.Cell(label: String(cell[..<pos0]),
                             value: String(cell[pos1...]))
        }
        
        return LTSV.Row(cells: cells)
    }
    
    private func readLine() throws -> String? {
        var line = String()
        guard let char0 = try reader.read() else {
            return nil
        }
        line.append(char0)
        
        while true {
            guard let char1 = try reader.read() else {
                break
            }
            
            if char1 == Character("\n") ||
                char1 == Character("\r") ||
                char1 == Character("\r\n")
            {
                break
            }
            
            line.append(char1)
        }
        
        return line
    }
}

extension LTSVReader {
    public func readAll() throws -> [LTSV.Row] {
        var ret = [LTSV.Row]()
        while true {
            guard let row = try read() else {
                break
            }
            ret.append(row)
        }
        return ret
    }
}
