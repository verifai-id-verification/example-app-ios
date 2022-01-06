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
