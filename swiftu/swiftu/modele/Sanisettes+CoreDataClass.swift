//
//  Sanisettes+CoreDataClass.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData

@objc(Sanisettes)
public class Sanisettes: Services {
    override func detailTitle() -> String? {
        var adresse: String?
        if let nomVoie = self.nomVoie, let numeroVoie = self.numeroVoie {
            adresse = numeroVoie + ", " + nomVoie
        }
        return adresse
    }
    override func detailSubTitle() -> String? {
        var subtitle: String?
        if self.horairesOuverture != nil {
            subtitle = String.init(format: "%@", self.horairesOuverture!)
        } else {
            subtitle = "Horaires inconnues"
        }
        return subtitle
    }
}
