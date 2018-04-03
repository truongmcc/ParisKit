//
//  ServicesUpdateProtocol.swift
//  swiftu
//
//  Created by christophe on 06/03/2018.
//  Copyright © 2018 tru. All rights reserved.
//

import Foundation

protocol ServicesUpdateProtocol {
    // MARK: RXSWIFT
    func updateService(url: String, type: String)
    func dynamicUpdateService(url: String, type: String, result: @escaping (String) -> Void)
    // MARK: CORE DATA
    func resultFromSelectWithEntity (nomEntity: String, idKey: String, bSort: Bool, bSave: Bool) -> [AnyObject]?
    func selectRecordFromEntity (nomEntity: String, field: String, value: String) -> [AnyObject]?
    func updateViewModedlFromEntity(nomEntity: String) -> [AnyObject]?
    // MARK: PARSING
    func parse(data: Data, type: String)
    func addNewServices(typeService: String, listeServices: [[String: AnyObject]])
    func createServiceFromJson(service: Services, structure: [[String: AnyObject]], dic: [String: AnyObject])
    func dynamicParse(data: Data, type: String) -> String?
}
