import UIKit

final class PixelManager {
    func modifyPixels(image: UIImage,
                      redHandler: ((UInt8) -> (UInt8)) = { return $0 },
                      greenHandler: ((UInt8) -> (UInt8)) = { return $0 },
                      blueHandler: ((UInt8) -> (UInt8)) = { return $0 },
                      alpha: UInt8) -> UIImage? {
        let pixelData = image.pixelData()
            .modifyRed(pixelHandler: redHandler)
            .modifyBlue(pixelHandler: blueHandler)
            .modifyGreen(pixelHandler: greenHandler)
            .modifyAlpha(alpha)
        
        return pixelData.toUIImage()
    }
    
    func setGrayScale(image: UIImage, style: PixelData.GrayscaleStyle) -> UIImage? {
        let pixelData = image.pixelData()
            .grayscale(style: style)
        
        return pixelData.toUIImage()
    }
    
    func deleteHalfPixels(image: UIImage) -> UIImage? {
        let pixelData = image.pixelData()
            .downsampleByRemovingOddColumns()
            .downsampleByRemovingOddRows()
        return pixelData.toUIImage()
    }
    
    func cropImageMaintainingCenterPoint(image: UIImage, cgrect: CGRect) -> UIImage? {
        let pixelData = image.pixelData()
            .cropImage(newWidth: Int(cgrect.size.width), newHeight: Int(cgrect.size.height), startPoint: cgrect.origin)
        
        return pixelData.toUIImage()
    }
}

//UIImage to PixelData([UInt8])
extension UIImage {
    func pixelData() -> PixelData {
        guard let cgImage = self.cgImage,
              let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data else { return PixelData(width: 0, height: 0, data: []) }
        
        let pixelData = CFDataGetBytePtr(data)
        let length = CFDataGetLength(data)
        let pixelArray = pixelData.map { Array(UnsafeBufferPointer(start: $0, count: length)) }!
        
        print("Total Data Size: \(pixelArray.count)")
//        print("100 bytes in Middle: \(pixelArray[524788..<524888])")
        
        return PixelData(width: cgImage.width, height: cgImage.height, data: pixelArray)
    }
}

// reverse RGB Num
extension UInt8 {
    func reversePixelColor() -> UInt8 {
        return 255 - self
    }
}

extension UIImage {
    func downSample(scale: CGFloat) -> UIImage {
        let data = self.pngData()! as CFData
        let imageSource = CGImageSourceCreateWithData(data, nil)!
        let maxPixel = max(self.size.width, self.size.height) * scale
        let options = [
            kCGImageSourceThumbnailMaxPixelSize: maxPixel,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ] as CFDictionary

        let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options)!

        return UIImage(cgImage: scaledImage)
    }
}
