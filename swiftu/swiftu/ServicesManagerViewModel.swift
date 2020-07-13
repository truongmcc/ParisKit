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

class ServicesManagerViewModel: NSObject, ServicesUpdateProtocol {
    let disposeBag = DisposeBag()
    var downloader = Downloader()
    // service et selectedService pour l'affichage courrant dans la map
    var service: [AnyObject]? = []
    var selectedService: Int?
    var dicoServices: [String: [AnyObject]] = [
        "Arbres": [AnyObject](),
        "Preservatifs": [AnyObject](),
        "Fontaines": [AnyObject](),
        "Cafes": [AnyObject](),
        "Sanisettes": [AnyObject](),
        "AutoLib": [AnyObject](),
        "Belibs": [AnyObject](),
        "Taxis": [AnyObject](),
        "Velib": [AnyObject]()
    ]
    // MARK: DISPLAYING
    func tabService(typeService: Int) -> [AnyObject]? {
        var tabResult: Array? = [AnyObject]()
        for service in Constants.SERVICES {
            if let pos: Int = service["order"] as? Int {
                if typeService == pos {
                    if let serv = service["type"] as? String {
                        tabResult = dicoServices[serv]
                    }
                }
            }
        }
        return tabResult
    }
    func dynamicSubtitleService(service: Int, idRecord: String) -> String? {
        let startUrl = Constants.SERVICES[service]["dynamicUrlBegin"] as? String
        let endUrl = Constants.SERVICES[service]["dynamicUrlEnd"] as? String
        let stringResult = startUrl?.appending(idRecord).appending(endUrl!)
        return stringResult
    }
    func addServices() {
        for dico in Constants.SERVICES {
            if let url: String = dico["url"] as? String, let type = dico["type"] as? String {
                self.updateService(url: url, type: type)
            }
        }
    }
    func selectService(service: Int) {
        self.selectedService = service
        if let serv = Constants.SERVICES[service]["type"] as? String {
            self.service = self.dicoServices[serv]
        }
    }
    func selectServiceFromMenu(position: Int) {
        self.service = self.tabService(typeService: position)
        for service in Constants.SERVICES {
            if let pos: Int = service["order"] as? Int {
                if position == pos {
                    self.selectedService = service["service"] as? Int
                    break
                }
            }
        }
    }
    // MARK: SERVICESUPDATEPROTOCOL functions
    // MARK: - RXSwift
    func updateService(url: String, type: String) {
        self.downloader.rxDataFromUrl(url: url).subscribe { element in
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
        self.downloader.rxDataFromUrl(url: url).subscribe { element in
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
    // MARK: - Core Data
    func resultFromSelectWithEntity (nomEntity: String, idKey: String, bSort: Bool, bSave: Bool) -> [AnyObject]? {
        var objects = [AnyObject]()
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: nomEntity)
            if bSort {
                let sortobjectid = NSSortDescriptor(key: idKey, ascending: true)
                let sortDescriptors = [sortobjectid]
                fetchRequest.sortDescriptors = sortDescriptors
            }
            do {
                objects = (try Constants.MANAGEDOBJECTCONTEXT?.fetch(fetchRequest))!
                if bSave {
                    do {
                        try Constants.MANAGEDOBJECTCONTEXT?.save()
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
                return objects as [AnyObject]
            } catch {
                fatalError("Failure to fetch request: \(error)")
            }
        }
    }
    func selectRecordFromEntity (nomEntity: String, field: String, value: String) -> [AnyObject]? {
        var objects = [AnyObject]()
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: nomEntity)
            fetchRequest.predicate = NSPredicate(format: "%K == %@", field, value)
            do {
                objects = (try Constants.MANAGEDOBJECTCONTEXT?.fetch(fetchRequest))!
                return objects
            } catch {
                fatalError("Failure to fetch request: \(error)")
            }
        }
    }

    func updateViewModedlFromEntity(nomEntity: String) -> [AnyObject]? {
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
    func updateTabServiceManagerViewModel(typeService: String) {
        self.dicoServices[typeService] = updateViewModedlFromEntity(nomEntity: typeService as String)
    }
    // MARK: Parsing
    func parse(data: Data, type: String) {
        NSLog("parse file data %@", type)
        var fetchResult: [AnyObject]?
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
                        for object in result! {
                            Constants.MANAGEDOBJECTCONTEXT?.delete((object as? NSManagedObject)!)
                        }
                        addNewServices(typeService: type, listeServices: listeServices)
                    }
                } else {
                    updateTabServiceManagerViewModel(typeService: type)
                }
            }
        } catch {
            print("Error")
        }
    }
    func addNewServices(typeService: String, listeServices: [[String: AnyObject]]) {
        DispatchQueue.main.async {
            let structService = Constants.STRUCTSERVICE[typeService]?["fieldAndKeyStruct"] as? [[String: AnyObject]]
            let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
            container?.performBackgroundTask { (context) in
                for dic in listeServices {
                    if let myManagedObject: Services = NSEntityDescription.insertNewObject(forEntityName: typeService as String, into: context ) as? Services {
                        self.createServiceFromJson(service: myManagedObject, structure: structService!, dic: dic as [String: AnyObject])
                    }
                }
                do {
                    try context.save()
                    self.updateTabServiceManagerViewModel(typeService: typeService)
                } catch _ {
                    fatalError("Failure to save context")
                }
            }
        }
    }
    // KVC
    func createServiceFromJson(service: Services, structure: [[String: AnyObject]], dic: [String: AnyObject]) {
        //https://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics
        if let recordid = dic["recordid"] as? String {
            service.setValue(recordid, forKey: "recordid")
            let dicoField = dic["fields"] as? [String: AnyObject]
            for property in structure {
                let field: String? = property["field"] as? String
                let keyDico: String? = (property["key"]) as? String
                if keyDico == "geoloc" || keyDico == "geolocation_coordinates" || keyDico == "geo_point_2d" || keyDico == "xy" || keyDico == "geom_x_y" || keyDico == "geo_point" || keyDico == "geo_coordinates" {
                    guard let coordo = dicoField![keyDico!] as? [Float] else { return }
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
            if listeDisponibilites.count == 1 {
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
            } else {
                return "infos non disponibles pour le moment"
            }

        } catch {
            return "error trying to convert data to JSON"
        }
        return message
    }
    // DetailViewController
    func createDetailViewController(service: Services) -> DetailViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController: DetailViewController! = storyboard.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController
        detailViewController.preferredContentSize = CGSize(width: 300.0, height: 500.0)
        detailViewController?.detailViewModel.service = service
        return detailViewController
    }
}
