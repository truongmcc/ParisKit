//
//  Autolib+CoreDataProperties.swift
//  
//
//  Created by picshertho on 17/06/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Autolib {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Autolib> {
        return NSFetchRequest<Autolib>(entityName: "Autolib")
    }

    @NSManaged public var attribute: Int32

}
