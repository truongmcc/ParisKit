//
//  Taxis+CoreDataClass.swift
//  
//
//  Created by christophe on 08/03/2018.
//
//

import Foundation
import CoreData


public class Taxis: Services {
    override func detailTitle() -> String? {
        return stationName
    }
    override func detailSubTitle() -> String? {
        return self.address! + " " + self.zipCode!
    }
}
