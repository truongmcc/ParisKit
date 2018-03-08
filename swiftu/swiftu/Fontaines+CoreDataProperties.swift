//
//  Fontaines+CoreDataProperties.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData


extension Fontaines {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Fontaines> {
        return NSFetchRequest<Fontaines>(entityName: "Fontaines")
    }

    @NSManaged public var adresse: String?
    @NSManaged public var classee: String?
    @NSManaged public var enService: String?
    @NSManaged public var localisation: String?
    @NSManaged public var modele: String?
    @NSManaged public var ouvHiver: String?
}
