# PixelDataPractice
원본 픽셀 데이터를 다루는 실험 프로젝트

## 픽셀 데이터([UInt8]) 추출하기 및 색상 변경
1. [픽셀 데이터 추출 및 색상 반전](https://rongios.tistory.com/9)
### 데이터 추출
```swift
// UIImage Extension
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
```
### 색상 변경
```swift
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
```
### 적용 예시
```swift
let pixelData = image.pixelData()
          .modifyRed(pixelHandler: redHandler)
          .modifyBlue(pixelHandler: blueHandler)
          .modifyGreen(pixelHandler: greenHandler)
          .modifyAlpha(alpha)
```



## Grayscale
2. [그레이스케일 적용](https://rongios.tistory.com/10)
```swift
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
```
## Downsampling
3. [다운샘플링 및 이미지 크롭](https://rongios.tistory.com/11)
```swift
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
```
## Crop
```swift
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
```
