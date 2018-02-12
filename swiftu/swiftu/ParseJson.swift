//
//  ParseJson.swift
//  swiftu
//
//  Created by picshertho on 19/07/2017.
//  Copyright © 2017 tru. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ParseJson: NSObject {
    // PARSE FROM EMBEDDED FILE (Taxis.json file)
    func parse(data: Data, type: String) {
        NSLog("parse file data %@", type)
        var fetchResult: NSArray?
        let dicoSort: NSDictionary = idKeySort(type: type as String)
        fetchResult = Constants.MANAGERDATA.resultFromSelectWithEntity(nomEntity: type as String, idKey: (dicoSort["idKey"] as? String)!, bSort: (dicoSort["sort"] as? Bool)!, bSave: false)
        do {
            let dicoJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            if let listeServices = dicoJson?["records"] as? [AnyObject] {
                if (fetchResult?.count)! < listeServices.count {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: type as String)
                    if let result = try? Constants.MANAGEDOBJECTCONTEXT?.fetch(fetchRequest) {
                        // --> suppression de la table s'il y a plus de data dans le json que dans la table
                        for object in result! {
                            Constants.MANAGEDOBJECTCONTEXT?.delete((object as? NSManagedObject)!)
                        }
                        // <--
                        let typeFromDico = Constants.dicoType[type as String]!
                        let typeForSelector = String(format: "%@JsonManager:", typeFromDico)
                        let selector = NSSelectorFromString(typeForSelector)
                        if responds(to: selector) {
                            self.perform(selector, with: listeServices)
                        }
                    }
                } else {
                    updateArrayInterets(type: type as String, fetchResult: fetchResult! as [AnyObject])
                }
            }
        } catch {
            print("Error")
        }
    }
    // Dynamic parse (disponibilités des véhicules...)
    func dynamicParse(data: Data, type: String) -> String {
        var message = ""
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                return "infos non disponibles pour le moment"
            }
            if type == "Velib" {
                if let listeDisponibilites = json["records"] as? [[String: AnyObject]] {
                    let dicoFields = listeDisponibilites[0]
                    let fields = dicoFields["fields"]
                    let attachesDispos = (fields?["numdocksavailable"] as? Int16?)!
                    let velibsDispos = (fields?["numbikesavailable"] as? Int16?)!
                    message = "Attaches disponibles: \(attachesDispos!) velibs disponibles: \(velibsDispos!)"
                }
            } else if type == "AutoLib" {
                if let listeDisponibilites = json["records"] as? [[String: AnyObject]] {
                    let dicoFields = listeDisponibilites[0]
                    let fields = dicoFields["fields"]
                    let slots = (fields?["slots"] as? Int16?)!
                    let cars = (fields?["cars"] as? Int16?)!
                    message = "\(cars!) voiture(s) restante(s) et \(slots!) place(s) libre(s)"
                }
            } else if type == "Belibs" {
                if let datas = json["records"] as? [[String: AnyObject]] {
                    if datas.count == 0 {
                        message = "info non disponible"
                    } else {
                        let dicoFields = datas[0]
                        let fields = dicoFields["fields"]
                        let status = (fields?["status_available"] as? String?)!
                        if status == "0" {
                            message = "indisponible"
                        } else {
                            message = "disponible"
                        }
                    }
                }
            }
        } catch {
            return "error trying to convert data to JSON"
        }
        return message
    }
    // parse from embedded file
    func parseFileWithType(type: String) {
        let fetchResult: NSArray?
        let dicoSort: NSDictionary = idKeySort(type: type as String)
        fetchResult = Constants.MANAGERDATA.resultFromSelectWithEntity(nomEntity: type as String, idKey: (dicoSort["idKey"] as? String)!, bSort: (dicoSort["sort"] as? Bool)!, bSave: false)
        let filePath = self.filePath(type: type as String)
        if let dataJson = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
            do {
                // array of dictionaries
                if let jsonObj = try JSONSerialization.jsonObject(with: dataJson, options: []) as? [[String: AnyObject]] {
                    // voir s'il faut remettre à jour la table
                    if (fetchResult?.count)! < jsonObj.count {
                        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: type as String)
                        if let result = try? Constants.MANAGEDOBJECTCONTEXT?.fetch(fetchRequest) {
                            for object in result! {
                                Constants.MANAGEDOBJECTCONTEXT?.delete((object as? NSManagedObject)!)
                            }
                            let typeFromDico = Constants.dicoType[type as String]!
                            let typeForSelector = String(format: "%@JsonManager:", typeFromDico)
                            let selector = NSSelectorFromString(typeForSelector)
                            if responds(to: selector) {
                                self.perform(selector, with: jsonObj)
                            }
                        }
                    } else {
                        updateArrayInterets(type: type as String, fetchResult: fetchResult! as [AnyObject])
                    }
                }
            } catch {
                print("Error")
            }
        }
    }
    // MARK: Services
    func createServiceFromJson(service: Services, structure: [[String: AnyObject]], dic: NSDictionary) {
        //https://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics
        if let recordid = dic["recordid"] as? String {
            service.setValue(recordid, forKey: "recordid")
            var dicoField = dic["fields"] as? [String: Any]
            for property in structure {
                let field: String? = property["field"] as? String      // field du Service
                let keyDico: String? = (property["key"]) as? String    // clé du dictionnaire correspondant au field
                if keyDico == "geoloc" || keyDico == "geolocation_coordinates" || keyDico == "geo_point_2d" || keyDico == "xy" || keyDico == "geom_x_y" || keyDico == "geo_point" {
                    guard let coordo = dicoField![keyDico!] as? NSArray else { return }
                    if field == "coordinateX" {
                        service.setValue(coordo[0], forKey: field!)
                    } else if field == "coordinateY" {
                        service.setValue(coordo[1], forKey: field!)
                    }
                } else {
                    let value = dicoField![keyDico!]         // valeur à updater
                    service.setValue(value, forKey: field!)
                }
            }
        }
    }
    @objc func cafesJsonManager(_ tabCafes: [AnyObject]) {
        DispatchQueue.main.async {
            let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
            container?.performBackgroundTask { (context) in
                for dic in tabCafes {
                    let myManagedObject: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Cafes" as String, into: context )
                    if myManagedObject?.entity.name == "Cafes" {
                        if let castedManagedObject = myManagedObject as? Cafes {
                            self.createServiceFromJson(service: castedManagedObject, structure: Constants.cafeFieldsAndKeys as [[String : AnyObject]], dic: (dic as? NSDictionary)!)
                        }
                    }
                }
                do {
                    try context.save()
                    Constants.MANAGERDATA.tableauCafes = Constants.MANAGERDATA.updateArrayEntity(nomEntity: "Cafes" as String)
                } catch _ {
                    fatalError("Failure to save context")
                }
            }
        }
    }
    @objc func belibsJsonManager(_ tabBelibs: [AnyObject]) {
        DispatchQueue.main.async {
            let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
            container?.performBackgroundTask { (context) in
                for dic  in tabBelibs {
                    let myManagedObject: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Belibs" as String, into: context )
                    if myManagedObject?.entity.name == "Belibs" {
                        if let castedManagedObject = myManagedObject as? Belibs {
                            self.createServiceFromJson(service: castedManagedObject, structure: Constants.belibFieldsAndKeys as [[String : AnyObject]], dic: (dic as? NSDictionary)!)
                        }
                    }
                }
                do {
                    try context.save()
                    Constants.MANAGERDATA.tableauBelibs = Constants.MANAGERDATA.updateArrayEntity(nomEntity: "Belibs" as String)
                } catch _ {
                    fatalError("Failure to save context")
                }
            }
        }
    }
    @objc func fontainesJsonManager(_ tabFontaines: [AnyObject]) {
        DispatchQueue.main.async {
            let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
            container?.performBackgroundTask { (context) in
                for dic in tabFontaines {
                    let myManagedObject: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Fontaines" as String, into: context )
                    if myManagedObject?.entity.name == "Fontaines" {
                        if let castedManagedObject = myManagedObject as? Fontaines {
                            self.createServiceFromJson(service: castedManagedObject, structure: Constants.fontaineFieldsAndKeys as [[String : AnyObject]], dic: (dic as? NSDictionary)!)
                        }
                    }
                }
                do {
                    try context.save()
                    Constants.MANAGERDATA.tableauFontaines = Constants.MANAGERDATA.updateArrayEntity(nomEntity: "Fontaines" as String)
                } catch _ {
                    fatalError("Failure to save context")
                }
            }
        }
    }
    @objc func capotesJsonManager(_ tabCapotes: [AnyObject]) {
        DispatchQueue.main.async {
            let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
            container?.performBackgroundTask { (context) in
                for dic in tabCapotes {
                    let myManagedObject: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Capotes" as String, into: context )
                    if myManagedObject?.entity.name == "Capotes" {
                        if let castedManagedObject = myManagedObject as? Capotes {
                            self.createServiceFromJson(service: castedManagedObject, structure: Constants.capoteFieldsAndKeys as [[String : AnyObject]], dic: (dic as? NSDictionary)!)
                        }
                    }
                }
                do {
                    try context.save()
                    Constants.MANAGERDATA.tableauCapotes = Constants.MANAGERDATA.updateArrayEntity(nomEntity: "Capotes" as String)
                } catch _ {
                    fatalError("Failure to save context")
                }
            }
        }
    }
    // https://opendata.paris.fr/api/records/1.0/search/?dataset=distributeurspreservatifsmasculinsparis2012&rows=1&facet=annee_installation&facet=arrond&facet=acces
    @objc func sanisettesJsonManager(_ tabSanisettes: [AnyObject]) {
        DispatchQueue.main.async {
            let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
            container?.performBackgroundTask { (context) in
                for dic  in tabSanisettes {
                    let myManagedObject: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Sanisettes" as String, into: context )
                    if myManagedObject?.entity.name == "Sanisettes" {
                        if let castedManagedObject = myManagedObject as? Sanisettes {
                            self.createServiceFromJson(service: castedManagedObject, structure: Constants.saniesetteFieldsAndKeys as [[String : AnyObject]], dic: (dic as? NSDictionary)!)
                        }
                    }
                }
                do {
                    try context.save()
                    Constants.MANAGERDATA.tableauSanisettes = Constants.MANAGERDATA.updateArrayEntity(nomEntity: "Sanisettes" as String)
                } catch _ {
                    fatalError("Failure to save context")
                }
            }
        }
    }
    
    /*--------- FORMAT -----------------
    // https://opendata.paris.fr/api/records/1.0/search/?dataset=les-arbres&rows=1&facet=typeemplacement&facet=domanialite&facet=arrondissement&facet=libellefrancais&facet=genre&facet=espece
    */
    @objc func arbresJsonManager(_ tabArbres: [AnyObject]) {
        DispatchQueue.main.async {
            let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
            container?.performBackgroundTask { (context) in
                for dic in tabArbres {
                    let myManagedObject: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Arbres" as String, into: context )
                    if myManagedObject?.entity.name == "Arbres" {
                        if let castedManagedObject = myManagedObject as? Arbres {
                            self.createServiceFromJson(service: castedManagedObject, structure: Constants.arbreFieldsAndKeys as [[String : AnyObject]], dic: (dic as? NSDictionary)!)
                        }
                    }
                }
                do {
                    try context.save()
                    Constants.MANAGERDATA.tableauArbres = Constants.MANAGERDATA.updateArrayEntity(nomEntity: "Arbres" as String)
                } catch _ {
                    fatalError("Failure to save context")
                }
            }
        }
    }
    // MARK: Perform Selector
    @objc func velibJsonManager(_ jsonObj: [[String: AnyObject]]) {
        for dataDict in jsonObj {
            let myManageObject: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Velib" as String, into: Constants.MANAGEDOBJECTCONTEXT! )
            if myManageObject?.entity.name == "Velib" {
                if let castedManageObject = myManageObject as? Velib {
                    if let recordid = dataDict["recordid"] as? String {
                        castedManageObject.recordid = recordid
                    }
                    if var dicoField = dataDict["fields"] as? [String: Any] {
                        if let name = dicoField["name"] as? String {
                            castedManageObject.name = name
                        } else if let station_id = dicoField["station_id"] as? String {
                            castedManageObject.station_id = station_id
                        }
                    }
                    if let dicoGeometry = dataDict["geometry"] as? [String: Any] {
                        if let coord: [Float] = dicoGeometry["coordinates"] as? [Float] {
                            castedManageObject.coordinateY = coord[0]
                            castedManageObject.coordinateX = coord[1]
                        }
                    }
                    do {
                        try castedManageObject.managedObjectContext?.save()
                        Constants.MANAGERDATA.tableauVelib = Constants.MANAGERDATA.updateArrayEntity(nomEntity: "Velib" as String)
                    } catch _ {
                        fatalError("Failure to save context")
                    }
                }
            }
        }
    }
