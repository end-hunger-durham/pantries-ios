//
//  ViewController.swift
//  Pantries
//
//  Created by Josh Johnson on 6/9/18.
//  Copyright © 2018 End Hunger Durham. All rights reserved.
//

import UIKit
import MapKit

class ListViewController: UIViewController {
    fileprivate let cellIdentifier = "PantryTableViewCell"

    @IBOutlet private weak var tableView: UITableView!

    private let locationManager = CLLocationManager()
    private lazy var pantryStore: PantryStore? = {
        return PantryStore()
    }()
    
    fileprivate var pantries = [Pantry]()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        internalConfigure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalConfigure()
    }
    
    private func internalConfigure() {
        tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "icon_list_tab"), selectedImage: nil)
        title = NSLocalizedString("tab_item_list", comment: "Title of the tab item for list")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = 66.0
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_nearby"), style: .plain, target: self, action: #selector(beginSortByClosest))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        fetchPantries()
        requestLocationPermission()
    }

    private func fetchPantries() {
        pantryStore?.fetchPantries { pantries in
            self.pantries = pantries
            self.tableView.reloadData()
        }
    }
    
    fileprivate func imageForPantry(at path: IndexPath) -> UIImage? {
        let pantry = pantries[path.row]
        
        if let image = pantry.image {
            return image
        } else if pantry.snapshotter == nil {
            if let latitude = pantry.latitude, let longitude = pantry.longitude {
                let options = MKMapSnapshotOptions()
                let location = CLLocationCoordinate2DMake(latitude, longitude)
                let region = MKCoordinateRegionMakeWithDistance(location, 3000, 3000)
                options.region = region
                options.scale = UIScreen.main.scale
                options.size = CGSize(width: 50.0, height: 50.0)
                options.showsBuildings = true
                options.showsPointsOfInterest = true
                
                let snapshotter = MKMapSnapshotter(options: options)
                pantry.snapshotter = snapshotter
                
                snapshotter.start { snapshot, error in
                    pantry.image = snapshot?.image
                    pantry.snapshotter = nil
                    
                    UIView.performWithoutAnimation {
                        self.tableView.reloadRows(at: [path], with: .none)
                    }
                }
            }
        }
        
        return nil
    }
    
    private func requestLocationPermission() {
        locationManager.delegate = self

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            navigationItem.rightBarButtonItem?.isEnabled = false
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            navigationItem.rightBarButtonItem?.isEnabled = true
            break
        }
    }
    
    @objc private func beginSortByClosest() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }
    
    private func sortPantriesNearest(_ coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        var unsortedPantries = [Pantry]()
        for pantry in pantries {
            if let latitude = pantry.latitude, let longitude = pantry.longitude {
                let pantryLocation = CLLocation(latitude: latitude, longitude: longitude)
                pantry.distance = pantryLocation.distance(from: location)
            }
            unsortedPantries.append(pantry)
        }
        
        pantries = unsortedPantries.sorted(by: { lhs, rhs -> Bool in
            return lhs.distance < rhs.distance
        })
        
        tableView.reloadData()
    }
    
}

extension ListViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            navigationItem.rightBarButtonItem?.isEnabled = false
            break
            
        case .authorizedWhenInUse:
            navigationItem.rightBarButtonItem?.isEnabled = true
            break
            
        case .notDetermined, .authorizedAlways:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
            location.horizontalAccuracy <= kCLLocationAccuracyHundredMeters else { return }
        
        sortPantriesNearest(location.coordinate)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed obtaining location: \(error.localizedDescription)")
    }
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pantries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let pantryCell = cell as? PantryTableViewCell else { return }
        
        let pantry = pantries[indexPath.row]
        
        pantryCell.nameLabel?.text = pantry.organization ?? "<unknown>"
        
        if let days = pantry.days, let hours = pantry.hours {
            pantryCell.availabilityLabel?.text = "\(days), \(hours)"
        } else {
            pantryCell.availabilityLabel?.text = "Call for details"
        }
        
        pantryCell.mapImageView?.image = imageForPantry(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let pantry = pantries[indexPath.row]
        show(PantryDetailViewController(for: pantry), sender: nil)
    }
    
}

