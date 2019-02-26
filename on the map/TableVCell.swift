//
//  TableVCell.swift
//  on the map
//
//  Created by reem katmeh on 28/02/2019
//  Copyright © 2019 reemkt. All rights reserved.
//

import Foundation
import UIKit


class TableVCell :  UITableViewCell {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var mediaURL: UILabel!
    
    var locationData: StudentLocation? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        fullNameLabel.text = "\(locationData?.firstName ?? " ") \(locationData?.lastName ?? " ")"
        mediaURL.text = "\(locationData?.mediaURL ?? " ")"
    }
}
