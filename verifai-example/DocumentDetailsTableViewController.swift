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
    @IBOutlet var documentTypeLabel: UILabel!
    @IBOutlet var countryCodeLabel: UILabel!
    @IBOutlet var lastNameLabel: UILabel!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var sexLabel: UILabel!
    @IBOutlet var nationalityLabel: UILabel!
    @IBOutlet var dateOfBirthLabel: UILabel!
    @IBOutlet var personalNumberLabel: UILabel!
    @IBOutlet var documentNumberLabel: UILabel!
    @IBOutlet var expirationDateLabel: UILabel!
    
    /// The document being shown
    var result: VerifaiResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign all data that was detected to the text fields
        documentTypeLabel.text = result?.idModel?.type
        countryCodeLabel.text = result?.mrzData?.countryCode
        lastNameLabel.text = result?.mrzData?.surname
        firstNameLabel.text = result?.mrzData?.givenNames
        sexLabel.text = result?.mrzData?.sex
        nationalityLabel.text = result?.mrzData?.nationality
        dateOfBirthLabel.text = result?.mrzData?.parsedDateOfBirth?.mediumFormattedString
        personalNumberLabel.text = result?.mrzData?.optionalData
        documentNumberLabel.text = result?.mrzData?.documentNumber
        expirationDateLabel.text = result?.mrzData?.parsedDateOfExpiry?.mediumFormattedString
    }
}

// Small extension to make getting a formatted string just a little easier
extension Date {
    fileprivate var mediumFormattedString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
    }
}
