//
//  PantryDetailViewController.swift
//  Pantries
//
//  Created by Josh Johnson on 6/9/18.
//  Copyright © 2018 End Hunger Durham. All rights reserved.
//

import UIKit
import MapKit

class PantryDetailViewController: UIViewController {
    
    enum PantryDetailCell {
        case mapCell(Double, Double)
        case textCell(String, String)
    }
    
    fileprivate let mapCellIdentifier = "MapTableViewCell"
    fileprivate let detailCellIdentifier = "TextDetailTableViewCell"

    fileprivate let pantryCells: [PantryDetailCell]
    
    @IBOutlet weak var detailTableView: UITableView!
    
    let pantry: Pantry
    
    init(for pantry: Pantry) {
        self.pantry = pantry
        
        var cells = [PantryDetailCell]()
        
        if let latitude = pantry.latitude, let longitude = pantry.longitude {
            cells.append(.mapCell(latitude, longitude))
        }
        
        if let address = pantry.address, let city = pantry.city {
            cells.append(.textCell(NSLocalizedString("item_detail_address", comment: "Title of field displaying address"), "\(address) \(city)"))
        }
        
        if let days = pantry.days, let hours = pantry.hours {
            cells.append(.textCell(NSLocalizedString("item_detail_available", comment: "Title of field displaying day and time available"), "\(days) \(hours)"))
        }

        if let prereq = pantry.prereq, prereq.count > 0 {
            cells.append(.textCell(NSLocalizedString("item_detail_prereqs", comment: "Title of field displaying requirements"), prereq))
        }
        
        if let info = pantry.info, info.count > 0 {
            cells.append(.textCell(NSLocalizedString("item_detail_info", comment: "Title of field displaying info"), info))
        }
        
        pantryCells = cells
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = pantry.organization
        
        detailTableView.register(UINib(nibName: mapCellIdentifier, bundle: nil), forCellReuseIdentifier: mapCellIdentifier)
        detailTableView.register(UINib(nibName: detailCellIdentifier, bundle: nil), forCellReuseIdentifier: detailCellIdentifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_phone_small"), style: .plain, target: self, action: #selector(callPhoneNumber))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        detailTableView.reloadData()
    }
    
    @objc func callPhoneNumber() {
        // TODO: Call number
    }

}

extension PantryDetailViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pantryCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pantryCells[indexPath.row]
        switch cell {
        case .mapCell(_, _): return tableView.dequeueReusableCell(withIdentifier: mapCellIdentifier, for: indexPath)
        case .textCell(_, _): return tableView.dequeueReusableCell(withIdentifier: detailCellIdentifier, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let pantryCell = pantryCells[indexPath.row]

        switch pantryCell {
        case .mapCell(let latitude, let longitude):
            guard let mapCell = cell as? MapTableViewCell else { return }
            
            mapCell.showMap(atLatitude: latitude, longitude: longitude)
            
        case .textCell(let title, let content):
            guard let textCell = cell as? TextDetailTableViewCell else { return }
            
            textCell.titleLabel.text = title
            textCell.contentLabel.text = content
            
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard indexPath.row == 1 else { return }
        guard let latitude = pantry.latitude, let longitude = pantry.longitude else { return }

        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = pantry.organization ?? "Pantry"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeTransit])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = pantryCells[indexPath.row]
        switch cell {
        case .mapCell(_, _): return 150.0
        case .textCell(_, _): return 60.0
        }
    }
    
}
