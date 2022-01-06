//
//  VisualInspectionTableViewController.swift
//  verifai-example
//
//  Created by Richard Chirino on 29/11/2021.
//  Copyright © 2021 Gert-Jan van Ginkel. All rights reserved.
//

import UIKit
import VerifaiCommonsKit

class VisualInspectionTableViewController: UITableViewController {
    
    /// The result data
    var frontVisualInspectionResult: VerifaiVisualInspectionZoneResult?
    var backVisualInspectionResult: VerifaiVisualInspectionZoneResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Visual inspection results"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var amountOfSections = 0
        // Add a section for the front if we have it
        if frontVisualInspectionResult != nil {
            amountOfSections += 1
        }
        // Add a section for the back if we have it
        if backVisualInspectionResult != nil {
            amountOfSections += 1
        }
        return amountOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Visual data on the frontside"
        case 1:
            return "Visual data on the back side"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return frontVisualInspectionResult?.count ?? 0
        case 1:
            return backVisualInspectionResult?.count ?? 0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return getCell(tableView: tableView, indexPath: indexPath, resultObject: frontVisualInspectionResult)
        case 1:
            return getCell(tableView: tableView, indexPath: indexPath, resultObject: backVisualInspectionResult)
        default:
            return UITableViewCell()
        }
    }
    
    /// Get the cell with it's filled in content
    /// - Parameters:
    ///   - tableView: The tableview being populated
    ///   - indexPath: The current index path
    ///   - resultObject: The result object with the data for this section
    /// - Returns: A populated cell with the visual inspection info
    private func getCell(tableView: UITableView,
                         indexPath: IndexPath,
                         resultObject: VerifaiVisualInspectionZoneResult?) -> UITableViewCell {
        let identifier = "UITableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            // Make the cell
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }
        // Populate it
        populate(cell: cell, indexPath: indexPath, resultObject: resultObject)
        return cell ?? UITableViewCell()
    }
    
    /// Populate the data from the data objects onto the cell
    /// - Parameters:
    ///   - cell: The cell to populate
    ///   - indexPath: The current index path of the section and cell
    ///   - resultObject: The result object with the data for this section
    private func populate(cell: UITableViewCell?,
                          indexPath: IndexPath,
                          resultObject: VerifaiVisualInspectionZoneResult?) {
        // Data setup
        let keys = resultObject?.compactMap { $0.key }
        let values = resultObject?.compactMap { $0.value }
        // Get content configuration
        if #available(iOS 14.0, *) {
            var content = UIListContentConfiguration.subtitleCell()
            // Set the values
            content.text = keys?[indexPath.row]
            content.secondaryText = values?[indexPath.row]
            cell?.contentConfiguration = content
        } else {
            // Fallback on earlier versions
            cell?.textLabel?.text = keys?[indexPath.row]
            cell?.detailTextLabel?.text = values?[indexPath.row]
        }
    }
}