//    @objc func velibJsonManager(_ jsonObj: [[String: AnyObject]]) {
//        for dataDict in jsonObj {
//            let myManageObject: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Velib" as String, into: Constants.MANAGEDOBJECTCONTEXT! )
//            if myManageObject?.entity.name == "Velib" {
//                if let castedManageObject = myManageObject as? Velib {
//                    if let recordid = dataDict["recordid"] as? String {
//                        castedManageObject.recordid = recordid
//                    }
//                    if var dicoField = dataDict["fields"] as? [String: Any] {
//                        if let name = dicoField["name"] as? String {
//                            castedManageObject.name = name
//                        } else if let station_id = dicoField["station_id"] as? String {
//                            castedManageObject.station_id = station_id
//                        }
//                    }
//                    if let dicoGeometry = dataDict["geometry"] as? [String: Any] {
//                        if let coord: [Float] = dicoGeometry["coordinates"] as? [Float] {
//                            castedManageObject.coordinateY = coord[0]
//                            castedManageObject.coordinateX = coord[1]
//                        }
//                    }
//                    do {
//                        try castedManageObject.managedObjectContext?.save()
//                        Constants.MANAGERDATA.tableauVelib = Constants.MANAGERDATA.updateArrayEntity(nomEntity: "Velib" as String)
//                    } catch _ {
//                        fatalError("Failure to save context")
//                    }
//                }
//            }
//        }
//    }
    @objc func autolibJsonManager(_ jsonObj: [[String: AnyObject]]) {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = Constants.MANAGEDOBJECTCONTEXT
        privateMOC.perform {
            for dataDict in jsonObj {
//                let myManagedObject: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "AutoLib" as String, into: context )
//                if myManagedObject?.entity.name == "AutoLib" {
//                    if let castedManagedObject = myManagedObject as? AutoLib {
//                        self.createServiceFromJson(service: castedManagedObject, structure: Constants.autolibFieldsAndKeys as [[String : AnyObject]], dic: (dic as? NSDictionary)!)
//                    }
//                }
                let myManageObject: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "AutoLib" as String, into: privateMOC )
                if myManageObject?.entity.name == "AutoLib" {
                    if let castedManageObject: AutoLib = myManageObject as? AutoLib {
                        let dicoGeometry=dataDict["geometry"]
                        let dicoFields = dataDict["fields"]
                        castedManageObject.recordid = (dicoFields?["id"] as? String?)!
                        if let coord: [Float] = dicoGeometry?["coordinates"] as? [Float] {
                            castedManageObject.coordinateY = coord[0]
                            castedManageObject.coordinateX = coord[1]
                        }
                        castedManageObject.address = (dicoFields?["address"] as? String?)!
                        castedManageObject.postal_code = (dicoFields?["postal_code"] as? String?)!
                        castedManageObject.public_name = (dicoFields?["public_name"] as? String?)!
                    }
                }
            }
            do {
                try privateMOC.save()
                Constants.MANAGEDOBJECTCONTEXT?.performAndWait {
                    do {
                        try Constants.MANAGEDOBJECTCONTEXT?.save()
                        Constants.MANAGERDATA.tableauAutolib = Constants.MANAGERDATA.updateArrayEntity(nomEntity: "AutoLib" as String)
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    @objc func taxiJsonManager(_ jsonObj: [[String: AnyObject]]) {
        for dataDict in jsonObj {
            let myManageObject: NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Taxis" as String, into: (Constants.MANAGEDOBJECTCONTEXT)!)
            if myManageObject?.entity.name == "Taxis" {
                if let castedManageObject = myManageObject as? Taxis {
                    let dicoGeometry=dataDict["geometry"]
                    let dicoFields = dataDict["fields"]
                    if let coord: [Float] = dicoGeometry?["coordinates"] as? [Float] {
                        castedManageObject.coordinateX = coord[1]
                        castedManageObject.coordinateY = coord[0]
                    }
                    castedManageObject.station_name = (dicoFields?["station_name"] as? String?)!
                    castedManageObject.address = (dicoFields?["address"] as? String?)!
                    castedManageObject.zip_code = (dicoFields?["zip_code"] as? String?)!
                    do {
                        try castedManageObject.managedObjectContext?.save()
                        Constants.MANAGERDATA.tableauTaxis = Constants.MANAGERDATA.updateArrayEntity(nomEntity: "Taxis" as String) as [AnyObject]
                    } catch _ {
                        fatalError("Failure to save context")
                    }
                }
            }
        }
    }
    // MARK: type manager
    func updateArrayInterets(type: String, fetchResult: [AnyObject]) {
        switch type {
        case "Velib":
            Constants.MANAGERDATA.tableauVelib = fetchResult as [AnyObject]
        case "AutoLib":
            Constants.MANAGERDATA.tableauAutolib = fetchResult as [AnyObject]
        case "Taxis":
            Constants.MANAGERDATA.tableauTaxis = fetchResult as [AnyObject]
        case "Arbres":
            Constants.MANAGERDATA.tableauArbres = fetchResult as [AnyObject]
        case "Sanisettes":
            Constants.MANAGERDATA.tableauSanisettes = fetchResult as [AnyObject]
        case "Capotes":
            Constants.MANAGERDATA.tableauCapotes = fetchResult as [AnyObject]
        case "Fontaines":
            Constants.MANAGERDATA.tableauFontaines = fetchResult as [AnyObject]
        case "Belibs":
            Constants.MANAGERDATA.tableauBelibs = fetchResult as [AnyObject]
        case "Cafes":
            Constants.MANAGERDATA.tableauCafes = fetchResult as [AnyObject]
        default: break
        }
    }
    func idKeySort(type: String) -> NSDictionary {
        let dico: [String: Any]
        switch type {
        case "Velib":
            dico = ["idKey": "recordid", "sort": true]
        case "AutoLib":
            dico = ["idKey": "nomStation", "sort": false]
        case "Arbres":
            dico = ["idKey": "objectid", "sort": true]
        case "Taxis":
            dico = ["idKey": "zip_code", "sort": true]
        case "Sanisettes":
            dico = ["idKey": "arrondissement", "sort": true]
        case "Capotes":
            dico = ["idKey": "site", "sort": false]
        case "Fontaines":
            dico = ["idKey": "recordid", "sort": false]
        case "Belibs":
            dico = ["idKey": "recordid", "sort": false]
        case "Cafes":
            dico = ["idKey": "recordid", "sort": false]
        default:
            dico = ["idKey": "", "sort": false]
        }
        return dico as NSDictionary
    }
    func filePath(type: String) -> String {
        var filePath: String?
        switch type {
        case "Velib":
            filePath = Bundle.main.path(forResource: "Paris", ofType: "json")
        case "Taxis":
            filePath = Bundle.main.path(forResource: "Taxis", ofType: "json")
        default: break
        }
        return filePath!
    }
}
