import Foundation

public enum LTSV {
    public struct Row : Equatable {
        public var cells: [Cell]
        
        public init(cells: [Cell]) {
            self.cells = cells
        }
    }
    
    public struct Cell :Equatable {
        public var label: String
        public var value: String
        public init(label: String,
                    value: String)
        {
            self.label = label
            self.value = value
        }
    }
}

