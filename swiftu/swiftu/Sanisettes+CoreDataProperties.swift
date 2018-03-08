//
//  Sanisettes+CoreDataProperties.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData


extension Sanisettes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sanisettes> {
        return NSFetchRequest<Sanisettes>(entityName: "Sanisettes")
    }

    @NSManaged public var arrondissement: String?
    @NSManaged public var horairesOuverture: String?
    @NSManaged public var nomVoie: String?
    @NSManaged public var numeroVoie: String?

}
