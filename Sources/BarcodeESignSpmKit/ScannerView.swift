//
//  File.swift
//  BarcodeESignSpmKit
//
//  Created by Mustafa Alper Aydin on 29.04.2025.
//

import Foundation
import AVFoundation
import SwiftUI

public protocol BarcodeScannable {
    var Barcode: String { get }
    var StatusId: Int { get set } // 0 = okunmadı, 1 = okunuyor, 2 = okundu vs.
}

public struct AnyBarcodeScannable: BarcodeScannable {
    private var _getBarcode: () -> String
    private var _getStatusId: () -> Int
    private var _setStatusId: (Int) -> Void

    public var Barcode: String {
        _getBarcode()
    }

    public var StatusId: Int {
        get { _getStatusId() }
        set { _setStatusId(newValue) }
    }

    public init<T: BarcodeScannable>(_ base: T) {
        var copy = base
        _getBarcode = { copy.Barcode }
        _getStatusId = { copy.StatusId }
        _setStatusId = { copy.StatusId = $0 }
    }
}

public struct ScannerView: UIViewControllerRepresentable {
    @Binding public var isScanning: Bool
    @Binding public var isReadText: Bool
    public var allowMultipleCodes: Bool = true
    public var barcodeColor: Bool = true
    @Binding public var barcodeList: [AnyBarcodeScannable]
    public var isRead: (Int) -> Bool
    public var isReading: (Int) -> Bool
    public var didFindCode: (String) -> Void
    
    public init(isScanning: Binding<Bool>, isReadText: Binding<Bool>, barcodeList: Binding<[AnyBarcodeScannable]>, isRead: @escaping (Int) -> Bool, isReading: @escaping (Int) -> Bool, didFindCode: @escaping (String) -> Void) {
        self._isScanning = isScanning
        self._isReadText = isReadText
        self._barcodeList = barcodeList
        self.isRead = isRead
        self.isReading = isReading
        self.didFindCode = didFindCode
    }

    public class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        public var parent: ScannerView
        public var scannedCodes: Set<String> = []
        public var previewLayer: AVCaptureVideoPreviewLayer?
        public var borderLayers: [String: CAShapeLayer] = [:]
        
        public var captureSession: AVCaptureSession?
        public var currentDeviceInput: AVCaptureDeviceInput?
        public var isTorchOn: Bool = false
        
        public var instructionLabel: UILabel?

        public init(parent: ScannerView) {
            self.parent = parent
        }

        public func getBorderColor(for barcode: String) -> UIColor {
            if let barcodeDetail = parent.barcodeList.first(where: { $0.Barcode == barcode }) {
                let status = barcodeDetail.StatusId
                if parent.isRead(status) {
                    return .green
                } else if parent.isReading(status) {
                    return .yellow
                } else {
                    return .red
                }
            }
            return .red
        }

        public func clearBorders() {
            borderLayers.values.forEach { $0.removeFromSuperlayer() }
            borderLayers.removeAll()
        }

        public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard parent.isScanning else { return }
            guard let previewLayer = previewLayer else { return }

            var visibleCodes: Set<String> = []

            for metadata in metadataObjects {
                guard let readableObject = metadata as? AVMetadataMachineReadableCodeObject,
                      let stringValue = readableObject.stringValue,
                      let transformedObject = previewLayer.transformedMetadataObject(for: readableObject) else {
                    continue
                }

                visibleCodes.insert(stringValue)

                if let existingLayer = borderLayers[stringValue] {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    existingLayer.path = UIBezierPath(rect: transformedObject.bounds).cgPath
                    if parent.barcodeColor {
                        existingLayer.strokeColor = getBorderColor(for: stringValue).cgColor
                    }
                    CATransaction.commit()
                } else {
                    let boxLayer = CAShapeLayer()
                    boxLayer.path = UIBezierPath(rect: transformedObject.bounds).cgPath
                    boxLayer.strokeColor = getBorderColor(for: stringValue).cgColor
                    boxLayer.lineWidth = 2.0
                    boxLayer.fillColor = UIColor.clear.cgColor

                    previewLayer.addSublayer(boxLayer)
                    borderLayers[stringValue] = boxLayer

                    if parent.allowMultipleCodes {
                        if !scannedCodes.contains(stringValue) {
                            scannedCodes.insert(stringValue)
                            parent.didFindCode(stringValue)
                        }
                    } else {
                        parent.didFindCode(stringValue)
                        parent.isScanning = false
                        break
                    }
                }
            }

