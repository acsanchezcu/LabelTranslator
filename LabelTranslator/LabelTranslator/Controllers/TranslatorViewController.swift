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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adjustSessionVideo()
        addTapRecognizerForCameraView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        session.startRunning()
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
    
    // MARK: - Private Methods
    
    private func detectAndTranslateText() {
        imageView.image = UIImage.imageWithCVPixelBuffer(cvPixelBuffer)?.fixedOrientation()
        
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
                print(text)
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.translationLabel?.text = text
                }
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
