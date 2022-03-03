import Foundation
import DeviceKit

struct DeviceInfo: Codable {
    var deviceName: String
    var isSimulator: Bool
    var displaySize: Double
    var hasRoundedDisplayCorners: Bool
    var orientation: String
    var screenBrightness: Int
    var platformName: String?
    var platformVersion: String?
    var displayPixelDensity: Int?
    var batteryLevel: Int?
    var batteryState: String?
    var lowPowerMode: Bool = false
    var bundleId: String?
    
    init(bundleId: String? = nil) {
        let device = Device.current
        
        self.deviceName = device.safeDescription
        self.isSimulator = device.isSimulator
        self.displaySize = device.diagonal
        self.hasRoundedDisplayCorners = device.hasRoundedDisplayCorners
        self.orientation = device.orientation == .portrait ? "portrait" : "landscape"
        self.screenBrightness = device.screenBrightness
        self.platformName = device.systemName
        self.platformVersion = device.systemVersion
        self.displayPixelDensity = device.ppi
        self.batteryLevel = device.batteryLevel
        self.bundleId = bundleId
        
        if let batteryState = device.batteryState {
            switch batteryState {
            case .full:
                self.batteryState = "full"
            case .charging(_):
                self.batteryState = "charging"
            case .unplugged(_):
                self.batteryState = "unplugged"
            }
            
            if batteryState.lowPowerMode {
                self.lowPowerMode = true
            }
        }
    }
    
}
