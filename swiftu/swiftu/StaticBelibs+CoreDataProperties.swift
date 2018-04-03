//
//  StaticBelibs+CoreDataProperties.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData


extension StaticBelibs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StaticBelibs> {
        return NSFetchRequest<StaticBelibs>(entityName: "StaticBelibs")
    }

    @NSManaged public var abonErdfKw: Float
    @NSManaged public var accesLieu: String?
    @NSManaged public var accesReseau: String?
    @NSManaged public var adresse: String?
    @NSManaged public var autentificationBorne: String?
    @NSManaged public var communicationSupervision: String?
    @NSManaged public var comptageEnergie: String?
    @NSManaged public var etatStation: String?
    @NSManaged public var idStation: String?
    @NSManaged public var nbrePlaces: Float
    @NSManaged public var nomStation: String?
    @NSManaged public var paiement: String?
    @NSManaged public var puissancePdcKw: Float
    @NSManaged public var telSavSodetrel: String?
    @NSManaged public var typeCharge: String?
    @NSManaged public var typeConnecteur: String?
    @NSManaged public var typeCourant: String?

}
