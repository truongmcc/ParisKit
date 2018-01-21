//
//  Velib+CoreDataProperties.swift
//  swiftu
//
//  Created by picshertho on 02/10/2016.
//  Copyright © 2016 tru. All rights reserved.
//

import Foundation
import CoreData


extension Velib {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Velib> {
        return NSFetchRequest<Velib>(entityName: "Velib");
    }

    @NSManaged public var adress: String?
    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var number: Int16
    @NSManaged public var name: String?

}
