//
//  ScannerView.swift
//  Navsight
//
//  Created by Aneesh on 14/5/25.
//

import AVKit
import SwiftUI
import UIKit

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var onCodeScanned: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("No camera available")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            print("Can't create camera input")
            return
        }
        
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Can't add metadata output")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        Task.detached {
            await self.captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           metadataObject.type == .qr,
           let stringValue = metadataObject.stringValue, let idValue = UUID(uuidString: stringValue) {
            captureSession.stopRunning()
            onCodeScanned?(idValue.uuidString)
        }
    }
}

extension SetupView {
    private struct ScannerUIView: UIViewControllerRepresentable {
        var onScan: (String) -> Void
        
        func makeUIViewController(context: Context) -> QRScannerViewController {
            let vc = QRScannerViewController()
            vc.onCodeScanned = onScan
            return vc
        }
        
        func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
            // no-op
        }
    }
    
    struct ScannerView: View {
        var onScan: (String) -> Void
        
        init(onScan: @escaping (String) -> Void) {
            self.onScan = onScan
        }
        
        @State private var viewModel: ViewModel = .shared
        
        var body: some View {
            ZStack {
                ScannerUIView(onScan: onScan)
                
                if viewModel.processingInvite {
                    Circle()
                        .fill(.thinMaterial)
                        .frame(width: 324, height: 324)
                        .colorScheme(.dark)
                        .overlay {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .foregroundStyle(.white)
                        }
                        .transition(.opacity)
                }
            }
            .animation(.default, value: viewModel.processingInvite)
            .frame(width: 324, height: 324)
            .clipShape(.circle)
        }
    }
}
