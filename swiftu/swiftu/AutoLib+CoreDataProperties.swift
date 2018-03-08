//
//  AutoLib+CoreDataProperties.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData


extension AutoLib {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AutoLib> {
        return NSFetchRequest<AutoLib>(entityName: "AutoLib")
    }

    @NSManaged public var address: String?
    @NSManaged public var cars: Int16
    @NSManaged public var postalCode: String?
    @NSManaged public var publicName: String?
    @NSManaged public var slots: Int16

}
