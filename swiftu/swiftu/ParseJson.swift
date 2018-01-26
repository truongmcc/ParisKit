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
    
    // static parse url
    func parse(data:Data,type:String) {
        NSLog("parse file data %@",type)
        var fetchResult:NSArray?
        let dicoSort:NSDictionary = idKeySort(type: type as String)
        fetchResult = Constants.MANAGER_DATA.resultFromSelectWithEntity(nomEntity: type as String, idKey: dicoSort["idKey"] as! String, bSort:dicoSort["sort"] as! Bool, bSave: false)
        do {
            
            let dicoJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            if let listeServices = dicoJson?["records"] as? [AnyObject]
            {
                if ((fetchResult?.count)! < listeServices.count){
                    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: type as String)
                    if let result = try? Constants.MANAGED_OBJECT_CONTEXT.fetch(fetchRequest) {
                        // --> suppression de la table s'il y a plus de data dans le json que dans la table
                        for object in result {
                            Constants.MANAGED_OBJECT_CONTEXT.delete(object as! NSManagedObject)
                        }
                        // <--
                        let typeFromDico = Constants.dicoType[type as String]!
                        let typeForSelector = String(format: "%@JsonManager:", typeFromDico)
                        let selector = NSSelectorFromString(typeForSelector)
                        if responds(to: selector) {
                            self.perform(selector, with:listeServices)
                        }
                    }
                } else {
                    updateArrayInterets(type:type as String, fetchResult:fetchResult!)
                }
            }
        } catch {
            print("Error")
        }
    }
    
    // Dynamic parse (disponibilités des véhicules...)
    func dynamicParse(data:Data, type:String) -> String {
        var message = ""
        do {
            guard let json = try JSONSerialization.jsonObject(with:data, options: []) as? [String: AnyObject] else {
                return "infos non disponibles pour le moment"
            }
            
            if (type == "Velib") {
                let dico = json as NSDictionary
                message = String.localizedStringWithFormat("Attaches disponibles : %@ ", dico.object(forKey:"available_bike_stands") as! CVarArg) as String
                message = message.appending(String.localizedStringWithFormat("velibs disponibles : %@",
                                                                             dico.object(forKey: "available_bikes") as! CVarArg) as String)
            } else if (type == "AutoLib") {
                if let listeDisponibilites = json["records"] as? [[String:AnyObject]]
                {
                    let dicoFields = listeDisponibilites[0]
                    let fields = dicoFields["fields"]
                    let slots = (fields?["slots"] as! Int16?)!
                    let cars = (fields?["cars"] as! Int16?)!
                    message = String.init(format: "%d voiture(s) restante(s) et %d place(s) libre(s)", cars, slots)
                }
            } else if (type == "Belibs") {
                if let datas = json["records"] as? [[String:AnyObject]]
                {
                    if (datas.count == 0) {
                        message = "info non disponible"
                    } else {
                        let dicoFields = datas[0]
                        let fields = dicoFields["fields"]
                        let status = (fields?["status_available"] as! String?)!
                        if (status == "0") {
                            message = "indisponible"
                        } else {
                            message = "disponible"
                        }
                    }
                }
            }
        } catch  {
            return "error trying to convert data to JSON"
        }
        return message
    }
    
    // parse from embedded file
    func parseFileWithType(type:String) {
        let fetchResult:NSArray?
        let dicoSort:NSDictionary = idKeySort(type: type as String)
        fetchResult = Constants.MANAGER_DATA.resultFromSelectWithEntity(nomEntity: type as String, idKey: dicoSort["idKey"] as! String, bSort:dicoSort["sort"] as! Bool, bSave: false)
        let filePath = self.filePath(type: type as String)
        if let dataJson = try? Data(contentsOf:URL(fileURLWithPath:filePath)) {
            do {
                // array of dictionaries
                if let jsonObj = try JSONSerialization.jsonObject(with: dataJson, options: []) as? [[String:AnyObject]]
                {
                    // voir s'il faut remettre à jour la table
                    if ((fetchResult?.count)! < jsonObj.count){
                        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: type as String)
                        if let result = try? Constants.MANAGED_OBJECT_CONTEXT.fetch(fetchRequest) {
                            for object in result {
                                Constants.MANAGED_OBJECT_CONTEXT.delete(object as! NSManagedObject)
                            }
                            let typeFromDico = Constants.dicoType[type as String]!
                            let typeForSelector = String(format: "%@JsonManager:", typeFromDico)
                            let selector = NSSelectorFromString(typeForSelector)
                            if responds(to: selector) {
                                self.perform(selector, with:jsonObj)
                            }
                        }
                    } else {
                        updateArrayInterets(type:type as String, fetchResult:fetchResult!)
                    }
                }
            } catch {
                print("Error")
            }
        }
    }

    //MARK:Services
    func cafesJsonManager(_ tabCafes:[AnyObject]) {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        container.performBackgroundTask() { (context) in
            for dic  in tabCafes  {
                let recordid = dic["recordid"] as! String
                var dicoField = dic["fields"] as! Dictionary<String,Any>
                let myManagedObject:NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Cafes" as String, into:context )
                if (myManagedObject?.entity.name == "Cafes") {
                    if let castedManagedObject = myManagedObject as? Cafes {
                        castedManagedObject.recordid = recordid
                        castedManagedObject.arrondissement =  (dicoField["arrondissement"] as! Int32)
                        castedManagedObject.prix_terasse =  dicoField["prix_terasse"] as! String?
                        if (dicoField["prix_comptoir"] as? Int16) != nil {
                            castedManagedObject.prix_comptoir = (dicoField["prix_comptoir"] as? Int16)!
                        }
                        castedManagedObject.prix_salle = dicoField["prix_salle"] as! String?
                        castedManagedObject.nom_du_cafe = dicoField["nom_du_cafe"] as! String?
                        castedManagedObject.adresse = dicoField["adresse"] as! String?
                        if let dicoGeometry = dic["geometry"] as? Dictionary<String, Any> {
                            let coordo:NSArray = dicoGeometry["coordinates"] as! NSArray
                            castedManagedObject.coordinateX = coordo[1] as! Float
                            castedManagedObject.coordinateY = coordo[0] as! Float
                        }
                    }
                }
            }
            do {
                try context.save()
                Constants.MANAGER_DATA.tableauCafes = Constants.MANAGER_DATA.updateArrayEntity(nomEntity:"Cafes" as String)
                
            } catch _ {
                fatalError("Failure to save context")
            }
        }
    }
    
    func belibsJsonManager(_ tabBelibs:[AnyObject]) {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        container.performBackgroundTask() { (context) in
            for dic  in tabBelibs  {
                let recordid = dic["recordid"] as! String
                var dicoField = dic["fields"] as! Dictionary<String, Any>
                let myManagedObject:NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Belibs" as String, into:context )
                if (myManagedObject?.entity.name == "Belibs") {
                    if let castedManagedObject = myManagedObject as? Belibs {
                        castedManagedObject.recordid = recordid
                        castedManagedObject.aggregated_nbplugs =  (dicoField["aggregated_nbplugs"] as! Int16)
                        castedManagedObject.geolocation_postalcode =  dicoField["geolocation_postalcode"] as! String?
                        castedManagedObject.geolocation_route =  dicoField["geolocation_route"] as! String?
                        castedManagedObject.geolocation_streetnumber = dicoField["geolocation_streetnumber"] as! String?
                        castedManagedObject.static_nbparkingspots = dicoField["static_nbparkingspots"] as! Int16
                        castedManagedObject.static_nbstations = dicoField["static_nbstations"] as! Int16
                        castedManagedObject.static_opening_247 = dicoField["static_opening_247"] as! String?
                        castedManagedObject.status_available = dicoField["status_available"] as! String?
                        if let dicoGeometry = dic["geometry"] as? Dictionary<String, Any> {
                            let coordo:NSArray = dicoGeometry["coordinates"] as! NSArray
                            castedManagedObject.coordinateX = coordo[1] as! Float
                            castedManagedObject.coordinateY = coordo[0] as! Float
                        }
                    }
                }
            }
            do {
                try context.save()
                Constants.MANAGER_DATA.tableauBelibs = Constants.MANAGER_DATA.updateArrayEntity(nomEntity:"Belibs" as String)
                
            } catch _ {
                fatalError("Failure to save context")
            }
        }
    }
    
    func fontainesJsonManager(_ tabFontaines:[AnyObject]) {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        container.performBackgroundTask() { (context) in
            for dic  in tabFontaines  {
                let recordid = dic["recordid"] as! String
                var dicoField = dic["fields"] as! Dictionary<String, Any>
                let myManagedObject:NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Fontaines" as String, into:context )
                if (myManagedObject?.entity.name == "Fontaines") {
                    if let castedManagedObject = myManagedObject as? Fontaines {
                        castedManagedObject.recordid = recordid
                        castedManagedObject.localisation =  dicoField["localisati"] as! String?
                        castedManagedObject.adresse =  dicoField["adr_s"] as! String?
                        castedManagedObject.classee =  dicoField["classee"] as! String?
                        castedManagedObject.modele = dicoField["modele"] as! String?
                        castedManagedObject.en_service = dicoField["en_service"] as! String?
                        castedManagedObject.ouv_hiver = dicoField["ouv_hiver"] as! String?
                        let dicoGeometry = dic["geometry"] as! Dictionary<String, Any>
                        let coordo:NSArray = dicoGeometry["coordinates"] as! NSArray
                        castedManagedObject.coordinateX = coordo[1] as! Float
                        castedManagedObject.coordinateY = coordo[0] as! Float
                    }
                }
            }
            do {
                try context.save()
                Constants.MANAGER_DATA.tableauFontaines = Constants.MANAGER_DATA.updateArrayEntity(nomEntity:"Fontaines" as String)
                
            } catch _ {
                fatalError("Failure to save context")
            }
        }
    }
    
    func capotesJsonManager(_ tabCapotes:[AnyObject]) {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        container.performBackgroundTask() { (context) in
            for dic  in tabCapotes  {
                let recordid = dic["recordid"] as! String
                var dicoField = dic["fields"] as! Dictionary<String, Any>
                let myManagedObject:NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Capotes" as String, into:context )
                if (myManagedObject?.entity.name == "Capotes") {
                    if let castedManagedObject = myManagedObject as? Capotes {
                        castedManagedObject.recordid = recordid
                        castedManagedObject.acces =  dicoField["acces"] as! String?
                        castedManagedObject.adresse =  dicoField["adresse_complete"] as! String?
                        castedManagedObject.horairesEte =  dicoField["horaires_vacances_ete"] as! String?
                        castedManagedObject.horairesHiver = dicoField["horaires_vacances_hiver"] as! String?
                        castedManagedObject.horairesNormales = dicoField["horaires_normal"] as! String?
                        castedManagedObject.site = dicoField["site"] as! String?
                        let dicoGeometry = dic["geometry"] as! Dictionary<String, Any>
                        let coordo:NSArray = dicoGeometry["coordinates"] as! NSArray
                        castedManagedObject.coordinateX = coordo[1] as! Float
                        castedManagedObject.coordinateY = coordo[0] as! Float
                    }
                }
            }
            do {
                try context.save()
                Constants.MANAGER_DATA.tableauCapotes = Constants.MANAGER_DATA.updateArrayEntity(nomEntity:"Capotes" as String)
                
            } catch _ {
                fatalError("Failure to save context")
            }
        }
    }
    
    //    {
    //        "datasetid":"sanisettesparis2011",
    //        "recordid":"cb7aee1791ccce595e97d98fc0f72d05709abf52",
    //        "fields":{
    //            "objectid":10,
    //            "arrondissement":"02",
    //            "nom_voie":"BOULEVARD DE SEBASTOPOL",
    //            "geom_x_y":[
    //            48.864828018946774,
    //            2.351611260829617
    //            ],
    //            "geom":{
    //                "type":"Point",
    //                "coordinates":[
    //                2.351611260829617,
    //                48.864828018946774
    //                ]
    //            },
    //            "y":129375.048287,
    //            "x":601106.877435,
    //            "numero_voie":"85",
    //            "identifiant":"2/102",
    //            "horaires_ouverture":"6 h - 22 h"
    //        },
    //        "geometry":{
    //            "type":"Point",
    //            "coordinates":[
    //            2.351611260829617,
    //            48.864828018946774
    //            ]
    //        },
    //        "record_timestamp":"2017-06-30T22:00:44+00:00"
    //        }
    func sanisettesJsonManager(_ tabSanisettes:[AnyObject]) {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        container.performBackgroundTask() { (context) in
            
            for dic  in tabSanisettes  {
                var dicoField = dic["fields"] as! Dictionary<String, Any>
                let myManagedObject:NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Sanisettes" as String, into:context )
                if (myManagedObject?.entity.name == "Sanisettes") {
                    if let castedManagedObject = myManagedObject as? Sanisettes {
                        castedManagedObject.nom_voie =  dicoField["nom_voie"] as! String?
                        castedManagedObject.horaires_ouverture =  dicoField["horaires_ouverture"] as! String?
                        castedManagedObject.numero_voie =  dicoField["numero_voie"] as! String?
                        castedManagedObject.arrondissement = dicoField["arrondissement"]      as! String?
                        let dicoGeometry = dic["geometry"] as! Dictionary<String, Any>
                        let coordo:NSArray = dicoGeometry["coordinates"] as! NSArray
                        castedManagedObject.coordinateX = coordo[1] as! Float
                        castedManagedObject.coordinateY = coordo[0] as! Float
                    }
                }
            }
            do {
                try context.save()
                Constants.MANAGER_DATA.tableauSanisettes = Constants.MANAGER_DATA.updateArrayEntity(nomEntity:"Sanisettes" as String)
                
            } catch _ {
                fatalError("Failure to save context")
            }
        }
    }
    
    /*--------- FORMAT -----------------
     //             [
     //             {
     //             "datasetid": "arbresremarquablesparis2011",
     //             "recordid": "209c78f694523775aed9e93af8e8bab730007f71",
     //             "fields":
     //             {
     //             "annee_pla": "1935",
     //             "circonf": 335.0,
     //             "objectid": 27,
     //             "adresse": "Bd Jourdan, avenue Reille, rue Gazan, rue de la Cité-Universitaire, rue Nansouty",
     //             "espece": "sempervirens",
     //             "arrondisse": "14",
     //             "famille": "Taxodiaceae",
     //             "geom_x_y": [
     //             48.8220238534,
     //             2.33628540112
     //             ],
     //             "genre": "Sequoia",
     //             "nom_commun": "Sequoia sempervirent",
     //             "nom_ev": "Parc Montsouris",
     //             "hauteur": 30.0
     //             },
     //             "geometry": {
     //             "type": "Point",
     //             "coordinates": [
     //             2.33628540112,
     //             48.8220238534
     //             ]
     //             },
     //             "record_timestamp": "2014-08-13T20:16:19.201211"
     //             }
     //             */
    func arbresJsonManager(_ tabArbres:[AnyObject]) {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        container.performBackgroundTask() { (context) in
            
            for dic in tabArbres  {
                let recordid = dic["recordid"] as! String
                var dicoField = dic["fields"] as! Dictionary<String,Any>
                let myManagedObject:NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Arbres" as String, into:context )
                if (myManagedObject?.entity.name == "Arbres") {
                    if let castedManagedObject = myManagedObject as? Arbres {
                        castedManagedObject.dateplantation =  dicoField["dateplantation"] as! String?
               
                        castedManagedObject.recordid = recordid
                        castedManagedObject.adresse = dicoField["adresse"]      as! String?
                        castedManagedObject.espece = dicoField["espece"]        as! String?
                        castedManagedObject.arrondisse = dicoField["arrondisse"] as! String?
                        castedManagedObject.famille = dicoField["famille"] as! String?
                        castedManagedObject.libellefrancais = dicoField["libellefrancais"] as! String?
                        castedManagedObject.genre = dicoField["genre"] as! String?
                        castedManagedObject.genre = dicoField["domanialite"] as! String?
                        castedManagedObject.nom_ev = dicoField["nom_env"] as! String?
                        castedManagedObject.hauteurenm = dicoField["hauteurenm"] as! Float
                        castedManagedObject.circonferenceencm = dicoField["circonferenceencm"] as! Float
                        
                        let dicoGeometry = dic["geometry"] as! Dictionary<String, Any>
                        castedManagedObject.type = dicoGeometry["type"] as? String
                        let coordo:NSArray = dicoGeometry["coordinates"] as! NSArray
                        castedManagedObject.coordinateX = coordo[1] as! Float
                        castedManagedObject.coordinateY = coordo[0] as! Float
                    }
                }
            }
            do {
                try context.save()
                Constants.MANAGER_DATA.tableauArbres = Constants.MANAGER_DATA.updateArrayEntity(nomEntity:"Arbres" as String)
                
            } catch _ {
                fatalError("Failure to save context")
            }
        }
    }
    
    func velibJsonManager(_ jsonObj:[[String:AnyObject]]) {
        for dataDict in jsonObj {
            let myManageObject:NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Velib" as String, into:Constants.MANAGED_OBJECT_CONTEXT )
            if (myManageObject?.entity.name == "Velib") {
                if let castedManageObject = myManageObject as? Velib {
                    castedManageObject.name = dataDict["name"] as! String?
                    castedManageObject.number = dataDict["number"]  as! Int32
                    castedManageObject.adress = dataDict["address"] as! String?
                    castedManageObject.latitude = (dataDict["latitude"] as! Float?)!
                    castedManageObject.longitude = (dataDict["longitude"] as! Float?)!
                    do {
                        try castedManageObject.managedObjectContext?.save()
                        Constants.MANAGER_DATA.tableauVelib = Constants.MANAGER_DATA.updateArrayEntity(nomEntity:"Velib" as String)
                        
                    } catch _ {
                        fatalError("Failure to save context")
                    }
                }
            }
        }
    }
    
    func autolibJsonManager(_ jsonObj:[[String:AnyObject]]) {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = Constants.MANAGED_OBJECT_CONTEXT
        privateMOC.perform {
            for dataDict in jsonObj {
                
                let myManageObject:NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "AutoLib" as String, into:privateMOC )
                if (myManageObject?.entity.name == "AutoLib") {
                    if let castedManageObject = myManageObject as? AutoLib {
                        let dicoGeometry=dataDict["geometry"]
                        let coord:NSArray = dicoGeometry?["coordinates"] as! NSArray
                        let dicoFields = dataDict["fields"]
                        castedManageObject.id = (dicoFields?["id"] as! String?)!
                        castedManageObject.coordinateY = (coord[0] as! Float)
                        castedManageObject.coordinateX = (coord[1] as! Float)
                        castedManageObject.address = (dicoFields?["address"] as! String?)!
                        castedManageObject.postal_code = (dicoFields?["postal_code"] as! String?)!
                        castedManageObject.public_name = (dicoFields?["public_name"] as! String?)!
                    }
                }
            }
            do {
                try privateMOC.save()
                Constants.MANAGED_OBJECT_CONTEXT.performAndWait {
                    do {
                        try Constants.MANAGED_OBJECT_CONTEXT.save()
                        Constants.MANAGER_DATA.tableauAutolib = Constants.MANAGER_DATA.updateArrayEntity(nomEntity:"AutoLib" as String)
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    func taxiJsonManager(_ jsonObj:[[String:AnyObject]]) {
        for dataDict in jsonObj {
            let myManageObject:NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Taxis" as String, into:Constants.MANAGED_OBJECT_CONTEXT )
            if (myManageObject?.entity.name == "Taxis") {
                if let castedManageObject = myManageObject as? Taxis {
                    
                    let dicoGeometry=dataDict["geometry"]
                    let coord:NSArray = dicoGeometry?["coordinates"] as! NSArray
                    
                    let dicoFields = dataDict["fields"]
                    castedManageObject.coordY = (coord[0] as! Float)
                    castedManageObject.coordX = (coord[1] as! Float)
                    castedManageObject.station_name = (dicoFields?["station_name"] as! String?)!
                    castedManageObject.address = (dicoFields?["address"] as! String?)!
                    castedManageObject.zip_code = (dicoFields?["zip_code"] as! String?)!
                    do {
                        try castedManageObject.managedObjectContext?.save()
                        Constants.MANAGER_DATA.tableauTaxis = Constants.MANAGER_DATA.updateArrayEntity(nomEntity:"Taxis" as String)
                    } catch _ {
                        fatalError("Failure to save context")
                    }
                }
            }
        }
    }
    
    //MARK:type manager
    func updateArrayInterets(type:String, fetchResult:NSArray) {
        switch type {
        case "Velib":
            Constants.MANAGER_DATA.tableauVelib = NSMutableArray(array:fetchResult)
        case "AutoLib":
            Constants.MANAGER_DATA.tableauAutolib = NSMutableArray(array:fetchResult)
        case "Taxis":
            Constants.MANAGER_DATA.tableauTaxis = NSMutableArray(array:fetchResult)
        case "Arbres":
            Constants.MANAGER_DATA.tableauArbres = NSMutableArray(array:fetchResult)
        case "Sanisettes":
            Constants.MANAGER_DATA.tableauSanisettes = NSMutableArray(array:fetchResult)
        case "Capotes":
            Constants.MANAGER_DATA.tableauCapotes = NSMutableArray(array:fetchResult)
        case "Fontaines":
            Constants.MANAGER_DATA.tableauFontaines = NSMutableArray(array:fetchResult)
        case "Belibs":
            Constants.MANAGER_DATA.tableauBelibs = NSMutableArray(array:fetchResult)
        case "Cafes":
            Constants.MANAGER_DATA.tableauCafes = NSMutableArray(array:fetchResult)
        default: break
        }
    }
    
    func idKeySort(type:String) -> NSDictionary {
        let dico:Dictionary<String, Any>
        switch type {
        case "Velib":
            dico = ["idKey" : "number", "sort" : true]
        case "AutoLib":
            dico = ["idKey" : "nomStation", "sort" : false]
        case "Arbres":
            dico = ["idKey" : "objectid", "sort" : true]
        case "Taxis":
            dico = ["idKey" : "zip_code", "sort" : true]
        case "Sanisettes":
            dico = ["idKey" : "arrondissement", "sort" : true]
        case "Capotes":
            dico = ["idKey" : "site", "sort" : false]
        case "Fontaines":
            dico = ["idKey" : "recordid", "sort" : false]
        case "Belibs":
            dico = ["idKey" : "recordid", "sort" : false]
        case "Cafes":
            dico = ["idKey" : "recordid", "sort" : false]
        default:
            dico = ["idKey" : "", "sort" : false]
        }
        return dico as NSDictionary
    }
    
    func filePath(type:String) -> String {
        var filePath:String?
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
