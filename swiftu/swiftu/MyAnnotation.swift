//
//  MyAnnotation.swift
//  swiftu
//
//  Created by picshertho on 06/11/2016.
//  Copyright © 2016 tru. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MyAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title:String?
    var subtitle:String?
    var number:String?
    var tag:Int?
    var id:String?
    init(location coord:CLLocationCoordinate2D) {
        self.coordinate = coord
        super.init()
    }
    
    //MARK:Constructeurs
    init(location coord:CLLocationCoordinate2D, velib:Velib) {
        self.coordinate = coord
        self.tag = Constants.INTERETS.VELIB
        self.number = String(format:"%d",velib.number)
        let title = velib.name!
        let index2 = title.range(of: "-")?.lowerBound
        var subString = title[index2!...]
        subString.remove(at: subString.startIndex)
        self.title = String(subString)
        super.init()
    }
    
    init(location coord:CLLocationCoordinate2D, autolib:AutoLib) {
        self.coordinate = coord
        self.tag = Constants.INTERETS.AUTOLIB;
        self.id = autolib.id!
        let address:String = autolib.address!
        let codePostal =  autolib.postal_code!
        self.title = String.init(format: "%@ %@", address as String, codePostal as String)
        super.init()
    }
    
    init(location coord:CLLocationCoordinate2D, taxi:Taxis) {
        self.coordinate = coord
        self.tag = Constants.INTERETS.TAXIS;
        self.title = taxi.station_name
        self.subtitle = String.init(format:"%@ %@",taxi.address!,taxi.zip_code!)
        super.init()
    }
    
    init(location coord:CLLocationCoordinate2D, sanisette:Sanisettes) {
        self.coordinate = coord
        self.tag = Constants.INTERETS.SANISETTES;
        self.coordinate = coord;
        var adresse:String?
        if let nomVoie = sanisette.nom_voie {
            if let numeroVoie = sanisette.numero_voie {
                adresse = numeroVoie + ", " + nomVoie
            }
        }
        self.title = adresse
        if (sanisette.horaires_ouverture != nil) {
            self.subtitle = String.init(format:"%@",sanisette.horaires_ouverture!)
        } else {
            self.subtitle = "Horaires inconnues"
        }
        
        super.init()
    }
    
    init(location coord:CLLocationCoordinate2D, belib:Belibs) {
        self.coordinate = coord
        self.tag = Constants.INTERETS.BELIB
        self.id = belib.recordid
        var adresse:String?
        if let nomVoie = belib.geolocation_route {
            if let numerovoie = belib.geolocation_streetnumber {
                adresse = numerovoie + ", " + nomVoie
            }
        }
        self.title = adresse
        super.init()
    }
    
    init(location coord:CLLocationCoordinate2D, arbre:Arbres) {
        self.coordinate = coord
        self.tag = Constants.INTERETS.ARBRE;
        self.id = arbre.recordid
        // initialiser self.title pour permmetre l'affichate de l'annotation
        self.title = " "
        super.init()
    }
    
    init(location coord:CLLocationCoordinate2D, capote:Capotes) {
        self.coordinate = coord
        self.tag = Constants.INTERETS.CAPOTES
        self.id = capote.recordid
        self.title = " "
        super.init()
    }
    
    init(location coord:CLLocationCoordinate2D, fontaine:Fontaines) {
        self.coordinate = coord
        self.tag = Constants.INTERETS.FONTAINE
        self.id = fontaine.recordid
        self.title = " "
        super.init()
    }
    
    init(location coord:CLLocationCoordinate2D, cafe:Cafes) {
        self.coordinate = coord
        self.tag = Constants.INTERETS.CAFE
        self.id = cafe.recordid
        self.title = cafe.nom_du_cafe
        self.subtitle = String.init(format:"%@ %d", cafe.adresse!,cafe.arrondissement)
     
        super.init()
    }
    
    //MARK: méthode de classe
    class func addAnntotation(tag:Int, tableau:[AnyObject],laMap:MKMapView) {
        var annotation:MyAnnotation
        if tag == Constants.INTERETS.VELIB {
            for velib:Velib in tableau as! [Velib] {
                let coord:CLLocationCoordinate2D? = CLLocationCoordinate2DMake (CLLocationDegrees(velib.latitude), CLLocationDegrees(velib.longitude))
                if coord != nil {
                    annotation = MyAnnotation(location: coord!, velib:velib)
                    laMap.addAnnotation(annotation)
                }
            }
        } else if tag == Constants.INTERETS.AUTOLIB {
            for autolib: AutoLib in tableau as! [AutoLib]{
                let coord:CLLocationCoordinate2D? = CLLocationCoordinate2DMake (CLLocationDegrees(autolib.coordinateX), CLLocationDegrees(autolib.coordinateY))
                if coord != nil {
                    annotation = MyAnnotation(location:coord!, autolib:autolib)
                    laMap.addAnnotation(annotation)
                }
            }
        } else if tag == Constants.INTERETS.ARBRE {
            for arbre: Arbres in tableau as! [Arbres] {
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees((arbre).coordinateX),CLLocationDegrees((arbre).coordinateY));
                annotation = MyAnnotation(location:coord, arbre:arbre)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.SANISETTES {
            for sanisette: Sanisettes in tableau as! [Sanisettes] {
                let coord: CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees(sanisette.coordinateX), CLLocationDegrees(sanisette.coordinateY))
                annotation = MyAnnotation(location:coord, sanisette:sanisette)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.TAXIS {
            for taxi:Taxis in tableau as! [Taxis] {
                let coord: CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees(taxi.coordX), CLLocationDegrees(taxi.coordY))
                annotation = MyAnnotation(location:coord, taxi:taxi)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.CAPOTES {
            for capote: Capotes in tableau as! [Capotes] {
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees(capote.coordinateX),CLLocationDegrees(capote.coordinateY))
                annotation = MyAnnotation(location:coord, capote:capote)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.FONTAINE {
            for fontaine:Fontaines in tableau as! [Fontaines]{
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees(fontaine.coordinateX),CLLocationDegrees(fontaine.coordinateY))
                annotation = MyAnnotation(location:coord, fontaine:fontaine)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.BELIB {
            for belib: Belibs in tableau as! [Belibs] {
                let coord: CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees(belib.coordinateX), CLLocationDegrees(belib.coordinateY))
                annotation = MyAnnotation(location: coord, belib: belib)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.CAFE {
            for cafe: Cafes in tableau as! [Cafes] {
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees(cafe.coordinateX), CLLocationDegrees(cafe.coordinateY))
                annotation = MyAnnotation(location: coord, cafe:cafe)
                laMap.addAnnotation(annotation)
            }
        }
    }

}
