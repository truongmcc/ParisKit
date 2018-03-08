//
//  Preservatifs+CoreDataProperties.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData


extension Preservatifs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Preservatifs> {
        return NSFetchRequest<Preservatifs>(entityName: "Preservatifs")
    }

    @NSManaged public var acces: String?
    @NSManaged public var adresse: String?
    @NSManaged public var horairesEte: String?
    @NSManaged public var horairesHiver: String?
    @NSManaged public var horairesNormales: String?
    @NSManaged public var site: String?

}
