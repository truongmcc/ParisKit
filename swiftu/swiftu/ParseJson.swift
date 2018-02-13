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
    func parse(data: Data, type: String) {
        NSLog("parse file data %@", type)
        var fetchResult: NSArray?
        let dicoSort: NSDictionary = idKeySort(type: type as String)
        fetchResult = Constants.MANAGERDATA.resultFromSelectWithEntity(nomEntity: type as String, idKey: (dicoSort["idKey"] as? String)!, bSort: (dicoSort["sort"] as? Bool)!, bSave: false)
        do {
            let dicoJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            if let listeServices = dicoJson?["records"] as? [[String: AnyObject]] {
                if (fetchResult?.count)! < listeServices.count {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: type as String)
                    if let result = try? Constants.MANAGEDOBJECTCONTEXT?.fetch(fetchRequest) {
                        // --> suppression de la table s'il y a plus de data dans le json que dans la table
                        for object in result! {
                            Constants.MANAGEDOBJECTCONTEXT?.delete((object as? NSManagedObject)!)
                        }
                        // <--
                        addServices(typeService: type, listeServices: listeServices)
                    }
                } else {
                    updateArrayInterets(type: type as String, fetchResult: fetchResult! as [AnyObject])
                }
            }
        } catch {
            print("Error")
        }
    }
    func addServices(typeService: String, listeServices: [[String: AnyObject]]) {
        DispatchQueue.main.async {
            let structService = Constants.STRUCTSERVICE[typeService]?["fieldAndKeyStruct"] as? [[String: AnyObject]]
            let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
            container?.performBackgroundTask { (context) in
                for dic in listeServices {
                    if let myManagedObject: Services = NSEntityDescription.insertNewObject(forEntityName: typeService as String, into: context ) as? Services {
                        self.createServiceFromJson(service: myManagedObject, structure: structService!, dic: dic as NSDictionary)
                    }
                }
                do {
                    try context.save()
                    
                    switch typeService {
                    case "Arbres":
                        Constants.MANAGERDATA.tableauArbres = Constants.MANAGERDATA.updateArrayEntity(nomEntity: typeService as String)
                    case "Velib":
                        Constants.MANAGERDATA.tableauVelib = Constants.MANAGERDATA.updateArrayEntity(nomEntity: typeService as String)
                    case "AutoLib":
                        Constants.MANAGERDATA.tableauAutolib = Constants.MANAGERDATA.updateArrayEntity(nomEntity: typeService as String)
                    case "Belibs":
                        Constants.MANAGERDATA.tableauBelibs = Constants.MANAGERDATA.updateArrayEntity(nomEntity: typeService as String)
                    case "Capotes":
                        Constants.MANAGERDATA.tableauCapotes = Constants.MANAGERDATA.updateArrayEntity(nomEntity: typeService as String)
                    case "Sanisettes":
                        Constants.MANAGERDATA.tableauSanisettes = Constants.MANAGERDATA.updateArrayEntity(nomEntity: typeService as String)
                    case "Cafes":
                        Constants.MANAGERDATA.tableauCafes = Constants.MANAGERDATA.updateArrayEntity(nomEntity: typeService as String)
                    case "Fontaines":
                        Constants.MANAGERDATA.tableauFontaines = Constants.MANAGERDATA.updateArrayEntity(nomEntity: typeService as String)
                    case "Taxis":
                        Constants.MANAGERDATA.tableauTaxis = Constants.MANAGERDATA.updateArrayEntity(nomEntity: typeService as String)
                    default:
                        return
                    }
                    //Constants.STRUCTSERVICE[typeService]?["tab"] = Constants.MANAGERDATA.updateArrayEntity(nomEntity: typeService as String) as? [[String: AnyObject]]
                } catch _ {
                    fatalError("Failure to save context")
                }
            }
        }
    }
    // MARK: Services
    // createServiceFromJson va parser de manière générique chaque service en utilsant le KVC
    func createServiceFromJson(service: Services, structure: [[String: AnyObject]], dic: NSDictionary) {
        //https://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics
        if let recordid = dic["recordid"] as? String {
            service.setValue(recordid, forKey: "recordid")
            var dicoField = dic["fields"] as? [String: Any]
            for property in structure {
                let field: String? = property["field"] as? String // field du Service
                let keyDico: String? = (property["key"]) as? String // clé du dictionnaire correspondant au field
                if keyDico == "geoloc" || keyDico == "geolocation_coordinates" || keyDico == "geo_point_2d" || keyDico == "xy" || keyDico == "geom_x_y" || keyDico == "geo_point" || keyDico == "geo_coordinates" {
                    guard let coordo = dicoField![keyDico!] as? NSArray else { return }
                    if field == "coordinateX" {
                        service.setValue(coordo[0], forKey: field!)
                    } else if field == "coordinateY" {
                        service.setValue(coordo[1], forKey: field!)
                    }
                } else {
                    let value = dicoField![keyDico!] // valeur à updater
                    service.setValue(value, forKey: field!)
                }
            }
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
