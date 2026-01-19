//
//  SVGImageHelper.swift
//  TextListener
//
//  Helper to load SVG images for use in SwiftUI
//

import SwiftUI
import AppKit

struct SVGImage: View {
    let name: String
    let size: CGSize?
    
    init(_ name: String, size: CGSize? = nil) {
        self.name = name
        self.size = size
    }
    
    var body: some View {
        if let image = loadSVGImage(named: name, targetSize: size) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size?.width, height: size?.height)
        } else {
            // Fallback to asset catalog if SVG not found
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size?.width, height: size?.height)
        }
    }
    
    private func loadSVGImage(named name: String, targetSize: CGSize?) -> NSImage? {
        // Try loading from asset catalog first (if PDF/PNG exists)
        if let image = NSImage(named: name) {
            // Resize if target size is specified
            if let targetSize = targetSize {
                return resizeImage(image, to: targetSize)
            }
            return image
        }
        
        // Try loading SVG from bundle
        guard let url = Bundle.main.url(forResource: name, withExtension: "svg") else {
            return nil
        }
        
        var image: NSImage?
        
        // For macOS 11+, we can use NSImage directly with SVG
        if #available(macOS 11.0, *) {
            image = NSImage(contentsOf: url)
        } else {
            // Fallback: try to load as data and create image
            if let data = try? Data(contentsOf: url) {
                image = NSImage(data: data)
            }
        }
        
        // Resize the image to target size if specified
        if let image = image, let targetSize = targetSize {
            return resizeImage(image, to: targetSize)
        }
        
        return image
    }
    
    private func resizeImage(_ image: NSImage, to size: CGSize) -> NSImage {
        let resizedImage = NSImage(size: size)
        resizedImage.lockFocus()
        defer { resizedImage.unlockFocus() }
        
        // Use high-quality interpolation
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(origin: .zero, size: size),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .sourceOver,
                   fraction: 1.0)
        return resizedImage
    }
}

// Convenience extension for easier usage
extension Image {
    static func svg(_ name: String, size: CGSize? = nil) -> some View {
        SVGImage(name, size: size)
    }
}

