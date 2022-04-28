//
//  ViewController.swift
//  verifai-example
//
//  Created by Gert-Jan van Ginkel on 26/06/2018.
//  Copyright © 2018 Gert-Jan van Ginkel. All rights reserved.
//

import UIKit
import VerifaiKit
import VerifaiCommonsKit
import AVFoundation

class MainViewController: UIViewController {
    
    // MARK: - View lifecycle methods
    
    override func viewDidLoad() {
        title = ""
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
        let configuration = VerifaiConfiguration(requireDocumentCopy: true,
                                                 requireCroppedImage: false,
                                                 enablePostCropping: true,
                                                 enableManual: true,
                                                 requireMRZContents: false,
                                                 readMRZContents: true,
                                                 requireNFCWhenAvailable: false,
                                                 validators: [])
        do {
            // Instruction screen configuration
//            configuration.instructionScreenConfiguration =
//                try VerifaiInstructionScreenConfiguration(showInstructionScreens: false,
//                                                          instructionScreens: [:])
            // Enable visual inspection feature 
            configuration.enableVisualInspection = true
            // Set the configuration in Verifai
            try Verifai.configure(with: configuration)
        } catch VerifaiConfigurationError.invalidConfiguration(let description) {
            print("Configuration error: \(description)")
        } catch {
            print("🚫 Unhandled error: \(error.localizedDescription)")
        }
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
            print("🚫 Unhandled error: \(error)")
        }
    }
    
    // MARK: - Button handlers
    
    @IBAction func handleAutomaticScan(_ sender: UIButton) {
        showVerifaiController()
    }
}

