//
//  Constants.swift
//  swiftu
//
//  Created by picshertho on 01/10/2016.
//  Copyright © 2016 tru. All rights reserved.
//

import Foundation
import UIKit

struct Constants {

    // MARK: Singleton
    static let MANAGEDOBJECTCONTEXT = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    // MARK: Interets
    struct INTERETS {
        static let ARBRE = 0
        static let PRESERVATIF = 1
        static let FONTAINE = 2
        static let CAFE = 3
        static let SANISETTES = 4
        static let VELIB = 5
        static let AUTOLIB = 6
        static let BELIB = 7
        static let TAXIS = 8
    }
    struct SERVICEORDER {
        static let VELIB = 0
        static let AUTOLIB = 1
        static let TAXIS = 2
        static let ARBRE = 3
        static let SANISETTES  = 4
        static let PRESERVATIF = 5
        static let FONTAINE = 6
        static let BELIB = 7
        static let CAFE = 8
    }
    static let SERVICES = [
        [
            "url": "https://opendata.paris.fr/api/records/1.0/search/?dataset=arbresremarquablesparis2011&rows=500&facet=genre&facet=espece",
            "service": INTERETS.ARBRE,
            "color": UIColor.green,
            "type": "Arbres",
            "entity": "Arbres",
            "field": "recordid",
            "order": SERVICEORDER.ARBRE,
            "listeTabDetail": [Constants.tabListServices[INTERETS.ARBRE]]
        ],
        [
            "url": "https://opendata.paris.fr/api/records/1.0/search/?dataset=distributeurspreservatifsmasculinsparis2012&rows=100&facet=annee_installation&facet=arrond&facet=acces",
            "service": INTERETS.PRESERVATIF,
            "color": UIColor.red,
            "type": "Preservatifs",
            "entity": "Preservatifs",
            "field": "recordid",
            "order": SERVICEORDER.PRESERVATIF,
            "listeTabDetail": [Constants.tabListServices[INTERETS.PRESERVATIF]]
        ],
        [
            "url": "https://opendata.paris.fr/api/records/1.0/search/?dataset=fontaines-a-boire&q=a_boire+%3D+1&rows=915&facet=arro&facet=modele&facet=a_boire",
            "service": INTERETS.FONTAINE,
            "color": UIColor.cyan,
            "type": "Fontaines",
            "entity": "Fontaines",
            "field": "recordid",
            "order": SERVICEORDER.FONTAINE,
            "listeTabDetail": [Constants.tabListServices[INTERETS.FONTAINE]]
        ],
        [
            "type": "Cafes",
            "url": "https://opendata.paris.fr/api/records/1.0/search/?dataset=liste-des-cafes-a-un-euro&q=prix_salle+%3D+%221%22++or+prix_terasse+%3D+%221%22&rows=200&facet=arrondissement",
            "service": INTERETS.CAFE,
            "order": SERVICEORDER.CAFE,
            "color": UIColor.brown
        ],
        [
            "type": "Sanisettes",
            "url": "https://opendata.paris.fr/api/records/1.0/search/?dataset=sanisettesparis2011&rows=1000&facet=arrondissement&facet=horaires_ouverture",
            "service": INTERETS.SANISETTES,
            "order": SERVICEORDER.SANISETTES,
            "color": UIColor.yellow
        ],
        [
            "type": "Velib",
            "url": "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&rows=1300",
            "service": INTERETS.VELIB,
            "order": SERVICEORDER.VELIB,
            "color": UIColor.lightGray,
            "dynamicUrlBegin": "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&q=recordid",
            "dynamicUrlEnd": "%22"
            //https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&q=recordid+%3D+%22e9a4f7a8874ba8dd9b3d004640d99759b3683005%22
        ],
        [
            "type": "AutoLib",
            "url": "https://opendata.paris.fr/api/records/1.0/search/?dataset=autolib-disponibilite-temps-reel&rows=2000&facet=charging_status&facet=kind&facet=postal_code&facet=slots&facet=status&facet=subscription_status",
            "service": INTERETS.AUTOLIB,
            "order": SERVICEORDER.AUTOLIB,
            "color": UIColor.darkGray,
            "dynamicUrlBegin": "https://opendata.paris.fr/api/records/1.0/search/?dataset=autolib-disponibilite-temps-reel&q=id+%3D+",
            "dynamicUrlEnd": "&facet=charging_status&facet=kind&facet=postal_code&facet=slots&facet=status&facet=subscription_status"
        ],
        [
            "type": "Belibs",
            "url": "https://opendata.paris.fr/api/records/1.0/search/?dataset=station-belib&rows=150&facet=geolocation_city&facet=geolocation_locationtype&facet=status_available&facet=static_accessibility_type&facet=static_brand&facet=static_opening_247",
            "service": INTERETS.BELIB,
            "order": SERVICEORDER.BELIB,
            "color": UIColor.blue,
            "dynamicUrlBegin": "https://opendata.paris.fr/api/records/1.0/search/?dataset=station-belib&q=recordid%3D",
            "dynamicUrlEnd": "&rows=1&facet=geolocation_city&facet=geolocation_locationtype&facet=status_available&facet=static_accessibility_type&facet=static_brand&facet=static_opening_247"
        ],
        [
            "type": "Taxis",
            "url": "https://opendata.paris.fr/api/records/1.0/search/?dataset=paris_taxis_stations&rows=150&facet=zip_code&facet=city",
            "service": INTERETS.TAXIS,
            "order": SERVICEORDER.TAXIS,
            "color": UIColor.black
        ]
    ]
    static let dicoType = ["Velib": "velib", "AutoLib": "autolib", "Taxis": "taxi",
                           "Arbres": "arbres", "Sanisettes": "sanisettes",
                           "Preservatifs": "préservatifs", "Fontaines": "fontaines",
                           "Belibs": "belibs", "Cafes": "cafes"] as [String: String]
    static let tabListServices = ["Velibs", "Autolibs", "Taxis", "Arbres remarquables", "Sanisettes", "Préservatifs", "Fontaines à boire", "Stations belib", "Cafés à 1 euro en terasse ou salle"]
    // MARK: detail service
    static let listeTabDetail = [tabDetailArbre, tabDetailPreservatif, tabDetailFontaine, tabDetailCafe]
    static let tabDetailFontaine = [
        [
            "title": "Localisation",
            "property": "localisation"
            ],
        [
            "title": "Modèle",
            "property": "modele"
            ],
        [
            "title": "Classée",
            "property": "classee"
            ],
        [
            "title": "En service",
            "property": "enService"
            ],
        [
            "title": "Ouvert l'hiver",
            "property": "ouvHiver"
            ]
    ]
    static let  tabDetailArbre = [
        [
            "title": "Nom commun",
            "property": "libellefrancais"
            ],
        [
            "title": "Genre",
            "property": "genre"
            ],
        [
            "title": "Espèce",
            "property": "espece"
            ],
        [
            "title": "Hauteur",
            "property": "hauteurenm",
            "unit": " m"
        ],
        [
            "title": "Circonférence",
            "property": "circonferenceencm",
            "unit": " cm"
        ],
        [
            "title": "Date de plantation",
            "property": "dateplantation"
            ],
        [
            "title": "Domanialité",
            "property": "domanialite"
            ]
        ]
    static let tabDetailPreservatif = [
        [
            "title": "Site",
            "property": "site"
            ],
        [
            "title": "Accès",
            "property": "acces"
            ],
        [
            "title": "Horaires",
            "property": "horairesNormales"
            ],
        [
            "title": "Horaires d'été",
            "property": "horairesEte"
            ],
        [
            "title": "Horaires d'hiver",
            "property": "horairesHiver"
            ]
    ]
    static let tabDetailCafe = [
        [
            "title": "Prix en terasse",
            "property": "prixTerasse"
            ],
        [
            "title": "Prix en salle",
            "property": "prixSalle"
            ],
        [
            "title": "Prix au comptoir",
            "property": "prixComptoir"
            ]
    ]

