//
//  ScanImagesViewController.swift
//  verifai-example
//
//  Created by Richard Chirino on 29/09/2020.
//  Copyright © 2020 Gert-Jan van Ginkel. All rights reserved.
//

import UIKit
import VerifaiCommonsKit

class ScanImagesViewController: UIViewController {

    @IBOutlet var frontImageView: UIImageView!
    @IBOutlet var backImageView: UIImageView!
    
    /// The document result being shown
    var result: VerifaiResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scan result images"
        frontImageView.image = result?.frontImage
        backImageView.image = result?.backImage

    }

}
