//
//  Utils.swift
//  
//
//  Created by Nathan Krishnan on 2/21/22.
//

import Foundation
import XCTest
import AEXML
import DeviceKit

enum TestStatus: String {
    case passed
    case failed
    case excluded
    case resolved
    case undetermined
}

struct CodeLine {
    var lineNumber: Int
    var lineCode: String
    
    init(_ lineNumber: Int, _ lineCode: String) {
        self.lineNumber = lineNumber
        self.lineCode = lineCode
    }
}

struct TaukError {
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
    
    // TODO: Return Array of Strings and Code Executed Line
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

struct TestResult {
    var status: TestStatus?
    let name: String
    let filename: String
    var tags: [String: Any]
    var screenshot: String?
    var viewSource: String?
    let startTime: TimeInterval
    var endTime: TimeInterval?
    
    // TODO: Implement 'error' and 'codeContext'
    init(testName name: String, filename: String, initialTags: [String: Any]) {
        self.name = name
        self.filename = filename
        self.tags = initialTags
        self.startTime = ProcessInfo.processInfo.systemUptime
    }
    
    func calcElapsedTimeMilliseconds() -> Int? {
        if let endTime = self.endTime {
            return Int((endTime - self.startTime) * 1000)
        } else {
            return nil
        }
    }
}

// TODO: Get log files
func getLog() {
    
}

// TODO: Implement function
func upload(testResult: TestResult) {
    
}

func formatTestMethodName(rawNameString: String) -> String {
    // Original format:
    // "-[ClassName testMethodName]"
    var intermediateString = rawNameString.replacingOccurrences(of: "-[", with: "")
    intermediateString = intermediateString.replacingOccurrences(of: "]", with: "")
    let resultStringArr = intermediateString.components(separatedBy: " ")
    return resultStringArr[1]
}

func getDeviceInformation() -> [String: Any] {
    let device = Device.current
    
    var deviceInfoDict: [String: Any] = [
        "deviceName": device.safeDescription,
        "isSimulator": device.isSimulator,
        "displaySize": device.diagonal,
        "hasRoundedDisplayCorners": device.hasRoundedDisplayCorners,
        "orientation": device.orientation == .portrait ? "portrait" : "landscape",
        "screenBrightness": device.screenBrightness,
        "automationName": "XCUITest"
    ]
    
    if let platformName = device.systemName {
        deviceInfoDict["platformName"] = platformName
    }
    
    if let platformVersion = device.systemVersion {
        deviceInfoDict["platformVersion"] = platformVersion
    }
    
    if let testRunnerBundleIdentifier = Bundle.main.bundleIdentifier {
        deviceInfoDict["bundleId"] = testRunnerBundleIdentifier
    }
    
    if let displayPixelDensity = device.ppi {
        deviceInfoDict["displayPixelDensity"] = displayPixelDensity
    }
    
    if let batteryState = device.batteryState, let batteryLevel = device.batteryLevel {
        deviceInfoDict["batteryLevel"] = batteryLevel
        
        switch batteryState {
        case .full:
            deviceInfoDict["batteryState"] = "full"
        case .charging(_):
            deviceInfoDict["batteryState"] = "charging"
        case .unplugged(_):
            deviceInfoDict["batteryState"] = "unplugged"
        }
        
        if batteryState.lowPowerMode {
            deviceInfoDict["lowPowerMode"] = true
        } else {
            deviceInfoDict["lowPowerMode"] = false
        }
    }
    
    return deviceInfoDict
}

func getElementTypeName(_ element: XCUIElement) -> String {
    let baseName = "XCUIElementType"

    switch element.elementType {
    case .activityIndicator:
        return "\(baseName)TypeActivityIndicator"
    case .alert:
        return "\(baseName)TypeAlert"
    case .application:
        return "\(baseName)Application"
    case .browser:
        return "\(baseName)Browser"
    case .button:
        return "\(baseName)Button"
    case .cell:
        return "\(baseName)Cell"
    case .checkBox:
        return "\(baseName)CheckBox"
    case .collectionView:
        return "\(baseName)CollectionView"
    case .comboBox:
        return "\(baseName)ComboBox"
    case .datePicker:
        return "\(baseName)DatePicker"
    case .dialog:
        return "\(baseName)Dialog"
    case .image:
        return "\(baseName)Image"
    case .key:
        return "\(baseName)Key"
    case .keyboard:
        return "\(baseName)Keyboard"
    case .layoutArea:
        return "\(baseName)LayoutArea"
    case .layoutItem:
        return "\(baseName)LayoutItem"
    case .levelIndicator:
        return "\(baseName)LevelIndicator"
    case .link:
        return "\(baseName)Link"
    case .map:
        return "\(baseName)Map"
    case .other:
        return "\(baseName)Other"
    case .popover:
        return "\(baseName)Popover"
    case .radioButton:
        return "\(baseName)RadioButton"
    case .radioGroup:
        return "\(baseName)RadioGroup"
    case .scrollBar:
        return "\(baseName)ScrollBar"
    case .scrollView:
        return "\(baseName)ScrollView"
    case .searchField:
        return "\(baseName)SearchField"
    case .secureTextField:
        return "\(baseName)SecureTextField"
    case .segmentedControl:
        return "\(baseName)SegmentedControl"
    case .slider:
        return "\(baseName)Slider"
    case .staticText:
        return "\(baseName)StaticText"
    case .switch:
        return "\(baseName)Switch"
    case .table:
        return "\(baseName)Table"
    case .tableColumn:
        return "\(baseName)TableColumn"
    case .tableRow:
        return "\(baseName)TableRow"
    case .textField:
        return "\(baseName)TextField"
    case .textView:
        return "\(baseName)TextView"
    case .toggle:
        return "\(baseName)Toggle"
    case .valueIndicator:
        return "\(baseName)ValueIndicator"
    case .webView:
        return "\(baseName)WebView"
    case .window:
        return "\(baseName)Window"
    default:
        return "\(baseName)Any"
    }
}

func getElementAttributes(_ element: XCUIElement) -> [String: String] {
    return [
        "type": getElementTypeName(element),
        "title": element.title,
        "identifier": element.identifier,
        "label": element.label,
        "placeholderValue": element.placeholderValue ?? "",
        "isHittable": String(element.isHittable),
        "isEnabled": String(element.isEnabled),
        "isSelected": String(element.isSelected),
        "x": String(Int(element.frame.origin.x)),
        "y": String(Int(element.frame.origin.y)),
        "width": String(Int(element.frame.width)),
        "height": String(Int(element.frame.height))
    ]
}

func getViewHierarchy(app: XCUIApplication) -> String {
    let viewHierarchy = AEXMLDocument()
    let body = viewHierarchy.addChild(name: getElementTypeName(app), attributes: getElementAttributes(app))
    
    func traverseElementTree(elementQuery: XCUIElementQuery, body: AEXMLElement) {
        for i in 0..<elementQuery.count {
            let element = elementQuery.element(boundBy: i)
            // Area for potential optimization
            // Check if the element has any children
            if element.children(matching: .any).count > 0 {
                let child = body.addChild(name: getElementTypeName(element), attributes: getElementAttributes(element))
                traverseElementTree(elementQuery: element.children(matching: .any), body: child)
            } else {
                body.addChild(name: getElementTypeName(element), attributes: getElementAttributes(element))
            }
        }
    }
    
    let start = app.children(matching: .any)
    traverseElementTree(elementQuery: start, body: body)
    return viewHierarchy.xml
}

class StreamingFileReader {
    var fileHandle: FileHandle?
    var buffer: Data
    let bufferSize: Int = 1024
    