            let codesToRemove = borderLayers.keys.filter { !visibleCodes.contains($0) }
            for code in codesToRemove {
                borderLayers[code]?.removeFromSuperlayer()
                borderLayers.removeValue(forKey: code)
            }
        }

        // MARK: Flash and Camera Switch
        @objc public func didTapTorch() {
            toggleTorch()
        }

        public func toggleTorch() {
            guard let device = currentDeviceInput?.device, device.hasTorch else { return }
            do {
                try device.lockForConfiguration()
                device.torchMode = isTorchOn ? .off : .on
                isTorchOn.toggle()
                device.unlockForConfiguration()
                
                if let torchButton = previewLayer?.superlayer?.delegate as? UIViewController,
                   let button = torchButton.view.viewWithTag(101) as? UIButton {
                    let image = UIImage(systemName: "flashlight.on.fill")?.withRenderingMode(.alwaysTemplate)
                    button.setImage(image, for: .normal)
                    button.tintColor = isTorchOn ? .yellow : .white
                }
            } catch {
                print("Torch error: \(error)")
            }
        }

        @objc public func didTapSwitchCamera() {
            switchCamera()
        }

        public func switchCamera() {
            guard let session = captureSession, let currentInput = currentDeviceInput else { return }

            session.beginConfiguration()
            session.removeInput(currentInput)

            let newPosition: AVCaptureDevice.Position = (currentInput.device.position == .back) ? .front : .back
            guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
                session.commitConfiguration()
                return
            }

            do {
                let newInput = try AVCaptureDeviceInput(device: newDevice)
                if session.canAddInput(newInput) {
                    session.addInput(newInput)
                    currentDeviceInput = newInput
                    
                    if let switchButtonContainer = previewLayer?.superlayer?.delegate as? UIViewController,
                       let button = switchButtonContainer.view.viewWithTag(102) as? UIButton {
                        let image = UIImage(systemName: "camera.rotate")?.withRenderingMode(.alwaysTemplate)
                        button.setImage(image, for: .normal)
                        let isFront = newPosition == .front
                        button.tintColor = isFront ? .systemBlue : .white
                    }
                }
            } catch {
                print("Switch camera error: \(error)")
            }

            session.commitConfiguration()
        }
        
        public func updateScanningUI() {
            DispatchQueue.main.async {
                self.previewLayer?.isHidden = !self.parent.isScanning
                self.instructionLabel?.isHidden = self.parent.isScanning
            }
        }
        
        @objc public func toggleScan() {
            DispatchQueue.main.async {
                self.parent.isReadText.toggle()  // Bu, dışarıdaki bağlı değişkeni günceller
                print("T button clicked, isReadText: \(self.parent.isReadText)")
            }
        }
        
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let session = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.code128, .qr]
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.25)
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        context.coordinator.captureSession = session
        context.coordinator.currentDeviceInput = videoInput
        
        let instructionLabel = UILabel()
        instructionLabel.text = "Barkod okutmak için basılı tutunuz"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.boldSystemFont(ofSize: 16)
        instructionLabel.textAlignment = .center
        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        instructionLabel.frame = previewLayer.frame
        instructionLabel.isHidden = isScanning
        context.coordinator.instructionLabel = instructionLabel
        viewController.view.addSubview(instructionLabel)

        // Flash button
        let torchImage = UIImage(systemName: "flashlight.on.fill")?.withRenderingMode(.alwaysTemplate)
        let torchButton = UIButton(type: .system)
        torchButton.setImage(torchImage, for: .normal)
        torchButton.tintColor = context.coordinator.isTorchOn ? .yellow : .white
        torchButton.backgroundColor = UIColor.black
        torchButton.layer.cornerRadius = 25
        torchButton.clipsToBounds = true
        torchButton.frame = CGRect(x: 20, y: previewLayer.frame.height - 60, width: 50, height: 50)
        torchButton.addTarget(context.coordinator, action: #selector(context.coordinator.didTapTorch), for: .touchUpInside)
        torchButton.tag = 101
        viewController.view.addSubview(torchButton)

        // Switch camera button
        let switchCameraButton = UIButton(type: .system)
        let cameraImage = UIImage(systemName: "camera.rotate")?.withRenderingMode(.alwaysTemplate)
        switchCameraButton.setImage(cameraImage, for: .normal)
        let isFront = context.coordinator.currentDeviceInput?.device.position == .front
        switchCameraButton.tintColor = isFront ? .systemBlue : .white
        switchCameraButton.backgroundColor = UIColor.black
        switchCameraButton.layer.cornerRadius = 25
        switchCameraButton.clipsToBounds = true
        switchCameraButton.frame = CGRect(x: 80, y: previewLayer.frame.height - 60, width: 50, height: 50)
        switchCameraButton.addTarget(context.coordinator, action: #selector(context.coordinator.didTapSwitchCamera), for: .touchUpInside)
        switchCameraButton.tag = 102
        viewController.view.addSubview(switchCameraButton)
        
        let tButton = UIButton(type: .system)
        let tImage = UIImage(systemName: "t.square")?.withRenderingMode(.alwaysTemplate)
        tButton.setImage(tImage, for: .normal)
        tButton.tintColor = .white
        tButton.backgroundColor = .black
        tButton.layer.cornerRadius = 25
        tButton.clipsToBounds = true
        tButton.frame = CGRect(x: UIScreen.main.bounds.width - 70, y: previewLayer.frame.height - 60, width: 50, height: 50)
        tButton.addTarget(context.coordinator, action: #selector(context.coordinator.toggleScan), for: .touchUpInside)
        viewController.view.addSubview(tButton)
        
        DispatchQueue.global(qos: .default).async {
            session.startRunning()
        }

        return viewController
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.updateScanningUI()
        print("isScanning: \(self.isScanning), isReadText: \(self.isReadText)")
    }
}


public class SoundPlayer {
    private static var audioPlayer: AVAudioPlayer?

    public static func playSound(named soundName: String, ofType type: String = "mp3") {
        guard let path = Bundle.main.path(forResource: soundName, ofType: type) else {
            print("🔊 Sound file not found: \(soundName).\(type)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("🔊 Failed to play sound: \(error.localizedDescription)")
        }
    }
}
