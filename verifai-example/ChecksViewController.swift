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
        // Push the result to the DocumentDetailsTableViewController
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "documentDetails") as! DocumentDetailsTableViewController
        destination.result = result
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    @IBAction func handleLivenessCheckButton() {
        // Push the result to the DocumentDetailsTableViewController
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "documentDetails") as! DocumentDetailsTableViewController
        destination.result = result
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    @IBAction func handleManualDataCrosscheckButton() {
        // Push the result to the DocumentDetailsTableViewController
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "documentDetails") as! DocumentDetailsTableViewController
        destination.result = result
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    @IBAction func handleManualSecurityFeatureButton() {
        // Push the result to the DocumentDetailsTableViewController
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "documentDetails") as! DocumentDetailsTableViewController
        destination.result = result
        self.navigationController?.pushViewController(destination, animated: true)
    }


}
