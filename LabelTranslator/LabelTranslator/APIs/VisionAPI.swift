//
//  VisionAPI.swift
//  LabelTranslator
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 8/14/17.
//  Copyright © 2017 Sanchez Custodio, Abel. All rights reserved.
//

import Vision
import UIKit

class VisionAPI
{
    // MARK: - Singleton
    
    static let shared = VisionAPI()
    
    // MARK: - Public Methods
    
    func highlight(imageView: UIImageView, completionHandler: @escaping ([UIImage]) -> Void) {
        highlight(view: imageView, pixelBuffer: nil, completionHandler: completionHandler)
    }
    
    func highlight(pixelBuffer: CVPixelBuffer, view: UIView) {
        highlight(view: view, pixelBuffer: pixelBuffer, completionHandler: nil)
    }
    
    // MARK: - Private Methods
    
    private func highlight(view: UIView, pixelBuffer: CVPixelBuffer?, completionHandler: (([UIImage]) -> Void)?) {
        var imageRequestHandler: VNImageRequestHandler?
        
        if let imageView = view as? UIImageView,
            let cgImage = imageView.image?.cgImage {
            imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        } else if let pixelBuffer = pixelBuffer {
            imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: 6, options: [:])
        }
        
        guard let handler = imageRequestHandler else { return }
        
        let request = VNDetectTextRectanglesRequest { [weak self] (request, error) in
            if error != nil {
                return
            }
            
            self?.detectTextHandler(request: request, view: view, completionHandler: completionHandler)
        }
        
        request.reportCharacterBoxes = true
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    private func highlightWords(box: VNTextObservation, view: UIView) {
        guard let boxes = box.characterBoxes else { return }
        
        let outline = CALayer()
        
        guard let frame = getFramesForWord(boxes: boxes, view: view) else { return }
        
        outline.frame = frame
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.red.cgColor
        
        view.layer.addSublayer(outline)
    }
    
    private func getFramesForWord(boxes: [VNRectangleObservation], view: UIView) -> CGRect? {
        var maxX: CGFloat = 9999.0
        var minX: CGFloat = 0.0
        var maxY: CGFloat = 9999.0
        var minY: CGFloat = 0.0
        
        for char in boxes {
            if char.bottomLeft.x < maxX {
                maxX = char.bottomLeft.x
            }
            if char.bottomRight.x > minX {
                minX = char.bottomRight.x
            }
            if char.bottomRight.y < maxY {
                maxY = char.bottomRight.y
            }
            if char.topRight.y > minY {
                minY = char.topRight.y
            }
        }
        
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        if let imageView = view as? UIImageView,
            let image = imageView.image {
            width = image.size.width
            height = image.size.height
        } else {
            width = view.frame.size.width
            height = view.frame.size.height
        }
        
        let xCord = maxX * width
        let yCord = (1 - minY) * height
        let widthWord = (minX - maxX) * width
        let heightWord = (minY - maxY) * height
        
        return CGRect(x: xCord, y: yCord, width: widthWord, height: heightWord)
    }
    
    private func detectTextHandler(request: VNRequest, view: UIView, completionHandler: (([UIImage]) -> Void)?) {
        DispatchQueue.main.async {
            if let imageView = view as? UIImageView {
                imageView.layer.sublayers?.removeAll()
            } else {
                view.layer.sublayers?.removeSubrange(1...)
            }
        }
        
        guard let observations = request.results,
            observations.count > 0 else {
                return
        }
        
        let result = observations.map({$0 as? VNTextObservation})
        
        DispatchQueue.main.async() {
            for region in result {
                guard let region = region else {
                    continue
                }
                
                self.highlightWords(box: region, view: view)
            }
            
            if let completionHandler = completionHandler {
                self.getWordImages(view: view, result: result, completionHandler: completionHandler)
            }
        }
    }
    
    private func getWordImages(view: UIView, result: [VNTextObservation?], completionHandler: @escaping ([UIImage]) -> Void) {
        var images: [UIImage] = []
        
        guard  let imageView = view as? UIImageView,
            let image = imageView.image else {
                completionHandler(images)
                return
        }
        
        for box in result {
            guard let box = box else {
                continue
            }
            
            guard let boxes = box.characterBoxes else { break }
            
            guard let cgImage = image.cgImage,
                let frame = getFramesForWord(boxes: boxes, view: view),
                let imageRef = cgImage.cropping(to: frame) else { break }
            
            let imageCropped = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
            
            images.append(imageCropped)
        }
        
        completionHandler(images)
    }
}
