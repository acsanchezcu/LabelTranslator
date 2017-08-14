//
//  TesseractAPI.swift
//  LabelTranslator
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 8/14/17.
//  Copyright © 2017 Sanchez Custodio, Abel. All rights reserved.
//

import TesseractOCR
import GPUImage

class TesseractAPI: NSObject {
    
    // MARK: - Singleton
    
    static let shared = TesseractAPI()
    
    // MARK: - Properties
    
    private var result: [Tesseract]?
    private let queue = OperationQueue()
    
    // MARK: - Public Methods
    
    func recognize(images: [UIImage], completionHandler: @escaping (String) -> ()) {
        if images.count == 0 || queue.operationCount > 0 {
            print("NO IMAGES OR OPERATIONS IN PROCESS")
            completionHandler("")
            return
        }
        
        queue.qualityOfService = .background
        
        result = []
        
        for (index, image) in images.enumerated() {
            let tesseract = Tesseract(index: index, status: .pending)
            
            result?.append(tesseract)
            
            let operation = TesseractOperation.init(image: image)
            
            operation.qualityOfService = .background
            operation.queuePriority = .high
            
            operation.tesseractCompletion = { [weak self] (value) in
                var recognizedText = ""
                if let value = value {
                    recognizedText = value
                    self?.result?[index].status = .success
                } else {
                    self?.result?[index].status = .error
                }
                
                self?.result?[index].value = recognizedText.replacingOccurrences(of: "\n\n", with: "\n")
                
                if let finished = self?.checkIfResultsIsFinished(),
                    finished,
                    let result = self?.buildText() {
                    
                    //Clean the cache of TesseractOCR
                    
                    G8Tesseract.clearCache()
                    
                    completionHandler(result)
                }
            }
            
            queue.addOperation(operation)
        }
    }
    
    // MARK: - Private Methods
    
    private func checkIfResultsIsFinished() -> Bool? {
        guard let results = result else { return nil }
        
        let filter = results.filter{ $0.status == .pending }
        
        return filter.count == 0
    }
    
    private func buildText() -> String {
        guard let results = result else { return "" }
        
        var text = ""
        
        results.forEach {
            if let value = $0.value {
                text += value
            }
        }
        
        return text
    }
}

private class Tesseract {
    enum Status {
        case pending
        case error
        case success
    }
    
    var index: Int
    var status: Status
    var value: String?
    
    init(index: Int, status: Status) {
        self.index = index
        self.status = status
    }
}

private class TesseractOperation: Operation {
    
    let image: UIImage
    var tesseractCompletion: ((String?) -> Void)?
    
    init(image: UIImage) {
        self.image = image
    }
    
    override func main() {
        autoreleasepool {
            guard let tesseract = G8Tesseract(language: "eng") else {
                guard let tesseractCompletion = tesseractCompletion else { return }
                
                tesseractCompletion(nil)
                
                return
            }
            
            tesseract.charBlacklist = "‘'"
            tesseract.delegate = self
            
            tesseract.image = processImage(image: image)
            
            tesseract.recognize()
            
            completionBlock = { [weak self] in
                guard let tesseractCompletion = self?.tesseractCompletion else { return }
                
                tesseractCompletion(tesseract.recognizedText)
            }
        }
    }
    
    private func processImage(image: UIImage) -> UIImage {
        if let processedImage = ImageProcessorAPI.shared.processImages(images: [image]).first {
            return processedImage
        } else {
            return image
        }
    }
    
}

extension TesseractOperation: G8TesseractDelegate
{
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print("Tesseract progress --- \(tesseract.progress)%")
    }
}
