//
//  DocumentDetailsTableViewController.swift
//  verifai-example
//
//  Created by Gert-Jan van Ginkel on 26/06/2018.
//  Copyright © 2018 Gert-Jan van Ginkel. All rights reserved.
//

import UIKit
import Verifai

class DocumentDetailsTableViewController: UITableViewController {
    
    // Cell details
    @IBOutlet weak var documentTypeLabel: UILabel!
    @IBOutlet weak var issuingCountryLabel: UILabel!
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
    var document: VerifaiResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign all data that was detected to the text fields
        documentTypeLabel.text = document?.documentType!.rawValue
        issuingCountryLabel.text = document?.issuingCountryString
        countryCodeLabel.text = document?.mrzModel?.countryCode
        lastNameLabel.text = document?.mrzModel?.lastName
        firstNameLabel.text = document?.mrzModel?.firstName
        sexLabel.text = document?.mrzModel?.gender
        nationalityLabel.text = document?.mrzModel?.nationality
        dateOfBirthLabel.text = document?.mrzModel?.dateOfBirth?.mediumFormattedString
        personalNumberLabel.text = document?.mrzModel?.personalNumber
        documentNumberLabel.text = document?.mrzModel?.documentNumber
        expirationDateLabel.text = document?.mrzModel?.dateOfExpiry?.mediumFormattedString
    }
}

// Small extension to make getting a formatted string just a little easier
extension Date {
    fileprivate var mediumFormattedString: String {
        return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
    }
}
