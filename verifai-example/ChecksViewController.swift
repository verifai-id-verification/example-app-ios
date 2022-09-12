//
//  ChecksViewController.swift
//  verifai-example
//
//  Created by Richard Chirino on 17/09/2019.
//  Copyright © 2019 Gert-Jan van Ginkel. All rights reserved.
//

import UIKit
import VerifaiKit
import VerifaiCommonsKit
import VerifaiNFCKit
import VerifaiLivenessKit

class ChecksViewController: UIViewController {
    
    @IBOutlet var nfcButton: UIButton!
    @IBOutlet var visualInspectionButton: UIButton!
    
    var result: VerifaiResult?
    var nfcImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Available checks"
        // Check if NFC is available and disable button if it isn't
        if !VerifaiNFC.nfcAvailable() {
            nfcButton.isEnabled = false
            nfcButton.setTitle("NFC scan (not available)", for: .disabled)
        }
        // Check if we have visual inspection results
        if result?.frontVisualInspectionZoneResult == nil &&
            result?.backVisualInspectionZoneResult == nil {
            visualInspectionButton.isEnabled = false
        }
    }
    
    // MARK: - Button actions
    
    @IBAction func handleShowScanResults() {
        // Push the result to the DocumentDetailsTableViewController
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "documentDetails") as! DocumentDetailsTableViewController
        destination.result = result
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @IBAction func handleShowVisualInspectionResults() {
        // Initialize the visual inspection VC
        let visualInspectionVC = VisualInspectionTableViewController()
        // Set the result objects
        visualInspectionVC.frontVisualInspectionResult = result?.frontVisualInspectionZoneResult
        visualInspectionVC.backVisualInspectionResult = result?.backVisualInspectionZoneResult
        navigationController?.pushViewController(visualInspectionVC, animated: true)
    }
    
    @IBAction func handleShowScanImages() {
        // Push the result to the DocumentDetailsTableViewController
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "scanImageResults") as! ScanImagesViewController
        destination.result = result
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @IBAction func handleNFCScanButton() {
        // Guarantee we have a result
        guard let result = result else {
            return
        }
        // Start the concurrency aware NFC scan
        Task { @MainActor in
            await startNFCScan(result:result)
        }
        // If you want to use the non concurrency aware way of starting the NFC scan you can call
        //startNFCBlock(result: result)
    }
    
    @IBAction func handleLivenessCheckButton() {
        // Start the VerifaiLiveness component
        do {
            // Setup the output directory where results will be kept
            let outputDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("VerifaiLiveness/")
            if FileManager.default.fileExists(atPath: outputDirectory.path) {
                try FileManager.default.removeItem(at: outputDirectory)
            }
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
            // Setup the requirement, we'll be using the default ones and add a face matching check
            let preferredLanguage = Locale.preferredLanguages.first ?? "en-US"
            let locale = Locale(identifier: preferredLanguage)
            var requirements = VerifaiLiveness.defaultRequirements(for: locale)
            // Determine which image to use for the face matching
            // You could use the front of the document with the face visible on the picture on it
            // Or if an NFC scanned has been performed we could use that image instead
            guard let documentImage = nfcImage ?? result?.frontImage else {
                return
            }
            // Add the face matching check
            let faceMatchingCheck = VerifaiFaceMatchingLivenessCheck(documentImage: documentImage)
            requirements.append(faceMatchingCheck)
            // Start a liveness check using the concurrency aware method
            Task { @MainActor in
                await startLivenessCheck(requirements: requirements,
                                         outputDirectory: outputDirectory)
            }
            // If you don't want to use concurrency aware methods then you can use the method below
            // Start the liveness check from a non concurrency aware context
            // startLivenessBlock(requirements: requirements, outputDirectory: outputDirectory)
        } catch {
            print("🚫 Error or cancellation: \(error)")
        }
    }
    
    // MARK: - NFC Starter functions
    
    /// Start the NFC scan in a non concurrency aware context
    /// - Parameter result: The result from the regular scan
    private func startNFCBlock(result: VerifaiResult) {
        // Start the NFC component
        do {
            try VerifaiNFC.start(over: self,
                                 documentData: result,
                                 retrieveImage: true,
                                 instructionScreenConfiguration: nil) { nfcScanResult in
                switch nfcScanResult {
                case .failure(let error):
                    print("Error: \(error)")
                case .success(let nfcResult):
                    // Set the image if retrieved
                    self.nfcImage = nfcResult.photo
                    // Show some data with an alert
                    self.showAlert(msg: "Authenticity: \(nfcResult.authenticity) \nOriginality: \(nfcResult.originality) \nConfidentiality: \(nfcResult.confidentiality)")
                }
            }
        } catch {
            print("🚫 Unhandled error: \(error)")
        }
    }
    
    /// Start the NFC scan through the concurrency aware start function
    /// - Parameter result: The result from the Core Verifai scan
    @available(iOS 13.0, *)
    @MainActor
    private func startNFCScan(result: VerifaiResult) async {
        // Start the NFC component
        do {
            let nfcResult = try await VerifaiNFC.start(over: self,
                                                       documentData: result,
                                                       retrieveImage: true)
            // Set the image if retrieved
            self.nfcImage = nfcResult.photo
            // Show some data with an alert
            self.showAlert(msg: "Authenticity: \(nfcResult.authenticity) \nOriginality: \(nfcResult.originality) \nConfidentiality: \(nfcResult.confidentiality)")
        } catch {
            print("🚫 Error or cancellation: \(error)")
        }
    }
    
    // MARK: - Liveness check starter functions
    
    /// Start the liveness check from a non concurrency aware context
    /// - Parameters:
    ///   - requirements: The requirements for the liveness check
    ///   - outputDirectory: The directory in which the video files of the liveness check are stored
    private func startLivenessBlock(requirements: [VerifaiLivenessCheck],
                                    outputDirectory: URL) {
        do {
            // Start the liveness check
            try VerifaiLiveness.start(over: self,
                                      requirements: requirements,
                                      resultOutputDirectory: outputDirectory) { livenessScanResult in
                switch livenessScanResult {
                case .failure(let error):
                    print("Error: \(error)")
                case .success(let livenessResult):
                    var resultText = "All checks done?\n\n\(livenessResult.automaticChecksPassed)"
                    // Print face matching result if available
                    if let faceMatchResult = livenessResult.resultList.first(where: { $0 is VerifaiFaceMatchingCheckResult }) as? VerifaiFaceMatchingCheckResult {
                        let confidence = faceMatchResult.confidence ?? 0.01
                        print("Face matches: \(faceMatchResult.matches ?? false)")
                        resultText += "\n\nFace matches: \(faceMatchResult.matches ?? false)"
                        resultText += "\n\nFace match: \(Double(confidence * 100).rounded())%"
                    }
                    // Show result
                    self.showAlert(msg: resultText)
                }
            }
        } catch {
            print("🚫 Unhandled error: \(error)")
        }
    }
    
    /// Start the Liveness check from a concurrency aware context
    /// - Parameters:
    ///   - requirements: The requirements for the liveness check
    ///   - outputDirectory: The directory in which the video files of the liveness check are stored
    @available(iOS 13.0, *)
    @MainActor
    private func startLivenessCheck(requirements: [VerifaiLivenessCheck],
                                    outputDirectory: URL) async {
        do {
            // Start the liveness check
            let livenessResult = try await VerifaiLiveness.start(over: self,
                                                                 requirements: requirements,
                                                                 resultOutputDirectory: outputDirectory)
            var resultText = "All checks done?\n\n\(livenessResult.automaticChecksPassed)"
            // Print face matching result if available
            if let faceMatchResult = livenessResult.resultList.first(where: { $0 is VerifaiFaceMatchingCheckResult }) as? VerifaiFaceMatchingCheckResult {
                let confidence = faceMatchResult.confidence ?? 0.01
                print("Face matches: \(faceMatchResult.matches ?? false)")
                resultText += "\n\nFace matches: \(faceMatchResult.matches ?? false)"
                resultText += "\n\nFace match: \(Double(confidence * 100).rounded())%"
            }
            // Show result
            self.showAlert(msg: resultText)
        } catch {
            print("🚫 Error or cancelled: \(error)")
        }
    }
    
    // MARK: - Alert message shower
    /// Show an alert message with a response
    /// - Parameter msg: The message to show inside of the alert message
    private func showAlert(msg: String) {
        let alert = UIAlertController(title: "Process completed",
                                      message: msg,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
