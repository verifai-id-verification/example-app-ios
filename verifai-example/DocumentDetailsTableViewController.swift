//
//  DocumentDetailsTableViewController.swift
//  verifai-example
//
//  Created by Gert-Jan van Ginkel on 26/06/2018.
//  Copyright © 2018 Gert-Jan van Ginkel. All rights reserved.
//

import UIKit
import Verifai
import VerifaiCommons

class DocumentDetailsTableViewController: UITableViewController {
    
    // Cell details
    @IBOutlet weak var documentTypeLabel: UILabel!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var personalNumberLabel: UILabel!
    @IBOutlet weak var documentNumberLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    
    /// The document being shown
    var result: VerifaiResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign all data that was detected to the text fields
        documentTypeLabel.text = result?.idModel?.type
        countryCodeLabel.text = result?.mrzModel?.countryCode
        lastNameLabel.text = result?.mrzModel?.surname
        firstNameLabel.text = result?.mrzModel?.givenNames
        sexLabel.text = result?.mrzModel?.sex
        nationalityLabel.text = result?.mrzModel?.nationality
        dateOfBirthLabel.text = result?.mrzModel?.parsedDateOfBirth?.mediumFormattedString
        personalNumberLabel.text = result?.mrzModel?.optionalData
        documentNumberLabel.text = result?.mrzModel?.documentNumber
        expirationDateLabel.text = result?.mrzModel?.parsedDateOfExpiry?.mediumFormattedString
    }
}

// Small extension to make getting a formatted string just a little easier
extension Date {
    fileprivate var mediumFormattedString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
    }
}
