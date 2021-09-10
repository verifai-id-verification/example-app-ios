//
//  ViewController.swift
//  verifai-example
//
//  Created by Gert-Jan van Ginkel on 26/06/2018.
//  Copyright © 2018 Gert-Jan van Ginkel. All rights reserved.
//

import UIKit
import Verifai
import VerifaiCommons
import AVFoundation

class MainViewController: UIViewController {
    
    // MARK: - View lifecycle methods
    
    override func viewDidLoad() {
        // Make sure we have access to the camera
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            AVCaptureDevice.requestAccess(for: .video) { _ in }
        }
        
        var licenceString: String
        
        // Read the license key out of a file
        do {
            let licencePath = Bundle.main.path(forResource: "licencefile", ofType: "txt")
            let licenceURL = URL(fileURLWithPath: licencePath!)
            licenceString = try String(contentsOf: licenceURL, encoding: .utf8)
        } catch {
            // We just crash when we cannot load the licence
            fatalError("🚫 Unable to load licence")
        }
        
        // Start configuring Verifai
        // Setup the licence
        switch VerifaiCommons.setLicence(licenceString) {
            case .success(_):
                print("Successfully configured Verifai")
            case .failure(let error):
                print("🚫 Licence error: \(error)")
        }
        // You can customise configuration items like this
        let configuration = VerifaiConfiguration(enableAutomatic: false,
                                                 requireDocumentCopy: true,
                                                 requireCroppedImage: false,
                                                 enablePostCropping: true,
                                                 enableManual: true,
                                                 enableAutoUpdate: true,
                                                 requireMRZContents: true,
                                                 readMRZContents: true,
                                                 requireNFCWhenAvailable: true,
                                                 validators: [])
        // Instruction screen configuration
        configuration.instructionScreenConfiguration =
            try! VerifaiInstructionScreenConfiguration(showInstructionScreens: true,
                                                       instructionScreens: [:])
        try? Verifai.configure(with: configuration)
    }
    
    // MARK: - Verifai interaction
    
    /// Starts Verifai
    func showVerifaiController() {
        // Create a new ScanViewController and provide a block that presents the given viewController
        do {
            try Verifai.start(over: self) { result in
                switch result {
                case .failure(let error):
                    print("Error: \(error)")
                case .success(let result):
                    // Show the available checks on this device
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    if let destination = storyboard.instantiateViewController(withIdentifier: "checksOverview") as? ChecksViewController {
                        destination.result = result
                        self.navigationController?.pushViewController(destination, animated: true)
                    }
                }
            }
        } catch {
            print("🚫 Licence error: \(error)")
        }
    }
    
    // MARK: - Button handlers
    
    @IBAction func handleAutomaticScan(_ sender: UIButton) {
        showVerifaiController()
    }
}

