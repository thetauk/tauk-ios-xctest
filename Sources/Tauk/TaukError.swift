import Foundation
import XCTest

struct CodeLine: Codable {
    var lineNumber: Int
    var lineCode: String
    
    init(_ lineNumber: Int, _ lineCode: String) {
        self.lineNumber = lineNumber
        self.lineCode = lineCode
    }
    
    enum CodingKeys: String, CodingKey {
        case lineNumber = "line_number"
        case lineCode = "line_code"
    }
}

struct TaukError: Codable {
    var type: String?
    var message: String
    var lineNumber: Int?
    var invokedFunction: String
    var codeExecuted: String?
    var codeContext: [CodeLine]?
    
    init(issue: XCTIssue, testMethodName: String) {
        self.message = issue.compactDescription
        self.lineNumber = issue.sourceCodeContext.location?.lineNumber
        self.invokedFunction = testMethodName
        self.type = getIssueType(issue: issue)
        self.codeContext = getCodeContext(issue: issue)
        
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "error_type"
        case message = "error_msg"
        case lineNumber = "line_number"
        case invokedFunction = "invoked_func"
        case codeExecuted = "code_executed"
    }
    
    func getIssueType(issue: XCTIssue) -> String {
        switch issue.type {
        case .assertionFailure: return "Assertion Failure"
        case .performanceRegression: return "Performance Regression"
        case .system: return "Internal Failure"
        case .thrownError: return "Error Thrown"
        case .uncaughtException: return "Uncaught Exception"
        case .unmatchedExpectedFailure: return "Unmatched Expected Failure"
        @unknown default:
            return "Issue"
        }
    }
    
    // Will mutate the struct to set the codeExecuted String before returning
    mutating func getCodeContext(issue: XCTIssue) -> [CodeLine]? {
        guard let sourceCodeFilePath = issue.sourceCodeContext.location?.fileURL, let issueLineNumber = issue.sourceCodeContext.location?.lineNumber else {
            return nil
        }
        
        var linesBeforeError: [CodeLine] = []
        var lineAtError: CodeLine?
        var linesAfterError: [CodeLine] = []
        
        let fileReader = StreamingFileReader(path: sourceCodeFilePath)
        var currentLineNumber = 1
        while let line = fileReader.readLine() {
            if currentLineNumber != issueLineNumber && lineAtError == nil {
                if linesBeforeError.count == 9 {
                    linesBeforeError.removeFirst(4)
                    linesBeforeError.append(CodeLine(currentLineNumber, line))
                } else {
                    linesBeforeError.append(CodeLine(currentLineNumber, line))
                }
            }
            
            if currentLineNumber == issueLineNumber {
                self.codeExecuted = line
                lineAtError = CodeLine(currentLineNumber, line)
            }
            
            if lineAtError != nil && currentLineNumber != issueLineNumber && linesAfterError.count < 10 {
                linesAfterError.append(CodeLine(currentLineNumber, line))
            }
            
            currentLineNumber += 1
        }
        
        guard let lineAtError = lineAtError else {
            return nil
        }
        
        return linesBeforeError + [lineAtError] + linesAfterError
    }
}
