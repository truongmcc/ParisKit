//
//  Velib+CoreDataProperties.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData


extension Velib {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Velib> {
        return NSFetchRequest<Velib>(entityName: "Velib")
    }

    @NSManaged public var adress: String?
    @NSManaged public var name: String?

}
