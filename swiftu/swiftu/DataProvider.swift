//
//  DataProvider.swift
//  swiftu
//
//  Created by picshertho on 02/10/2016.
//  Copyright © 2016 tru. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataProvider {
    // MARK: singleton
//    static let sharedInstance: DataProvider = {
//        let instance = DataProvider()
//        return instance
//    }()
    
        //static let instance = DataProvider()

    
    var tableauVelib:NSMutableArray? = []
    var tableauAutolib:NSMutableArray? = []
    var tableauTaxis:NSMutableArray? = []
    var tableauArbres:NSMutableArray? = []
    var tableauSanisettes:NSMutableArray? = []
    var tableauCapotes:NSMutableArray? = []
    var tableauFontaines:NSMutableArray? = []
    var tableauBelibs:NSMutableArray? = []
    var tableauCafes:NSMutableArray? = []
    
    var dicCorrespondanceVelib:NSArray? = []
    var typeMapKit:Int?
    var parser:ParseJson? = ParseJson.init()
    
    // MARK: functions
    func selectEntity(nomEntity:String) -> NSMutableArray {
        let results:NSMutableArray?
        let resultFetch = NSFetchRequest<NSFetchRequestResult>(entityName: nomEntity)
        do {
            results = try ((Constants.MANAGED_OBJECT_CONTEXT.execute(resultFetch) as AnyObject as? NSMutableArray))
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        return results! as NSMutableArray
    }
    
    func resultFromSelectWithEntity (nomEntity:String,idKey:String,bSort:Bool,bSave:Bool) -> NSArray {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:nomEntity)
            if (bSort) {
                let sortobjectid = NSSortDescriptor(key: idKey, ascending: true)
                let sortDescriptors = [sortobjectid]
                fetchRequest.sortDescriptors = sortDescriptors
            }
            do {
                let objects = try Constants.MANAGED_OBJECT_CONTEXT.fetch(fetchRequest)
                if(bSave){
                    do {
                        try Constants.MANAGED_OBJECT_CONTEXT.save()
                        
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
                return objects as NSArray
                
            }
            catch {
                fatalError("Failure to fetch request: \(error)")
            }
        }
        return NSArray()
    }
    
    func selectRecordFromEntity (nomEntity:String,field:String,value:String) -> NSArray {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:nomEntity)
            fetchRequest.predicate = NSPredicate(format: "%K == %@",field,value)
            do {
                let objects = try Constants.MANAGED_OBJECT_CONTEXT.fetch(fetchRequest)
                return objects as NSArray
            }
            catch {
                fatalError("Failure to fetch request: \(error)")
            }
        }
        return NSArray()
    }

 
    func updateArrayEntity(nomEntity: String)->NSMutableArray {
        let entity = NSFetchRequest<NSFetchRequestResult>(entityName: nomEntity)
        do {
            let myfetchResult = try Constants.MANAGED_OBJECT_CONTEXT.fetch(entity)
            return NSMutableArray(array:myfetchResult)
        } catch {
            fatalError("Failed to fetch \(nomEntity) : \(error)")
        }
        return []
    }
}

