//
//  Taxis+CoreDataProperties.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData


extension Taxis {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Taxis> {
        return NSFetchRequest<Taxis>(entityName: "Taxis")
    }

    @NSManaged public var address: String?
    @NSManaged public var stationName: String?
    @NSManaged public var zipCode: String?

}
