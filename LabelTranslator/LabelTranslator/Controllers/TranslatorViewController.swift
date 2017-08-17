//
//  TranslatorViewController.swift
//  LabelTranslator
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 8/14/17.
//  Copyright © 2017 Sanchez Custodio, Abel. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class TranslatorViewController: UIViewController
{    
    // MARK: - Outlets
    
    @IBOutlet weak var languageFromButton: UIButton!
    @IBOutlet weak var languageToButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
        }
    }
    @IBOutlet weak var translationLabel: UILabel! {
        didSet {
            translationLabel.text = ""
        }
    }
    
    // MARK: - Properties
    
    private lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard let captureDevice = AVCaptureDevice.default(for: .video),
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return session }
        
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        return session
    }()
    
    private lazy var sessionLayer: AVCaptureVideoPreviewLayer = {
        let sessionLayer = AVCaptureVideoPreviewLayer(session: self.session)
        
        sessionLayer.videoGravity = .resize
        
        return sessionLayer
    }()
    var cvPixelBuffer: CVPixelBuffer?
    var type: LanguageType = .from
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustSessionVideo()
        addTapRecognizerForCameraView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        session.startRunning()
        
        let languageFrom = Settings.shared.getLanguage(type: .from)
        let languageTo = Settings.shared.getLanguage(type: .to)
        
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0),NSAttributedStringKey.underlineStyle : 1]
        
        let fromTitle = NSAttributedString(string: languageFrom.name ?? languageFrom.language,
                                                 attributes: attributes)
        let toTitle = NSAttributedString(string: languageTo.name ?? languageTo.language,
                                           attributes: attributes)
        languageFromButton.setAttributedTitle(fromTitle, for: .normal)
        languageToButton.setAttributedTitle(toTitle, for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.stopRunning()
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cameraView.layer.sublayers?[0].frame = cameraView.bounds
    }
    
    // MARK: - Actions
    
    @objc func cameraViewTapped() {
        detectAndTranslateText()
    }
    
    @IBAction func languagesButtonTapped(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        
        type = (button.isEqual(languageFromButton)) ? .from : .to
        
        performSegue(withIdentifier: "goToLanguages", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController,
            let viewController = navigationController.viewControllers.first as? LanguagesViewController else {
                return
        }
        
        viewController.type = type
    }
    
    // MARK: - Private Methods
    
    private func detectAndTranslateText() {
        guard let image = UIImage.imageWithCVPixelBuffer(cvPixelBuffer)?.fixedOrientation() else {
            return
        }
        
        imageView.image = image
        
        translationLabel?.text = ""
        activityIndicator.startAnimating()
        
        VisionAPI.shared.highlight(imageView: imageView) { [weak self] (images) in
            if images.isEmpty {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
                print("no images founded")
                return
            }
            TesseractAPI.shared.recognize(images: images, completionHandler: { (text) in
                if text.isEmpty {
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                    }
                    print("no text recognized")
                    return
                }
                
                TranslationAPI.shared.translateText(text, language: Settings.shared.getLanguage(type: .to).language, completionHandler: { (translate, error) in
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                    }
                    
                    if let error = error {
                        let alertController = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self?.present(alertController, animated: true, completion: nil)
                    }
                    
                    guard let translateText = translate else { return }
                    
                    DispatchQueue.main.async {
                        self?.translationLabel.text = translateText
                    }
                })
            })
        }
    }
    
    private func adjustSessionVideo() {
        sessionLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(sessionLayer)
    }
    
    private func addTapRecognizerForCameraView() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TranslatorViewController.cameraViewTapped))
        
        cameraView?.addGestureRecognizer(tapRecognizer)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension TranslatorViewController: AVCaptureVideoDataOutputSampleBufferDelegate
{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        cvPixelBuffer = pixelBuffer
        
        VisionAPI.shared.highlight(pixelBuffer: pixelBuffer, view: cameraView)
    }
    
}
