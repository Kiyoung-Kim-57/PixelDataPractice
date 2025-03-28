//
//  ContentView.swift
//  ImageTest
//
//  Created by 김기영 on 3/13/25.
//

import SwiftUI

struct ContentView: View {
    private let pixelManager = PixelManager()
    @State private var img = UIImage(named: "pepe")!
    @State private var isCropped: Bool = false
    @State private var croppedImg: UIImage?
    @State private var cropRange: CGRect = CGRect(origin: CGPoint(), size: CGSize(width: 0, height: 0))
    @State private var croppedSize: CGSize = CGSize(width: 350, height: 350)
    var body: some View {
        imageView
    }
    
    private var imageView: some View {
        ZStack {
            VStack {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
            }
            .frame(width: croppedSize.width, height: croppedSize.height)
            
            VStack {
                Spacer()
                HStack(spacing: 15) {
                    downSampleButton1
                    downSampleButton2
                    resetButton
                }
                
                Spacer()
                    .frame(height: 50)
            }
        }
    }
    
    private var downSampleButton1: some View {
        Button {
            img = pixelManager
                .setGrayScale(image: img, style: .luma)
            ?? UIImage()
            
        } label: {
            Text("Downsample1")
                .font(.headline)
                .foregroundStyle(.black)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .padding(-10)
                }
        }

    }
    
    private var downSampleButton2: some View {
        Button {
            img = pixelManager.deleteHalfPixels(image: img)
            ?? UIImage()
        } label: {
            Text("Downsample2")
                .font(.headline)
                .foregroundStyle(.black)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .padding(-10)
                }
        }

    }
    
    private var resetButton: some View {
        Button {
            img = UIImage(named: "pepe")!
        } label: {
            Text("resetButton")
                .font(.headline)
                .foregroundStyle(.black)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .padding(-10)
                }
        }

    }
}
