//
//  ParseJson.swift
//  swiftu
//
//  Created by picshertho on 19/11/2016.
//  Copyright © 2016 tru. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ParseJson {

    func parseFile(data:Data,type:NSString) {
        var fetchResult:NSArray?
        let dicoSort:NSDictionary = idKeySort(type: type as String)
        fetchResult = Constants.MANAGER_DATA.resultFromSelectWithEntity(nomEntity: type as String, idKey: dicoSort["idKey"] as! String, bSort:dicoSort["sort"] as! Bool, bSave: false)
        do {
            // array of dictionaries
            if let listeArbresComplet = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyObject]
            {
                // voir s'il faut remettre à jour la table
                if ((fetchResult?.count)! < listeArbresComplet.count){
                    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: type as String)
                    if let result = try? Constants.MANAGED_OBJECT_CONTEXT.fetch(fetchRequest) {
                        for object in result {
                            Constants.MANAGED_OBJECT_CONTEXT.delete(object as! NSManagedObject)
                        }
                        arbresJsonManager(tabArbres:listeArbresComplet)
                    }
                } else {
                    updateArrayInterets(type:type as String,fetchResult:fetchResult!)
                }
            }
        } catch {
            print("Error")
        }
    }

    func parseFileWithType(type:NSString) {
        // RENDRE GENERIQUE LA FONCTION EN CREANT UNE FONCTION QUI SELECTIONNE LE BON TABLEAU À METTRE A JOUR
        let fetchResult:NSArray?
        let dicoSort:NSDictionary = idKeySort(type: type as String)
        fetchResult = Constants.MANAGER_DATA.resultFromSelectWithEntity(nomEntity: type as String, idKey: dicoSort["idKey"] as! String, bSort:dicoSort["sort"] as! Bool, bSave: false)
        
        let filePath =   self.filePath(type: type as String)//Bundle.main.path(forResource: "Paris", ofType: "json")
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
                            
                            switch type {
                            case "Velib":
                                velibJsonManager(jsonObj)
                            case "AutoLib":
                                autolibJsonManager(jsonObj:jsonObj)
                            case "Taxis":
                                taxiJsonManager(jsonObj:jsonObj)
                            default: break
                            }
                        }
                    } else {
                        updateArrayInterets(type:type as String,fetchResult:fetchResult!)
                    }
                }
            } catch {
                print("Error")
            }
        }
    }
    
    //MARK:Parsing
    func arbresJsonManager(tabArbres:[AnyObject]) {
        var d = 0
        for dic  in tabArbres  {
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

            var dicoField = dic["fields"] as! Dictionary<String,Any>
            d = d + 1
            let myManagedObject:NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Arbres" as String, into:Constants.MANAGED_OBJECT_CONTEXT )
            if (myManagedObject?.entity.name == "Arbres") {
                if let castedManagedObject = myManagedObject as? Arbres {
//                    castedManagedObject.datasetid = (dic["datasetid"] as! Int16?)!
//                    castedManagedObject.recordid = dic["recordid"] as! Int16
                    castedManagedObject.annee_pla =  dicoField["annee_pla"] as! String?
                    if let circonf = dicoField["circonf"] as? Float {
                        castedManagedObject.circonf = circonf
                    }
                    castedManagedObject.objectid = dicoField["objectid"]    as! Int16
                    castedManagedObject.adresse = dicoField["adresse"]      as! String?
                    castedManagedObject.espece = dicoField["espece"]        as! String?
                    castedManagedObject.arrondisse = dicoField["arrondisse"] as! String?
                    castedManagedObject.famille = dicoField["famille"] as! String?
                    if let hauteur = dicoField["circonf"] as? Int16 {
                        castedManagedObject.hauteur = hauteur
                    }
                    castedManagedObject.nom_commun = dicoField["nom_commun"] as! String?
                    castedManagedObject.genre = dicoField["genre"] as! String?
                    castedManagedObject.nom_ev = dicoField["nom_env"] as! String?
                    
                    if ((dicoField["geom_x_y"]) != nil) {
                        let tabGeomXY:NSArray = dicoField["geom_x_y"] as! NSArray
                        castedManagedObject.geomX = tabGeomXY[0] as! Float
                        castedManagedObject.geomY = tabGeomXY[1] as! Float
                    }
                    let dicoGeometry = dic["geometry"] as! Dictionary<String,Any>
                    castedManagedObject.type = dicoGeometry["type"] as? String
                    let coordo:NSArray = dicoGeometry["coordinates"] as! NSArray
                    castedManagedObject.coordinateX = coordo[0] as! Float
                    castedManagedObject.coordinateY = coordo[1] as! Float

                    do {
                        try castedManagedObject.managedObjectContext?.save()
                        Constants.MANAGER_DATA.tableauArbres = Constants.MANAGER_DATA.MiseAJourTableEntity(nomEntity:"Arbres" as String)
                        
                    } catch _ {
                        fatalError("Failure to save context")
                    }
                }
            }
        }
    }
    
    func velibJsonManager(_ jsonObj:[[String:AnyObject]]) {
        for dataDict in jsonObj {
            let myManageObject:NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "Velib" as String, into:Constants.MANAGED_OBJECT_CONTEXT )
            if (myManageObject?.entity.name == "Velib") {
                if let castedManageObject = myManageObject as? Velib {
                    castedManageObject.name = dataDict["name"] as! String?
                    castedManageObject.number = dataDict["number"]  as! Int16
                    castedManageObject.adress = dataDict["address"] as! String?
                    castedManageObject.latitude = (dataDict["latitude"] as! Float?)!
                    castedManageObject.longitude = (dataDict["longitude"] as! Float?)!
                    do {
                        try castedManageObject.managedObjectContext?.save()
                        Constants.MANAGER_DATA.tableauVelib = Constants.MANAGER_DATA.MiseAJourTableEntity(nomEntity:"Velib" as String)
                        
                    } catch _ {
                        fatalError("Failure to save context")
                    }
                }
            }
        }
    }
    
    func autolibJsonManager(jsonObj:[[String:AnyObject]]) {
        for dataDict in jsonObj {
            let myManageObject:NSManagedObject? = NSEntityDescription.insertNewObject(forEntityName: "AutoLib" as String, into:Constants.MANAGED_OBJECT_CONTEXT )
            if (myManageObject?.entity.name == "AutoLib") {
                if let castedManageObject = myManageObject as? AutoLib {
                    
                    let dicoGeometry=dataDict["geometry"]
                    let coord:NSArray = dicoGeometry?["coordinates"] as! NSArray
                    
                    let dicoFields = dataDict["fields"]
                    castedManageObject.coordinateX = (coord[0] as! Float)
                    castedManageObject.coordinateY = (coord[1] as! Float)
                    castedManageObject.nombreTotalPlaces = (dicoFields?["nombre_total_de_places"] as! Int16)
                    castedManageObject.nomStation = (dicoFields?["nom_de_la_station"] as! String?)!
                    castedManageObject.placeRecharge = (dicoFields?["places_recharge_tiers"] as! Int16?)!
                    castedManageObject.placesAutolib = (dicoFields?["places_autolib"] as! Int16?)!
                    do {
                        try castedManageObject.managedObjectContext?.save()
                        Constants.MANAGER_DATA.tableauAutolib = Constants.MANAGER_DATA.MiseAJourTableEntity(nomEntity:"AutoLib" as String)
                    } catch _ {
                        fatalError("Failure to save context")
                    }
                }
            }
        }
    }
    
    func taxiJsonManager(jsonObj:[[String:AnyObject]]) {
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
                        Constants.MANAGER_DATA.tableauTaxis = Constants.MANAGER_DATA.MiseAJourTableEntity(nomEntity:"Taxis" as String)
                    } catch _ {
                        fatalError("Failure to save context")
                    }
                }
            }
        }
    }
    
    //MARK:type manager
    func updateArrayInterets(type:String , fetchResult:NSArray) {
        switch type {
        case "Velib":
            Constants.MANAGER_DATA.tableauVelib = NSMutableArray(array:fetchResult)
        case "AutoLib":
            Constants.MANAGER_DATA.tableauAutolib = NSMutableArray(array:fetchResult)
        case "Taxis":
            Constants.MANAGER_DATA.tableauTaxis = NSMutableArray(array:fetchResult)
        case "Arbres":
            Constants.MANAGER_DATA.tableauArbres = NSMutableArray(array:fetchResult)
        default: break
        }
    }
    
    func idKeySort(type:String) -> NSDictionary {
        let dico:Dictionary<String,Any>
        switch type {
        case "Velib":
            dico = ["idKey" : "number", "sort" : true]
        case "AutoLib":
            dico = ["idKey" : "nomStation", "sort" : false]
        case "Arbres":
            dico = ["idKey" : "objectid", "sort" : true]
        case "Taxis":
            dico = ["idKey" : "zip_code", "sort" : true]
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
        case "AutoLib":
            filePath = Bundle.main.path(forResource: "Autolib", ofType: "json")
        case "Taxis":
            filePath = Bundle.main.path(forResource: "Taxis", ofType: "json")
        case "Arbres":
            filePath = Bundle.main.path(forResource: "Arbres", ofType: "json")
        default: break
        }
        return filePath!
    }
}
