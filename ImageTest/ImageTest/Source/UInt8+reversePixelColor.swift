import Foundation

// reverse RGB Num
extension UInt8 {
    func reversePixelColor() -> UInt8 {
        return 255 - self
    }
}
