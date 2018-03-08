//
//  ServiceViewModel.swift
//  swiftu
//
//  Created by christophe on 07/03/2018.
//  Copyright © 2018 tru. All rights reserved.
//

import UIKit

struct LocationCoordinate2D {
    var latitude: Double
    var longitude: Double
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
class ServiceViewModel: NSObject {
    var coordinate: LocationCoordinate2D?
    var title: String?
    var subtitle: String?
    var number: String?
    var tag: Int?
    var idRecord: String?
    init(location coord: LocationCoordinate2D) {
        self.coordinate = coord
    }
    func updateInfoService( service: Services) {
        if let optionalIdRecord = service.recordid {
            self.idRecord = optionalIdRecord
            self.title = service.detailTitle()
            if  ((service as? Taxis) != nil) || ((service as? Sanisettes) != nil) || ((service as? Cafes) != nil) {
                self.subtitle = service.detailSubTitle()
            }
        }
    }
    init(typeService: Int, location coord: LocationCoordinate2D, service: Services) {
        super.init()
        self.coordinate = coord
        self.tag = typeService
        updateInfoService(service: service)
    }
}
