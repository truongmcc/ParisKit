//
//  Cafes+CoreDataProperties.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData


extension Cafes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cafes> {
        return NSFetchRequest<Cafes>(entityName: "Cafes")
    }

    @NSManaged public var adresse: String?
    @NSManaged public var arrondissement: Int32
    @NSManaged public var nomDuCafe: String?
    @NSManaged public var prixComptoir: Int16
    @NSManaged public var prixSalle: String?
    @NSManaged public var prixTerasse: String?

}
