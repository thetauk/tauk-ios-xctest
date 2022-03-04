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

func getElementName(_ element: XCUIElementSnapshot) -> String {
    switch element.elementType {
    case .activityIndicator:
        return "XCUIElementTypeActivityIndicator"
    case .other:
        return "XCUIElementTypeOther"
    case .any:
        return "XCUIElementTypeAny"
    case .application:
        return "XCUIElementTypeApplication"
    case .group:
        return "XCUIElementTypeGroup"
    case .window:
        return "XCUIElementTypeWindow"
    case .sheet:
        return "XCUIElementTypeSheet"
    case .drawer:
        return "XCUIElementTypeDrawer"
    case .alert:
        return "XCUIElementTypeAlert"
    case .dialog:
        return "XCUIElementTypeDialog"
    case .button:
        return "XCUIElementTypeButton"
    case .radioButton:
        return "XCUIElementTypeRadioButton"
    case .radioGroup:
        return "XCUIElementTypeRadioGroup"
    case .checkBox:
        return "XCUIElementTypeCheckBox"
    case .disclosureTriangle:
        return "XCUIElementTypeDisclosureTriangle"
    case .popUpButton:
        return "XCUIElementTypePopupButton"
    case .comboBox:
        return "XCUIElementTypeComboBox"
    case .menuButton:
        return "XCUIElementTypeMenuButton"
    case .toolbarButton:
        return "XCUIElementTypeToolbarButton"
    case .popover:
        return "XCUIElementTypePopover"
    case .keyboard:
        return "XCUIElementTypeKeyboard"
    case .key:
        return "XCUIElementTypeKey"
    case .navigationBar:
        return "XCUIElementTypeNavigationBar"
    case .tabBar:
        return "XCUIElementTypeTabBar"
    case .tabGroup:
        return "XCUIElementTypeTabGroup"
    case .toolbar:
        return "XCUIElementTypeToolbar"
    case .statusBar:
        return "XCUIElementTypeStatusBar"
    case .table:
        return "XCUIElementTypeTable"
    case .tableRow:
        return "XCUIElementTypeTableRow"
    case .tableColumn:
        return "XCUIElementTypeTableColumn"
    case .outline:
        return "XCUIElementTypeOutline"
    case .outlineRow:
        return "XCUIElementTypeOutlineRow"
    case .browser:
        return "XCUIElementTypeBrowser"
    case .collectionView:
        return "XCUIElementTypeCollectionView"
    case .slider:
        return "XCUIElementTypeSlider"
    case .pageIndicator:
        return "XCUIElementTypePageIndicator"
    case .progressIndicator:
        return "XCUIElementTypeProgressIndicator"
    case .segmentedControl:
        return "XCUIElementTypeSegmentedControl"
    case .picker:
        return "XCUIElementTypePicker"
    case .pickerWheel:
        return "XCUIElementTypePickerWheel"
    case .switch:
        return "XCUIElementTypeSwitch"
    case .toggle:
        return "XCUIElementTypeToggle"
    case .link:
        return "XCUIElementTypeLink"
    case .image:
        return "XCUIElementTypeImage"
    case .icon:
        return "XCUIElementTypeIcon"
    case .searchField:
        return "XCUIElementTypeSearchField"
    case .scrollView:
        return "XCUIElementTypeScrollView"
    case .scrollBar:
        return "XCUIElementTypeScrollBar"
    case .staticText:
        return "XCUIElementTypeStaticText"
    case .textField:
        return "XCUIElementTypeTextFiled"
    case .secureTextField:
        return "XCUIElementTypeSecureTextField"
    case .datePicker:
        return "XCUIElementTypeDatePicker"
    case .textView:
        return "XCUIElementTypeTextView"
    case .menu:
        return "XCUIElementTypeMenu"
    case .menuItem:
        return "XCUIElementTypeMenuItem"
    case .menuBar:
        return "XCUIElementTypeMenuBar"
    case .menuBarItem:
        return "XCUIElementTypeMenuBarItem"
    case .map:
        return "XCUIElementTypeMap"
    case .webView:
        return "XCUIElementTypeWebView"
    case .incrementArrow:
        return "XCUIElementTypeIncrementArrow"
    case .decrementArrow:
        return "XCUIElementTypeDecrementArrow"
    case .timeline:
        return "XCUIElementTypeTimeline"
    case .ratingIndicator:
        return "XCUIElementTyperRatingIndicator"
    case .valueIndicator:
        return "XCUIElementTypeValueIndicator"
    case .splitGroup:
        return "XCUIElementTypeSplitGroup"
    case .splitter:
        return "XCUIElementTypeSplitter"
    case .relevanceIndicator:
        return "XCUIElementTypeRelevanceIndicator"
    case .colorWell:
        return "XCUIElementTypeColorWell"
    case .helpTag:
        return "XCUIElementTypeHelpTag"
    case .matte:
        return "XCUIElementTypeMatte"
    case .dockItem:
        return "XCUIElementTypeDockItem"
    case .ruler:
        return "XCUIElementTypeRuler"
    case .rulerMarker:
        return "XCUIElementTypeRulerMarker"
    case .grid:
        return "XCUIElementTypeGrid"
    case .levelIndicator:
        return "XCUIElementTypeLevelIndicator"
    case .cell:
        return "XCUIElementTypeCell"
    case .layoutArea:
        return "XCUIElementTypeLayoutArea"
    case .layoutItem:
        return "XCUIElementTypeLayoutItem"
    case .handle:
        return "XCUIElementTypeHandle"
    case .stepper:
        return "XCUIElementTypeStepper"
    case .tab:
        return "XCUIElementTypeTab"
    case .touchBar:
        return "XCUIElementTypeTouchBar"
    case .statusItem:
        return "XCUIElementTypeStatusItem"
    @unknown default:
        return "XCUIElementTypeUnknown"
    }
}

func getElementAttributes(_ element: XCUIElementSnapshot) -> [String: String] {
    var attrs: [String: String] = [
        "title": element.title,
        "identifier": element.identifier,
        "label": element.label,
        "placeholderValue": element.placeholderValue ?? "",
        "isEnabled": String(element.isEnabled),
        "isSelected": String(element.isSelected),
        "hasFocus": String(element.hasFocus),
        "x": String(Int(element.frame.origin.x)),
        "y": String(Int(element.frame.origin.y)),
        "width": String(Int(element.frame.width)),
        "height": String(Int(element.frame.height))
    ]

    if let value = element.value {
        attrs["value"] = String(describing: value)
    }
    return attrs
}


func getViewHierarchy(app: XCUIApplication) -> String {
    let xmlDoc = AEXMLDocument()
    guard let snapshot = try? app.snapshot() else {
        print("Waring: No Snapshot available")
        return xmlDoc.xml
    }

    let app = xmlDoc.addChild(name: getElementName(snapshot), attributes: getElementAttributes(snapshot))

    func traverseElementTree(elementSnapshot: XCUIElementSnapshot, xmlElement: AEXMLElement) {
        for es in elementSnapshot.children {
            traverseElementTree(
                    elementSnapshot: es,
                    xmlElement: xmlElement.addChild(AEXMLElement(
                            name: getElementName(elementSnapshot),
                            attributes: getElementAttributes(elementSnapshot)
                    )))
        }
    }

    traverseElementTree(elementSnapshot: snapshot.children[0], xmlElement: app)
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
