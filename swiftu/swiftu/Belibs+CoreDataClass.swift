//
//  Belibs+CoreDataClass.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData

@objc(Belibs)
public class Belibs: Services {
    override func detailTitle() -> String? {
        var adresse: String?
        if let nomVoie = self.geolocationRoute, let numeroVoie = self.geolocationStreetnumber {
            adresse = numeroVoie + ", " + nomVoie
        }
        return adresse
    }
}
