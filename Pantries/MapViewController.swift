//
//  MapViewController.swift
//  Pantries
//
//  Created by Josh Johnson on 7/10/18.
//  Copyright © 2018 End Hunger Durham. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet fileprivate weak var mapView: MKMapView!
    
    fileprivate var pantries = [Pantry]()
    private lazy var pantryStore: PantryStore? = {
        return PantryStore()
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        internalConfigure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalConfigure()
    }
    
    private func internalConfigure() {
        tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "icon_map_tab"), selectedImage: nil)
        title = NSLocalizedString("tab_item_map", comment: "Title of the tab item for maps")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        fetchPantries()
    }
    
    private func fetchPantries() {
        pantryStore?.fetchPantries { pantries in
            self.pantries = pantries
            
            for pantry in pantries {
                self.mapView.addAnnotation(PantryAnnotation(pantry: pantry))
            }

            // starting in durham, because … prototyping
            self.mapView.camera.centerCoordinate = CLLocationCoordinate2D(latitude: 35.996543666002445, longitude: -78.90108037808307)
            self.mapView.camera.altitude = 10000
        }
    }

}

extension MapViewController : MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PantryAnnotation else { return nil }

        let marker = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
//        marker.glyphImage = #imageLiteral(resourceName: "icon_food")
        
        return marker
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? PantryAnnotation else { return }

        show(PantryDetailViewController(for: annotation.pantry), sender: nil)
    }
    
}

class PantryAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    let pantry: Pantry
    
    init(pantry: Pantry) {
        self.pantry = pantry
        
        if let latitude = pantry.latitude, let longitude = pantry.longitude {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            coordinate = CLLocationCoordinate2D(latitude: 35.996543666002445, longitude: -78.90108037808307)
        }
        
        super.init()
    }
    
}


