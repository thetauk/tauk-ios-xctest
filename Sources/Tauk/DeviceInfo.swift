import Foundation
import DeviceKit

struct DeviceInfo: Codable {
    var deviceName: String
    var isSimulator: String
    var displaySize: String
    var hasRoundedDisplayCorners: String
    var orientation: String
    var screenBrightness: String
    var platformName: String?
    var platformVersion: String?
    var displayPixelDensity: String?
    var batteryLevel: String?
    var batteryState: String?
    var lowPowerMode: String = String(false)
    var bundleId: String?
    
    init(bundleId: String?) {
        let device = Device.current
        
        self.deviceName = device.safeDescription
        self.isSimulator = String(device.isSimulator)
        self.displaySize = String(device.diagonal)
        self.hasRoundedDisplayCorners = String(device.hasRoundedDisplayCorners)
        self.orientation = device.orientation == .portrait ? "portrait" : "landscape"
        self.screenBrightness = String(device.screenBrightness)
        self.platformName = device.systemName
        self.platformVersion = device.systemVersion
        self.bundleId = bundleId
        
        if let ppi = device.ppi {
            self.displayPixelDensity = String(ppi)
        }
        
        if let batLevel = device.batteryLevel {
            self.batteryLevel = String(batLevel)
        }
        
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
                self.lowPowerMode = String(true)
            }
        }
    }
    
}
