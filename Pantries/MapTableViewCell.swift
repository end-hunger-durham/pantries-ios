//
//  MapTableViewCell.swift
//  Pantries
//
//  Created by Josh Johnson on 6/9/18.
//  Copyright © 2018 End Hunger Durham. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapImageView: UIImageView!
    
    private var snapshotter: MKMapSnapshot?
        
    private func displayImageWithPin(from snapshot: MKMapSnapshot, at coordinate: CLLocationCoordinate2D) {
        let rect = mapImageView.bounds
        let size = CGSize(width: rect.width, height: rect.height)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            snapshot.image.draw(at: .zero)
            
            let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            let pinImage = pinView.image
            
            var point = snapshot.point(for: coordinate)
            
            if rect.contains(point) {
                let pinCenterOffset = pinView.centerOffset
                point.x -= pinView.bounds.size.width / 2
                point.y -= pinView.bounds.size.height / 2
                point.x += pinCenterOffset.x
                point.y += pinCenterOffset.y
                pinImage?.draw(at: point)
            }
        }
        
        mapImageView.image = image
    }
    
    func showMap(atLatitude latitude: Double, longitude: Double) {
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let options = MKMapSnapshotOptions()
        let region = MKCoordinateRegionMakeWithDistance(location, 5000, 5000)
        options.region = region
        options.scale = UIScreen.main.scale
        options.size = CGSize(width: UIScreen.main.bounds.width, height: mapImageView.bounds.height)
        options.showsBuildings = true
        options.showsPointsOfInterest = true
        
        let snapshotter = MKMapSnapshotter(options: options)
        
        snapshotter.start { snapshot, error in
            if let snapshot = snapshot {
                self.displayImageWithPin(from: snapshot, at: location)
            }
        }
    }
}
