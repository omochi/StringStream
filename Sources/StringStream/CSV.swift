import Foundation

public enum CSV {
    public struct Row : Equatable {
        public var columns: [String]
        
        public init(columns: [String]) {
            self.columns = columns
        }
    }
}
