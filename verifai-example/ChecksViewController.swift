//
//  ChecksViewController.swift
//  verifai-example
//
//  Created by Richard Chirino on 17/09/2019.
//  Copyright © 2019 Gert-Jan van Ginkel. All rights reserved.
//

import UIKit
import Verifai
import VerifaiCommons
import VerifaiNFC
import VerifaiLiveness
import VerifaiManualDataCrosscheck
import VerifaiManualSecurityFeatureCheck

class ChecksViewController: UIViewController {
    
    @IBOutlet var nfcButton: UIButton!

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
    }
    
    // MARK: - Button actions
    
    @IBAction func handleShowScanResults() {
        // Push the result to the DocumentDetailsTableViewController
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "documentDetails") as! DocumentDetailsTableViewController
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
            try VerifaiNFC.start(over: self, documentData: result, retrieveImage: true) { nfcScanResult in
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
            print("🚫 Licence error: \(error)")
        }
    }
    
    @IBAction func handleLivenessCheckButton() {
        // Start the VerifaiLiveness component
        do {
            let outputDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("VerifaiLiveness/")
            if FileManager.default.fileExists(atPath: outputDirectory.path) {
                try FileManager.default.removeItem(at: outputDirectory)
            }
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
            let preferredLanguage = Locale.preferredLanguages.first ?? "en-US"
            let locale = Locale(identifier: preferredLanguage)
            try VerifaiLiveness.start(over: self, requirements: VerifaiLiveness.defaultRequirements(for: locale), videoLocation: outputDirectory) { (livenessScanResult) in
                switch livenessScanResult {
                case .failure(let error):
                print("Error: \(error)")
                case .success(let livenessResult):
                    // Show result
                    self.showAlert(msg: "All checks done?\n\n\(livenessResult.automaticChecksPassed)")
                }
            }
        } catch {
            print("🚫 Licence error: \(error)")
        }
    }
    
    @IBAction func handleManualDataCrosscheckButton() {
        // Guarantee we have a result
        guard let result = result else {
            return
        }
        // Start the Manual data crosscheck component
        do {
            try VerifaiManualDataCrosscheck.start(over: self,
                                                  documentData: result,
                                                  nfcImage: nfcImage) { manualDataCrosscheckScanResult  in
                                                    // Handle result
                                                    switch manualDataCrosscheckScanResult {
                                                    case .success(let checkResult):
                                                        // Show result
                                                        self.showAlert(msg: "All checks passed?\n\n\(checkResult.passedAll)")
                                                    case .failure(let error):
                                                        print("Error: \(error)")
                                                    }
            }
        } catch {
            print("🚫 Licence error: \(error)")
        }
    }
    
    @IBAction func handleManualSecurityFeatureButton() {
        // Guarantee we have a result
        guard let result = result else {
            return
        }
        // Start the Manual security feature check component
        do {
            try VerifaiManualSecurityFeatureCheck.start(over: self,
                                                        documentData: result) { msfcResult in
                switch msfcResult {
                case .failure(let error):
                    print("Error: \(error)")
                case .success(let checkResult):
                    // Show result
                    self.showAlert(msg: "Check passed?\n\n\(checkResult.passed)")
                }
            }
        } catch {
            print("🚫 Licence error: \(error)")
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
