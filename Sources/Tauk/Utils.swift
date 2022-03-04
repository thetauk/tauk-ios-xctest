import Foundation
import XCTest
import AEXML

// TODO: Get log files
func getLog() {

}

func formatTestMethodName(rawNameString: String) -> String {
    // Original format:
    // "-[ClassName testMethodName]"
    var intermediateString = rawNameString.replacingOccurrences(of: "-[", with: "")
    intermediateString = intermediateString.replacingOccurrences(of: "]", with: "")
    let resultStringArr = intermediateString.components(separatedBy: " ")
    return resultStringArr[1]
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


struct Stack<AEXMLElement, Int> {
    private var myArray: [(AEXMLElement, Int)] = []

    mutating func push(_ element: AEXMLElement, _ depth: Int) {
        myArray.append((element, depth))
    }

    mutating func pop() -> (element: AEXMLElement, depth: Int)? {
        return myArray.popLast()
    }

    func peek() -> (element: AEXMLElement, depth: Int)? {
        return myArray.last
    }

    func size() -> Int {
        return myArray.count as! Int
    }
}

func getXmlElement(line: String) -> (element: AEXMLElement?, depth: Int?) {
    let start = line.index(line.startIndex, offsetBy: 2)
    let correctedLine = String(line[start..<line.endIndex])

    let range = NSRange(correctedLine.startIndex..<correctedLine.endIndex, in: correctedLine)
    let pattern = #"(?<depth>\s*)(?<tagName>.+?), (?<ref>.+?), \{\{(?<x>.+?), (?<y>.+?)\}, \{(?<width>.+?), (?<height>.+?)\}\}[.*|, ]?(?<attributes>.*)"#
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let matches = regex.matches(in: correctedLine, options: [], range: range)
    guard let match = matches.first else {
        print("WARNING: failed to parse the line: " + line)
        return (nil, nil)
    }

    var attributes: [String: String] = [:]
    for name in ["ref", "x", "y", "width", "height"] {
        let matchRange = match.range(withName: name)
        if let substringRange = Range(matchRange, in: correctedLine) {
            attributes[name] = String(correctedLine[substringRange])
        }
    }

    var elementName = "XCUIElementType"
    let tagNameMatchRange = match.range(withName: "tagName")
    if let tagNameRange = Range(tagNameMatchRange, in: correctedLine) {
        elementName += String(correctedLine[tagNameRange].split(separator: " ")[0]).trimmingCharacters(in: .whitespaces)
    }

    var depth: Int?
    let depthMatchRange = match.range(withName: "depth")
    if let depthRange = Range(depthMatchRange, in: correctedLine) {
        depth = correctedLine[depthRange].count / 2
    }

    let e = AEXMLElement(name: elementName, attributes: attributes)
    let parts = correctedLine.split(separator: ",")
    if parts.count < 4 {
        return (nil, nil)
    }

    return (e, depth)
}

func getViewHierarchy2(app: XCUIApplication) throws -> String {
    let rawStringDesc = app.debugDescription

    var elementStack = Stack<AEXMLElement, Int>()
    let xmlDoc = try AEXMLDocument()
    var startParsingXml = false
    rawStringDesc.enumerateLines { (line, _) in

        if startParsingXml && line.starts(with: "Path to element:") {
            startParsingXml = false
            return
        }

        if startParsingXml {
            let e = getXmlElement(line: line)
            if let element = e.element, let depth = e.depth {
                if let lastElement = elementStack.peek() {
                    if lastElement.depth == depth - 1 {// Add as child
                        lastElement.element.addChild(element)
                        elementStack.push(element, depth)
                    } else if lastElement.depth == depth {
                        elementStack.pop()
                        if let lastElement = elementStack.peek() {
                            lastElement.element.addChild(element)
                            elementStack.push(element, depth)
                        }
                    } else if lastElement.depth > depth {
                        for i in 1...(lastElement.depth - depth + 1) {
                            elementStack.pop()
                        }
                        if let lastElement = elementStack.peek() {
                            lastElement.element.addChild(element)
                            elementStack.push(element, depth)
                        }
                    }
                } else {
                    elementStack.push(element, depth)
                }
            }
        }
        if line.starts(with: "Element subtree:") {
            startParsingXml = true
        }
    }

    // Flush the stack
    while elementStack.size() != 0 {
        if let e = elementStack.pop() {
            if e.depth == 1 {
                xmlDoc.addChild(e.element)
            }
        }
    }
    return xmlDoc.xml
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
            guard let strongSelf = self else {
                return
            }

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
