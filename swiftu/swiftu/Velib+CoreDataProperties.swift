//
//  Velib+CoreDataProperties.swift
//  
//
//  Created by picshertho on 24/06/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Velib {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Velib> {
        return NSFetchRequest<Velib>(entityName: "Velib")
    }

    @NSManaged public var adress: String?
    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var name: String?
    @NSManaged public var number: Int16

}
