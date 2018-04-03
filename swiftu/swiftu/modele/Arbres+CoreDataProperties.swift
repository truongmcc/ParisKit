//
//  Arbres+CoreDataProperties.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData


extension Arbres {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Arbres> {
        return NSFetchRequest<Arbres>(entityName: "Arbres")
    }

    @NSManaged public var adresse: String?
    @NSManaged public var arrondisse: String?
    @NSManaged public var circonferenceencm: Float
    @NSManaged public var dateplantation: String?
    @NSManaged public var domanialite: String?
    @NSManaged public var espece: String?
    @NSManaged public var famille: String?
    @NSManaged public var genre: String?
    @NSManaged public var hauteurenm: Float
    @NSManaged public var libellefrancais: String?
    @NSManaged public var nomEv: String?
    @NSManaged public var objectid: Int16
    @NSManaged public var type: String?

}