    // Using new line as the delimiter
    let delimiter = "\n".data(using: .utf8)!
    
    init(path: URL) {
        try? fileHandle = FileHandle(forReadingFrom: path)
        buffer = Data(capacity: bufferSize)
    }
    
    func readLine() -> String? {
        var rangeOfDelimiter = buffer.range(of: delimiter)
        
        while rangeOfDelimiter == nil {
            guard let chunk = fileHandle?.readData(ofLength: bufferSize) else { return nil }
            
            if chunk.count == 0 {
                if buffer.count > 0 {
                    defer { buffer.count = 0 }
                    
                    return String(data: buffer, encoding: .utf8)
                }
                
                return nil
            } else {
                buffer.append(chunk)
                rangeOfDelimiter = buffer.range(of: delimiter)
            }
        }
        
        let rangeOfLine = 0 ..< rangeOfDelimiter!.upperBound
        let line = String(data: buffer.subdata(in: rangeOfLine), encoding: .utf8)
        
        buffer.removeSubrange(rangeOfLine)
        
        return line?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Source: https://bit.ly/3H3bj3B
class OutputListener {
    // Consume the messages on STDOUT
    let inputPipe = Pipe()
    
    // Output messages back to STDOUT
    let outputPipe = Pipe()
    
    // Buffer strings written to STDOUT
    var contents = ""
    
    init() {
        // Setup a read handler, which fires when data is written to the inputPipe
        inputPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            guard let strongSelf = self else { return }
            
            // Use availableData property as it will have a Data object of the character data written to the pipe's file handle, at the time
            let data = fileHandle.availableData
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                strongSelf.contents += string
            }
            
            // Write input back to STDOUT
            strongSelf.outputPipe.fileHandleForWriting.write(data)
            
        }
    }
    
    // Sets up the "tee" of the piped output, intercepting STDOUT and then passing it through
    func openConsolePipe() {
        // Copy STDOUT file descriptor to outputPipe for writing strings back to STDOUT
        dup2(FileHandle.standardOutput.fileDescriptor, outputPipe.fileHandleForWriting.fileDescriptor)
        
        // Intercept STDOUT with inputPipe
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, FileHandle.standardOutput.fileDescriptor)
    }
    
    // Tears down the "tee" of the piped output
    func closeConsolePipe() {
        // Restore STDOUT
        freopen("/dev/stdout", "a", stdout)
        
        [inputPipe.fileHandleForReading, outputPipe.fileHandleForWriting].forEach { file in
            file.closeFile()
        }
    }
}
