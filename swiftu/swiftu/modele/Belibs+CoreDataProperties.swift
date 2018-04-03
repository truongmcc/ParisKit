//
//  Belibs+CoreDataProperties.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData


extension Belibs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Belibs> {
        return NSFetchRequest<Belibs>(entityName: "Belibs")
    }

    @NSManaged public var aggregatedNbplugs: Int16
    @NSManaged public var geolocationPostalcode: String?
    @NSManaged public var geolocationRoute: String?
    @NSManaged public var geolocationStreetnumber: String?
    @NSManaged public var staticNbparkingspots: Int16
    @NSManaged public var staticNbstations: Int16
    @NSManaged public var staticOpening247: String?
    @NSManaged public var statusAvailable: String?

}
