//
//  AutoLib+CoreDataClass.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData

@objc(AutoLib)
public class AutoLib: Services {
    override func detailTitle() -> String? {
        var detailTitle = ""
        if let address: String = self.address, let codePostal =  self.postalCode {
            detailTitle = address + " " + codePostal
        }
        return detailTitle
    }
}