    static let cafeFieldsAndKeys = [
        [
            "field": "arrondissement",
            "key": "arrondissement"
        ],
        [
            "field": "prixTerasse",
            "key": "prix_terasse"
        ],
        [
            "field": "prixComptoir",
            "key": "prix_comptoir"
        ],
        [
            "field": "prixSalle",
            "key": "prix_salle"
        ],
        [
            "field": "nomDuCafe",
            "key": "nom_du_cafe"
        ],
        [
            "field": "adresse",
            "key": "adresse"
        ],
        [
            "field": "coordinateX",
            "key": "geoloc"
        ],
        [
            "field": "coordinateY",
            "key": "geoloc"
        ]
    ]
    static let belibFieldsAndKeys = [
        [
            "field": "aggregatedNbplugs",
            "key": "aggregated_nbplugs"
        ],
        [
            "field": "geolocationPostalcode",
            "key": "geolocation_postalcode"
        ],
        [
            "field": "geolocationRoute",
            "key": "geolocation_route"
        ],
        [
            "field": "geolocationStreetnumber",
            "key": "geolocation_streetnumber"
        ],
        [
            "field": "staticNbparkingspots",
            "key": "static_nbparkingspots"
        ],
        [
            "field": "staticNbstations",
            "key": "static_nbstations"
        ],
        [
            "field": "staticOpening247",
            "key": "static_opening_247"
        ],
        [
            "field": "statusAvailable",
            "key": "status_available"
        ],
        [
            "field": "coordinateX",
            "key": "geolocation_coordinates"
        ],
        [
            "field": "coordinateY",
            "key": "geolocation_coordinates"
        ]
    ]
    static let fontaineFieldsAndKeys = [
        [
            "field": "adresse",
            "key": "adr_s"
        ],
        [
            "field": "classee",
            "key": "classee"
        ],
        [
            "field": "enService",
            "key": "en_service"
        ],
        [
            "field": "localisation",
            "key": "localisati"
        ],
        [
            "field": "modele",
            "key": "modele"
        ],
        [
            "field": "ouvHiver",
            "key": "ouv_hiver"
        ],
        [
            "field": "coordinateX",
            "key": "geo_point_2d"
        ],
        [
            "field": "coordinateY",
            "key": "geo_point_2d"
        ]
    ]
    static let preservatifFieldsAndKeys = [
        [
            "field": "acces",
            "key": "acces"
        ],
        [
            "field": "adresse",
            "key": "adresse_complete"
        ],
        [
            "field": "horairesEte",
            "key": "horaires_vacances_ete"
        ],
        [
            "field": "horairesHiver",
            "key": "horaires_vacances_hiver"
        ],
        [
            "field": "horairesNormales",
            "key": "horaires_normal"
        ],
        [
            "field": "site",
            "key": "site"
        ],
        [
            "field": "coordinateX",
            "key": "xy"
        ],
        [
            "field": "coordinateY",
            "key": "xy"
        ]
    ]
    static let saniesetteFieldsAndKeys = [
        [
            "field": "arrondissement",
            "key": "arrondissement"
        ],
        [
            "field": "horairesOuverture",
            "key": "horaires_ouverture"
        ],
        [
            "field": "nomVoie",
            "key": "nom_voie"
        ],
        [
            "field": "numeroVoie",
            "key": "numero_voie"
        ],
        [
            "field": "coordinateX",
            "key": "geom_x_y"
        ],
        [
            "field": "coordinateY",
            "key": "geom_x_y"
        ]
    ]
    static let arbreFieldsAndKeys = [
        [
            "field": "dateplantation",
            "key": "dateplantation"
        ],
        [
            "field": "adresse",
            "key": "adresse"
        ],
        [
            "field": "espece",
            "key": "espece"
        ],
        [
            "field": "arrondisse",
            "key": "arrondisse"
        ],
        [
            "field": "famille",
            "key": "famille"
        ],
        [
            "field": "libellefrancais",
            "key": "libellefrancais"
        ],
        [
            "field": "genre",
            "key": "genre"
        ],
        [
            "field": "domanialite",
            "key": "domanialite"
        ],
        [
            "field": "hauteurenm",
            "key": "hauteurenm"
        ],
        [
            "field": "nomEv",
            "key": "nom_env"
        ],
        [
            "field": "circonferenceencm",
            "key": "circonferenceencm"
        ],
        [
            "field": "coordinateX",
            "key": "geom_x_y"
        ],
        [
            "field": "coordinateY",
            "key": "geom_x_y"
        ]
    ]
    static let autolibFieldsAndKeys = [
        [
            "field": "recordid",
            "key": "id"
        ],
        [
            "field": "address",
            "key": "address"
        ],
        [
            "field": "postalCode",
            "key": "postal_code"
        ],
        [
            "field": "publicName",
            "key": "public_name"
        ],
        [
            "field": "coordinateX",
            "key": "geo_point"
        ],
        [
            "field": "coordinateY",
            "key": "geo_point"
        ]
    ]
    static let taxiFieldsAndKeys = [
        [
            "field": "address",
            "key": "address"
        ],
        [
            "field": "stationName",
            "key": "station_name"
        ],
        [
            "field": "zipCode",
            "key": "zip_code"
        ],
        [
            "field": "coordinateX",
            "key": "geo_coordinates"
        ],
        [
            "field": "coordinateY",
            "key": "geo_coordinates"
        ]
    ]
    static let velibFieldsAndKeys = [
        [
            "field": "name",
            "key": "name"
        ],
        [
            "field": "coordinateX",
            "key": "xy"
        ],
        [
            "field": "coordinateY",
            "key": "xy"
        ]
    ]
    static var STRUCTSERVICE = [
        "Arbres": [
            "fieldAndKeyStruct": arbreFieldsAndKeys,
            "idKey": "objectid",
            "sort": true
        ],
        "Preservatifs": [
            "fieldAndKeyStruct": preservatifFieldsAndKeys,
            "idKey": "site",
            "sort": false
        ],
        "Fontaines": [
            "fieldAndKeyStruct": fontaineFieldsAndKeys,
            "idKey": "recordid",
            "sort": false
        ],
        "Cafes": [
            "fieldAndKeyStruct": cafeFieldsAndKeys,
            "idKey": "recordid",
            "sort": false
        ],
        "Sanisettes": [
            "fieldAndKeyStruct": saniesetteFieldsAndKeys,
            "idKey": "arrondissement",
            "sort": true
        ],
        "Velib": [
            "fieldAndKeyStruct": velibFieldsAndKeys,
            "idKey": "recordid",
            "sort": true
        ],
        "AutoLib": [
            "fieldAndKeyStruct": autolibFieldsAndKeys,
            "idKey": "nomStation",
            "sort": false
        ],
        "Belibs": [
            "fieldAndKeyStruct": belibFieldsAndKeys,
            "idKey": "recordid",
            "sort": false
        ],
        "Taxis": [
            "fieldAndKeyStruct": taxiFieldsAndKeys,
            "idKey": "zipCode",
            "sort": true
        ]
    ]
}
