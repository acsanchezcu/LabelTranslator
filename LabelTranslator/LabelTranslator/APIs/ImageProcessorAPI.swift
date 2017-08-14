//
//  ImageProcessorAPI.swift
//  LabelTranslator
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 8/14/17.
//  Copyright © 2017 Sanchez Custodio, Abel. All rights reserved.
//

import Foundation
import GPUImage
import TesseractOCR

class ImageProcessorAPI {
    
    static let shared = ImageProcessorAPI()
    
    // MARK: - Public Methods
    
    func processImages(images: [UIImage]) -> [UIImage] {
        let gpiAPI = GPUImageAdaptiveThresholdFilter()
        
        gpiAPI.blurRadiusInPixels = 10.0
        
        return images.map {
            if let image = gpiAPI.image(byFilteringImage: $0) {
                return image
            } else {
                return $0.g8_blackAndWhite()
            }
        }
    }
    
}
