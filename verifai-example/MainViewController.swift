//
//  ViewController.swift
//  verifai-example
//
//  Created by Gert-Jan van Ginkel on 26/06/2018.
//  Copyright © 2018 Gert-Jan van Ginkel. All rights reserved.
//

import UIKit
import Verifai
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
        // We have to pass our bundle identifier along with the license key to activate Verifai
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            let configureResponse = Verifai.configure(licence: licenceString, identifier: bundleIdentifier)
            // Assign an success block
            configureResponse.success() { _ in
                print("Successfully configured Verifai")
            }
            // And an error block
            configureResponse.error() { error in
                print(error.description)
            }
        }
    }
    
    /// Shows an error in an AlertController
    ///
    /// - Parameter error: the message to present
    func showVerifaiError(error: VerifaiMessage?) {
        let errorDescription = error?.description ?? "Unknown error"
        
        let alertController = UIAlertController(title: "Verifai Error",
                                                message: errorDescription,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss",
                                                style: .cancel,
                                                handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Verifai interaction
    
    private func loadLocalModel() {
        // Get the URL for the local model package
        let url = Bundle.main.url(forResource: "Set_9_CoreML", withExtension: "package")
        // Load local model
        let responseBlock = Verifai.setNeuralModel(modelPath: url!)
        // Pass the new responseBlock to our handler
        handleLoadModelsResponseBlock(responseBlock)
    }
    
    // Load online models, these will get downloaded
    private func loadOnlineModels() {
        // Start downloading the neural models
        let responseBlock = Verifai.downloadNeuralModels(for: ["NL"])
        // Pass the new responseBlock to our handler
        handleLoadModelsResponseBlock(responseBlock)
    }
    
    // Handles a VerifaiResponseoBlock
    private func handleLoadModelsResponseBlock(_ block: VerifaiResponseBlock<Void>) {
        // Create an alertController to notify the user we are loading the models
        let alertController = UIAlertController(title: "Loading models",
                                                message: nil,
                                                preferredStyle: .alert)
        // We also want to allow the user to cancel loading the models in case their device is slow, they don't want to etc.
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { _ in
                                            // Cancel all requests that Verifai is making
                                            Verifai.cancelAllRequests()
        }
        alertController.addAction(cancelAction)
        
        // Verifai will notify us of the progress it makes when loading the models, so we create a UIProgressView
        // to relay this information to the user
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.frame = CGRect(x: 10, y: 50, width: 250, height: 0)
        alertController.view.addSubview(progressView)
        self.present(alertController, animated: true, completion: nil)
        
        // Create a progress handling block
        block.progress() { progress in
            DispatchQueue.main.async {
                progressView.progress = Float(progress) / 100.0
            }
        }
        // Create the error block that will show the error in an alert
        block.error() { (message: VerifaiMessage) -> Void in
            DispatchQueue.main.async {
                alertController.dismiss(animated: true) {
                    DispatchQueue.main.async {
                        self.showVerifaiError(error: message)
                    }
                }
            }
        }
        // Just print any additional info to console
        block.info() { (message: VerifaiMessage) -> Void in
            print(message.description)
        }
        // Block that gets executed when the task is completed
        block.success() { _ in
            DispatchQueue.main.async {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /// Pushes a new Verifai ScanViewController with the given scanMode onto the stack
    ///
    /// - Parameter scanMode: the mode for the ScanViewController
    func pushVerifaiController(scanMode: VerifaiScanMode) {
        // Create a new ScanViewController and provide a block that presents the given viewController
        let responseBlock = Verifai.scanViewController(scanMode: scanMode) { vc in
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        // Assign a block that gets executed when an error occurs
        responseBlock.error() { error in
            DispatchQueue.main.async {
                self.showVerifaiError(error: error)
            }
        }
        // Assign a block that gets executed when the task is completed
        responseBlock.success() { response in
            // Pop back the navigationController to self
            self.navigationController?.popToViewController(self, animated: true)
            
            // response is of type VerifaiResponse?, so make sure it's not nil
            guard let response = response else { return }
            
            // Verifai detected a document!
            print("Document found: \(response)")
            // Push the document to the DocumentDetailsTableViewController
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let destination = storyboard.instantiateViewController(withIdentifier: "documentDetails") as! DocumentDetailsTableViewController
            destination.document = response
            self.navigationController?.pushViewController(destination, animated: true)
        }
    }
    
    // MARK: - Button handlers
    
    @IBAction func handleAutomaticScan(_ sender: UIButton) {
        pushVerifaiController(scanMode: .ai)
    }
    
    @IBAction func handleManualScan(_ sender: UIButton) {
        pushVerifaiController(scanMode: .manual)
    }

    @IBAction func handleDownloadNeuralModels(_ sender: UIButton) {
        loadOnlineModels()
    }
    
    @IBAction func handleSetLocalModels(_ sender: UIButton) {
        loadLocalModel()
    }
    
    
}

