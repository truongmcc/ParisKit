//
//  AutoLib+CoreDataProperties.swift
//  
//
//  Created by picshertho on 24/06/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension AutoLib {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AutoLib> {
        return NSFetchRequest<AutoLib>(entityName: "AutoLib")
    }

    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var nombreTotalPlaces: Int16
    @NSManaged public var nomStation: String?
    @NSManaged public var placeRecharge: Int16
    @NSManaged public var placesAutolib: Int16

}
