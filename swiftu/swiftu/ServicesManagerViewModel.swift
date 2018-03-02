//
//  ServicesManagerViewModel.swift
//  swiftu
//
//  Created by christophe on 28/02/2018.
//  Copyright © 2018 tru. All rights reserved.
//

import RxCocoa
import RxSwift
import CoreData

class ServicesManagerViewModel: NSObject {
    let disposeBag = DisposeBag()
    var monDownloader = Downloader()
    var dicoTabServices: [String: [AnyObject]] = [
                            "Arbres": [AnyObject](),
                           "Capotes": [AnyObject](),
                           "Fontaines": [AnyObject](),
                           "Cafes": [AnyObject](),
                           "Sanisettes": [AnyObject](),
                           "AutoLib": [AnyObject](),
                           "Belibs": [AnyObject](),
                           "Taxis": [AnyObject](),
                           "Velib": [AnyObject]()
                           ]
    // serviceToDisplay et selectedService pour l'affichage courrant dans la map
    var serviceToDisplay: [AnyObject]? = []
    var selectedService: Int?

    var typeMapKit: Int?
    func addServices() {
        for dico in Constants.SERVICES {
            if let url: String = dico["url"] as? String, let type = dico["type"] as? String {
                self.updateService(url: url, type: type)
            }
        }
    }
    // MARK: RXSWIFT
    func updateService(url: String, type: String) {
        self.monDownloader.rxDataFromUrl(url: url).subscribe { element in
            switch element {
            case .next(let value):
                self.parse(data: value, type: type)
            case .error:
                print("error : retrieving data from url")
            case .completed:
                print("completed")
            }
            }.disposed(by: disposeBag)
    }
    func dynamicUpdateService(url: String, type: String, result: @escaping (String) -> Void) {
        self.monDownloader.rxDataFromUrl(url: url).subscribe { element in
            switch element {
            case .next(let value):
                if let resultDynamicData = self.dynamicParse(data: value, type: type) {
                    result(resultDynamicData)
                }
            case .error:
                print("error : retrieving data from url")
            case .completed:
                print("completed")
            }
            }.disposed(by: disposeBag)
    }
    // MARK: CORE DATA
    func resultFromSelectWithEntity (nomEntity: String, idKey: String, bSort: Bool, bSave: Bool) -> NSArray {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: nomEntity)
            if bSort {
                let sortobjectid = NSSortDescriptor(key: idKey, ascending: true)
                let sortDescriptors = [sortobjectid]
                fetchRequest.sortDescriptors = sortDescriptors
            }
            do {
                let objects = try Constants.MANAGEDOBJECTCONTEXT?.fetch(fetchRequest)
                if bSave {
                    do {
                        try Constants.MANAGEDOBJECTCONTEXT?.save()
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
                return objects! as NSArray
            } catch {
                fatalError("Failure to fetch request: \(error)")
            }
        }
        return NSArray()
    }
    func selectRecordFromEntity (nomEntity: String, field: String, value: String) -> NSArray {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: nomEntity)
            fetchRequest.predicate = NSPredicate(format: "%K == %@", field, value)
            do {
                let objects = try Constants.MANAGEDOBJECTCONTEXT?.fetch(fetchRequest)
                return objects! as NSArray
            } catch {
                fatalError("Failure to fetch request: \(error)")
            }
        }
        return NSArray()
    }
    func updateArrayEntity(nomEntity: String) -> [AnyObject]? {
        var tabResult: Array? = [AnyObject]()
        let entity = NSFetchRequest<NSFetchRequestResult>(entityName: nomEntity)
        do {
            let myfetchResult = try Constants.MANAGEDOBJECTCONTEXT?.fetch(entity)
            tabResult = myfetchResult! as [AnyObject]
        } catch {
            fatalError("Failed to fetch \(nomEntity) : \(error)")
        }
        return tabResult
    }
    func tabService(typeService: Int) -> [AnyObject]? {
        var tabResult: Array? = [AnyObject]()
        for service in Constants.SERVICES {
            if let pos: Int = service["order"] as? Int {
                if typeService == pos {
                    if let serv = service["type"] as? String {
                        tabResult = dicoTabServices[serv]
                    }
                }
            }
        }
        return tabResult
    }
    // MARK: PARSING
    func parse(data: Data, type: String) {
        NSLog("parse file data %@", type)
        var fetchResult: NSArray?
        guard let idKey = Constants.STRUCTSERVICE[type]!["idKey"] as? String else {
            print("erreur idKey") ; return }
        guard let sort = Constants.STRUCTSERVICE[type]!["sort"] as? Bool else {
            print("erreur sort") ; return }
        fetchResult = resultFromSelectWithEntity(nomEntity: type as String, idKey: idKey, bSort: sort, bSave: false)
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
                    updateTabService(typeService: type)
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
                    self.updateTabService(typeService: typeService)
                } catch _ {
                    fatalError("Failure to save context")
                }
            }
        }
    }
    func updateTabService(typeService: String) {
        self.dicoTabServices[typeService] = updateArrayEntity(nomEntity: typeService as String)
    }
    // createServiceFromJson va parser de manière générique chaque service en utilsant le KVC
    func createServiceFromJson(service: Services, structure: [[String: AnyObject]], dic: NSDictionary) {
        //https://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics
        if let recordid = dic["recordid"] as? String {
            service.setValue(recordid, forKey: "recordid")
            var dicoField = dic["fields"] as? [String: Any]
            for property in structure {
                let field: String? = property["field"] as? String
                let keyDico: String? = (property["key"]) as? String
                if keyDico == "geoloc" || keyDico == "geolocation_coordinates" || keyDico == "geo_point_2d" || keyDico == "xy" || keyDico == "geom_x_y" || keyDico == "geo_point" || keyDico == "geo_coordinates" {
                    guard let coordo = dicoField![keyDico!] as? NSArray else { return }
                    if field == "coordinateX" {
                        service.setValue(coordo[0], forKey: field!)
                    } else if field == "coordinateY" {
                        service.setValue(coordo[1], forKey: field!)
                    }
                } else {
                    let value = dicoField![keyDico!]
                    service.setValue(value, forKey: field!)
                }
            }
        }
    }
    // Dynamic parse (disponibilités des véhicules...)
    func dynamicParse(data: Data, type: String) -> String? {
        var message = ""
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                return "infos non disponibles pour le moment"
            }
            guard let listeDisponibilites = json["records"] as? [[String: AnyObject]] else {
                return "Aucune infos disponibles"
            }
            if type == "Velib" {
                let dicoFields = listeDisponibilites[0]
                let fields = dicoFields["fields"]
                let attachesDispos = (fields?["numdocksavailable"] as? Int16?)!
                let velibsDispos = (fields?["numbikesavailable"] as? Int16?)!
                message = "Attaches disponibles: \(attachesDispos!) velibs disponibles: \(velibsDispos!)"
            } else if type == "AutoLib" {
                let dicoFields = listeDisponibilites[0]
                let fields = dicoFields["fields"]
                let slots = (fields?["slots"] as? Int16?)!
                let cars = (fields?["cars"] as? Int16?)!
                message = "\(cars!) voiture(s) restante(s) et \(slots!) place(s) libre(s)"
            } else if type == "Belibs" {
                let dicoFields = listeDisponibilites[0]
                let fields = dicoFields["fields"]
                let status = (fields?["status_available"] as? String?)!
                if status == "0" {
                    message = "indisponible"
                } else {
                    message = "disponible"
                }
            }
        } catch {
            return "error trying to convert data to JSON"
        }
        return message
    }
}
