//
//  GCDBox.swift
//  on the map
//
//  Created by reem katmeh on 28/02/2019
//  Copyright © 2019 reemkt. All rights reserved.
//

import Foundation
import UIKit

// Perform updates on Main queue
func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

