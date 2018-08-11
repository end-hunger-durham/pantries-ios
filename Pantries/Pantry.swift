//
//  Pantry.swift
//  Pantries
//
//  Created by Josh Johnson on 6/9/18.
//  Copyright © 2018 End Hunger Durham. All rights reserved.
//

import UIKit
import MapKit

class Pantry {
    
    var address: String?
    var city: String?
    var days: String?
    var hours: String?
    var info: String?
    var organization: String?
    var phone: String?
    var prereq: String?
    var latitude: Double?
    var longitude: Double?
    
    var image: UIImage?
    var snapshotter: MKMapSnapshotter?
    
    // todo cheating a distance for demo
    var distance = Double.greatestFiniteMagnitude
    
}
