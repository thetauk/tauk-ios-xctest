import Foundation
import XCTest
import AEXML

struct LogEntry: Codable {
    var unixTimestamp: String
    var level: String?
    var message: String
    var type: String
    
    init(date: Date, message: String, type: String = "XCTest", level: String? = nil) {
        self.unixTimestamp = String(Int(date.timeIntervalSince1970))
        self.message = message.trimmingCharacters(in: .whitespacesAndNewlines)
        self.type = type
        self.level = level
    }
    
    enum CodingKeys: String, CodingKey {
        case unixTimestamp = "timestamp"
        case level = "level"
        case message = "message"
        case type = "type"
    }
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
    let baseName = "XCUIElementType"
    switch element.elementType {
    case .activityIndicator:
        return "\(baseName)ActivityIndicator"
    case .other:
        return "\(baseName)Other"
    case .any:
        return "\(baseName)Any"
    case .application:
        return "\(baseName)Application"
    case .group:
        return "\(baseName)Group"
    case .window:
        return "\(baseName)Window"
    case .sheet:
        return "\(baseName)Sheet"
    case .drawer:
        return "\(baseName)Drawer"
    case .alert:
        return "\(baseName)Alert"
    case .dialog:
        return "\(baseName)Dialog"
    case .button:
        return "\(baseName)Button"
    case .radioButton:
        return "\(baseName)RadioButton"
    case .radioGroup:
        return "\(baseName)RadioGroup"
    case .checkBox:
        return "\(baseName)CheckBox"
    case .disclosureTriangle:
        return "\(baseName)DisclosureTriangle"
    case .popUpButton:
        return "\(baseName)PopupButton"
    case .comboBox:
        return "\(baseName)ComboBox"
    case .menuButton:
        return "\(baseName)MenuButton"
    case .toolbarButton:
        return "\(baseName)ToolbarButton"
    case .popover:
        return "\(baseName)Popover"
    case .keyboard:
        return "\(baseName)Keyboard"
    case .key:
        return "\(baseName)Key"
    case .navigationBar:
        return "\(baseName)NavigationBar"
    case .tabBar:
        return "\(baseName)TabBar"
    case .tabGroup:
        return "\(baseName)TabGroup"
    case .toolbar:
        return "\(baseName)Toolbar"
    case .statusBar:
        return "\(baseName)StatusBar"
    case .table:
        return "\(baseName)Table"
    case .tableRow:
        return "\(baseName)TableRow"
    case .tableColumn:
        return "\(baseName)TableColumn"
    case .outline:
        return "\(baseName)Outline"
    case .outlineRow:
        return "\(baseName)OutlineRow"
    case .browser:
        return "\(baseName)Browser"
    case .collectionView:
        return "\(baseName)CollectionView"
    case .slider:
        return "\(baseName)Slider"
    case .pageIndicator:
        return "\(baseName)PageIndicator"
    case .progressIndicator:
        return "\(baseName)ProgressIndicator"
    case .segmentedControl:
        return "\(baseName)SegmentedControl"
    case .picker:
        return "\(baseName)Picker"
    case .pickerWheel:
        return "\(baseName)PickerWheel"
    case .switch:
        return "\(baseName)Switch"
    case .toggle:
        return "\(baseName)Toggle"
    case .link:
        return "\(baseName)Link"
    case .image:
        return "\(baseName)Image"
    case .icon:
        return "\(baseName)Icon"
    case .searchField:
        return "\(baseName)SearchField"
    case .scrollView:
        return "\(baseName)ScrollView"
    case .scrollBar:
        return "\(baseName)ScrollBar"
    case .staticText:
        return "\(baseName)StaticText"
    case .textField:
        return "\(baseName)TextFiled"
    case .secureTextField:
        return "\(baseName)SecureTextField"
    case .datePicker:
        return "\(baseName)DatePicker"
    case .textView:
        return "\(baseName)TextView"
    case .menu:
        return "\(baseName)Menu"
    case .menuItem:
        return "\(baseName)MenuItem"
    case .menuBar:
        return "\(baseName)MenuBar"
    case .menuBarItem:
        return "\(baseName)MenuBarItem"
    case .map:
        return "\(baseName)Map"
    case .webView:
        return "\(baseName)WebView"
    case .incrementArrow:
        return "\(baseName)IncrementArrow"
    case .decrementArrow:
        return "\(baseName)DecrementArrow"
    case .timeline:
        return "\(baseName)Timeline"
    case .ratingIndicator:
        return "\(baseName)RatingIndicator"
    case .valueIndicator:
        return "\(baseName)ValueIndicator"
    case .splitGroup:
        return "\(baseName)SplitGroup"
    case .splitter:
        return "\(baseName)Splitter"
    case .relevanceIndicator:
        return "\(baseName)RelevanceIndicator"
    case .colorWell:
        return "\(baseName)ColorWell"
    case .helpTag:
        return "\(baseName)HelpTag"
    case .matte:
        return "\(baseName)Matte"
    case .dockItem:
        return "\(baseName)DockItem"
    case .ruler:
        return "\(baseName)Ruler"
    case .rulerMarker:
        return "\(baseName)RulerMarker"
    case .grid:
        return "\(baseName)Grid"
    case .levelIndicator:
        return "\(baseName)LevelIndicator"
    case .cell:
        return "\(baseName)Cell"
    case .layoutArea:
        return "\(baseName)LayoutArea"
    case .layoutItem:
        return "\(baseName)LayoutItem"
    case .handle:
        return "\(baseName)Handle"
    case .stepper:
        return "\(baseName)Stepper"
    case .tab:
        return "\(baseName)Tab"
    case .touchBar:
        return "\(baseName)TouchBar"
    case .statusItem:
        return "\(baseName)StatusItem"
    @unknown default:
        return "\(baseName)Unknown"
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
        print("Warning: No App Snapshot available.")
        return xmlDoc.xmlCompact
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
    return xmlDoc.xmlCompact
}
