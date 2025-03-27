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



