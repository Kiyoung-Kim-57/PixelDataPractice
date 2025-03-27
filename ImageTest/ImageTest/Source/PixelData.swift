import UIKit

struct PixelData {
    let width: Int
    let height: Int
    let data: [UInt8]
    
    func toUIImage() -> UIImage? {
        let dataProvider = CGDataProvider(data: NSData(bytes: data, length: data.count))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        if let dataProvider = dataProvider,
           let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
           ) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
    
    // MARK: Grayscale
    func grayscale(style: GrayscaleStyle) -> Self {
        var modified: [UInt8] = []
        
        switch style {
        case .average:
            modified = averageGrayscale(self.data)
        case .luma:
            modified = lumaGrayScale(self.data)
        }
        
        return PixelData(width: width, height: height, data: modified)
    }
    
    private func averageGrayscale(_ data: [UInt8]) -> [UInt8] {
        var result: [UInt8] = data
        for i in stride(from: 0, to: data.count, by: 4) {
            let average: UInt8 = UInt8((Double(data[i]) + Double(data[i+1]) + Double(data[i+2])) / 3)
            result[i] = average
            result[i+1] = average
            result[i+2] = average
        }
        
        return result
    }
    
    private func lumaGrayScale(_ data: [UInt8]) -> [UInt8] {
        var result: [UInt8] = data
        for i in stride(from: 0, to: data.count, by: 4) {
            let luma = UInt8(0.299 * Double(data[i]) + 0.587 * Double(data[i+1]) + 0.114 * Double(data[i+2]))
            result[i] = luma
            result[i+1] = luma
            result[i+2] = luma
        }
        
        return result
    }
    
    // MARK: Downsampling
    func downsampleByRemovingOddColumns() -> Self {
        var modified: [UInt8] = []
        for i in stride(from: 0, to: data.count, by: 4) {
            guard ((i + 1) / 4) % 2 == 0 else { continue }
            modified += [data[i], data[i+1], data[i+2], data[i+3]]
        }
        
        return PixelData(width: width / 2, height: height, data: modified)
    }
    
    func downsampleByRemovingOddRows() -> Self {
        var modified: [UInt8] = []
        let widthPixels = width * 4
        for i in stride(from: 0, to: data.count, by: widthPixels) {
            guard ((i + 1) / (widthPixels)) % 2 == 0 else { continue }
            modified += data[i..<(i + widthPixels)]
        }
        
        return PixelData(width: width, height: height / 2, data: modified)
    }
    
    func cropImage(newWidth nw: Int, newHeight nh: Int, startPoint: CGPoint) -> Self {
        guard width >= nw + Int(startPoint.x), height >= nh + Int(startPoint.y) else {
            print("Crop Failed Consider Image Size width: \(width), height: \(height)")
            return self
        }
        var modified: [UInt8] = []
        let widthPixels = width * 4
        let newWidthPixels = nw * 4
        let startX = Int(startPoint.x * 4)
        let startY = Int(startPoint.y) * widthPixels
        for i in stride(from: startY, to: startY + (nh * widthPixels), by: widthPixels) {
            let leftEdge = i + startX
            let rightEdge = leftEdge + newWidthPixels
            modified += data[(leftEdge)..<(rightEdge)]
        }
        
        return PixelData(width: nw, height: nh, data: modified)
    }
                                       
    // MARK: Modify Color Pixels & Alpha
    func modifyRed(pixelHandler: (UInt8) -> (UInt8)) -> Self {
        var modified = self.data
        for (index, value) in data.enumerated() {
            guard index % 4 == 0 else { continue }
            
            let newValue = pixelHandler(value)
            modified[index] = newValue
        }
        
        return PixelData(width: width, height: height, data: modified)
    }
    
    func modifyGreen(pixelHandler: (UInt8) -> (UInt8)) -> Self {
        var modified = self.data
        for (index, value) in data.enumerated() {
            guard index % 4 == 1 else { continue }
            
            let newValue = pixelHandler(value)
            modified[index] = newValue
        }
        
        return PixelData(width: width, height: height, data: modified)
    }
    
    func modifyBlue(pixelHandler: (UInt8) -> (UInt8)) -> Self {
        var modified = self.data
        for (index, value) in data.enumerated() {
            guard index % 4 == 2 else { continue }
            
            let newValue = pixelHandler(value)
            modified[index] = newValue
        }
        return PixelData(width: width, height: height, data: modified)
    }
    
    func modifyAlpha(_ alpha: UInt8) -> Self {
        var modified = self.data
        for index in 0..<data.count {
            guard index % 4 == 3 else { continue }
            
            let newValue = alpha
            modified[index] = newValue
        }
        return PixelData(width: width, height: height, data: modified)
    }
    
    // MARK: Enum
    enum GrayscaleStyle {
        case average
        case luma
    }
}


