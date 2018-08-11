//
//  PantryStore.swift
//  Pantries
//
//  Created by Josh Johnson on 7/10/18.
//  Copyright © 2018 End Hunger Durham. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PantryStore: NSObject {
    private var reference: DatabaseReference?
    
    fileprivate var pantries = [Pantry]()
    
    override init() {
        super.init()
        
        reference = Database.database().reference()
    }
    
    func fetchPantries(_ completion: (([Pantry]) -> Void)?) {
        reference?.child("pantries").observeSingleEvent(of: .value) { snapshot in
            self.loadPantries(from: snapshot, completion)
        }
    }
    
    private func loadPantries(from snapshot: DataSnapshot, _ completion: (([Pantry]) -> Void)?) {
        for item in snapshot.children {
            guard let item = item as? DataSnapshot,
                let value = item.value as? NSDictionary else { continue }
            
            let dict = value as! [String : Any]
            let pantry = Pantry()
            pantry.address = dict["address"] as? String
            pantry.city = dict["city"] as? String
            pantry.days = dict["days"] as? String
            pantry.hours = dict["hours"] as? String
            pantry.info = dict["info"] as? String
            pantry.organization = dict["organizations"] as? String
            pantry.phone = dict["phone"] as? String
            pantry.prereq = dict["prereq"] as? String
            pantry.latitude = dict["latitude"] as? Double
            pantry.longitude = dict["longitude"] as? Double
            pantries.append(pantry)
        }
        
        completion?(pantries)
    }

}
