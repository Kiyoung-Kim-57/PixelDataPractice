import UIKit

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
        
        return PixelData(width: cgImage.width, height: cgImage.height, data: pixelArray)
    }
    
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
