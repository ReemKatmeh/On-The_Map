//
//  String+Date.swift
//  on the map
//
//  Created by reem katmeh on 28/02/2019
//  Copyright © 2019 reemkt. All rights reserved.
//

import Foundation


extension String {
    var toDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: self)
    }
}
