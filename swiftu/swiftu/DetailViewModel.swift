//
//  DetailViewModel.swift
//  swiftu
//
//  Created by christophe on 06/03/2018.
//  Copyright © 2018 tru. All rights reserved.
//

import UIKit

class DetailViewModel: NSObject {
    var service: AnyObject?
    var tabService: [AnyObject]?
    var adresse: String? 
    override init() {
        super.init()
        self.recupAdresse()
    }
    func recupAdresse() {
        if let fontaine = service as? Fontaines {
            self.adresse = fontaine.adresse
        } else if let arbre = service as? Arbres {
            self.adresse = arbre.adresse
        } else if let preservatif = service as? Preservatifs {
            if let adress = preservatif.adresse {
                self.adresse = adress
            }
        }
    }
    func serviceColor() -> UIColor {
        if service is Arbres? {
            return UIColor.green
        } else if service is Preservatifs? {
            return UIColor.red
        } else if service is Fontaines? {
            return UIColor.cyan
        } else if service is Cafes? {
            return UIColor.brown
        } else {
            return UIColor.white
        }
    }
    func detailText(index: Int) -> String? {
        var result: String?
        let property: String? = self.tabService?[index]["property"] as? String
        if let value = self.service?.value(forKey: property!) {
            if value is Float {
                let floatToString = String(describing: value)
                if let unit = Constants.tabDetailArbre[index]["unit"] {
                    result = floatToString + unit
                } else {
                    result = floatToString
                }
            } else if value is String {
                result = self.service?.value(forKey: property!) as? String
            }
        }
        return result
    }
}
