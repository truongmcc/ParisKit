//
//  MyAnnotation.swift
//  swiftu
//
//  Created by picshertho on 06/11/2016.
//  Copyright © 2016 tru. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var number: String?
    var tag: Int?
    var idRecord: String?
    init(location coord: CLLocationCoordinate2D) {
        self.coordinate = coord
        super.init()
    }
    // MARK: Constructeurs
    init(typeService: Int, location coord: CLLocationCoordinate2D, service: Services) {
        self.coordinate = coord
        self.tag = typeService
        if let optionalIdRecord = service.recordid {
            self.idRecord = optionalIdRecord
        }
        // initialiser self.title pour permetre l'affichage de la date de l'annotation
        self.title = " "
        if let velib = service as? Velib {
            self.title = velib.name
        } else if let autolib = service as? AutoLib {
            let address: String = autolib.address!
            let codePostal =  autolib.postal_code!
            self.title = String.init(format: "%@ %@", address as String, codePostal as String)
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
            if let nomVoie = belib.geolocation_route, let numerovoie = belib.geolocation_streetnumber {
                adresse = numerovoie + ", " + nomVoie
            }
            self.title = adresse
        } else if let cafe = service as? Cafes {
            self.title = cafe.nom_du_cafe
            if let adresse = cafe.adresse {
                self.subtitle = "\(adresse) \(cafe.arrondissement)" // String.init(format: "%@ %@", adresse, String(cafe.arrondissement))
            }
        }
        super.init()
    }
    class func addAnntotation(tag: Int, tableau: [AnyObject], laMap: MKMapView) {
        var annotation: MyAnnotation
        for service in (tableau as? [Services])! {
            let coord: CLLocationCoordinate2D? = CLLocationCoordinate2DMake (CLLocationDegrees(service.coordinateX), CLLocationDegrees(service.coordinateY))
            if coord != nil {
                annotation = MyAnnotation(typeService: tag, location: coord!, service: service)
                laMap.addAnnotation(annotation)
            }
        }
    }

}
