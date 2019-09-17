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
    var nfcResult: VerifaiNFCResult?
    var livenessResult: VerifaiLivenessCheckResults?
    var manualDataCrosscheck: VerifaiManualDataCrosscheckResult?
    
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
        self.navigationController?.pushViewController(destination, animated: true)
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
                    // Set result
                    self.nfcResult = nfcResult
                }
            }
        } catch {
            print("🚫 Licence error: \(error)")
        }
    }
    
    @IBAction func handleLivenessCheckButton() {
        // Start the VerifaiLiveness component
        do {
            try VerifaiLiveness.start(over: self) { (livenessScanResult) in
                switch livenessScanResult {
                case .failure(let error):
                print("Error: \(error)")
                case .success(let livenessResult):
                    // Set the result
                    self.livenessResult = livenessResult
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
                                                  nfcImage: nfcResult?.photo) { manualDataCrosscheckScanResult  in
                                                    // Handle result
                                                    switch manualDataCrosscheckScanResult {
                                                    case .success(let checkResult):
                                                        self.manualDataCrosscheck = checkResult
                                                    case .failure(let error):
                                                        print("Error: \(error)")
                                                    }
            }
        } catch {
            print("🚫 Licence error: \(error)")
        }
    }
    
    @IBAction func handleManualSecurityFeatureButton() {
        // Push the result to the DocumentDetailsTableViewController
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "documentDetails") as! DocumentDetailsTableViewController
        destination.result = result
        self.navigationController?.pushViewController(destination, animated: true)
    }
}
