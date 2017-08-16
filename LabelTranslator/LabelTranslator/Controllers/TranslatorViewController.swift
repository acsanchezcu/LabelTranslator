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
    
    @IBOutlet weak var cameraView: UIView!
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adjustSessionVideo()
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
    
    // MARK: - Private Methods
    
    private func adjustSessionVideo() {
        sessionLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(sessionLayer)
    }
}

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension TranslatorViewController: AVCaptureVideoDataOutputSampleBufferDelegate
{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        VisionAPI.shared.highlight(pixelBuffer: pixelBuffer, view: cameraView)
    }
    
}
