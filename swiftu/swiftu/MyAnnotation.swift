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
        var title = velib.name!
        let index2 = title.range(of: "-")?.lowerBound
        title = title.substring(from: index2!)
        title.remove(at: title.startIndex)
        self.title = title;
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
    class func addAnntotation(tag:Int, tableau:NSMutableArray,laMap:MKMapView) {
        var annotation:MyAnnotation
        if tag == Constants.INTERETS.VELIB {
            for velib in tableau {
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees((velib as? Velib)!.latitude),CLLocationDegrees((velib as! Velib).longitude));
                annotation = MyAnnotation(location: coord, velib:(velib as? Velib)!)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.AUTOLIB {
            for autolib in tableau {
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees((autolib as! AutoLib).coordinateX),CLLocationDegrees((autolib as! AutoLib).coordinateY))
                annotation = MyAnnotation(location:coord, autolib:(autolib as? AutoLib)!)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.ARBRE {
            for arbre in tableau {
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees((arbre as? Arbres)!.coordinateX),CLLocationDegrees((arbre as! Arbres).coordinateY));
                annotation = MyAnnotation(location:coord, arbre:arbre as! Arbres)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.SANISETTES {
            for sanisette in tableau {
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees((sanisette as! Sanisettes).coordinateX),CLLocationDegrees((sanisette as! Sanisettes).coordinateY))
                annotation = MyAnnotation(location:coord, sanisette:sanisette as! Sanisettes)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.TAXIS {
            for taxi in tableau {
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees((taxi as! Taxis).coordX),CLLocationDegrees((taxi as! Taxis).coordY));
                annotation = MyAnnotation(location:coord, taxi:taxi as! Taxis)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.CAPOTES {
            for capote in tableau {
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees((capote as! Capotes).coordinateX),CLLocationDegrees((capote as! Capotes).coordinateY));
                annotation = MyAnnotation(location:coord, capote:capote as! Capotes)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.FONTAINE {
            for fontaine in tableau {
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees((fontaine as! Fontaines).coordinateX),CLLocationDegrees((fontaine as! Fontaines).coordinateY));
                annotation = MyAnnotation(location:coord, fontaine:fontaine as! Fontaines)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.BELIB {
            for belib in tableau {
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees((belib as! Belibs).coordinateX),CLLocationDegrees((belib as! Belibs).coordinateY));
                annotation = MyAnnotation(location:coord, belib:belib as! Belibs)
                laMap.addAnnotation(annotation)
            }
        } else if tag == Constants.INTERETS.CAFE {
            for cafe in tableau {
                let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake (CLLocationDegrees((cafe as! Cafes).coordinateX),CLLocationDegrees((cafe as! Cafes).coordinateY));
                annotation = MyAnnotation(location:coord, cafe:cafe as! Cafes)
                laMap.addAnnotation(annotation)
            }
        }
    }

}
