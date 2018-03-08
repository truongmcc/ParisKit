//
//  Cafes+CoreDataClass.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData

@objc(Cafes)
public class Cafes: Services {
    override func detailTitle() -> String? {
        return nomDuCafe
    }
    override func detailSubTitle() -> String? {
        var subtitle: String?
        if self.adresse != nil {
            subtitle = self.adresse
            if self.arrondissement > 0 {
                subtitle = subtitle! + " "
                subtitle = subtitle! + String(self.arrondissement)
            }
        }
        return subtitle
    }
}
