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
            self.title = " "
            if let velib = service as? Velib {
                self.title = velib.name
            } else if let autolib = service as? AutoLib {
                if let address: String = autolib.address, let codePostal =  autolib.postal_code {
                    self.title = address + " " + codePostal
                }
            } else if let taxi = service as? Taxis {
                self.title = taxi.station_name
                self.subtitle = String.init(format: "%@ %@", taxi.address!, taxi.zip_code!)
            } else if let sanisette = service as? Sanisettes {
                var adresse: String?
                if let nomVoie = sanisette.nom_voie, let numeroVoie = sanisette.numero_voie {
                    adresse = numeroVoie + ", " + nomVoie
                }
                self.title = adresse
                if sanisette.horaires_ouverture != nil {
                    self.subtitle = String.init(format: "%@", sanisette.horaires_ouverture!)
                } else {
                    self.subtitle = "Horaires inconnues"
                }
            } else if let belib = service as? Belibs {
                var adresse: String?
                if let nomVoie = belib.geolocation_route, let numeroVoie = belib.geolocation_streetnumber {
                    adresse = numeroVoie + ", " + nomVoie
                }
                self.title = adresse
            } else if let cafe = service as? Cafes {
                self.title = cafe.nom_du_cafe
                if let adresse = cafe.adresse {
                    self.subtitle = "\(adresse) \(cafe.arrondissement)"
                }
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
