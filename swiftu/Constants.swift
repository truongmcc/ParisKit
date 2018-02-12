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

    // MARK: Singletons
    static let MANAGERDATA = DataProvider()
    static let MANAGEDOBJECTCONTEXT = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    // MARK: URLs
    static let urlArbres = "https://opendata.paris.fr/api/records/1.0/search/?dataset=arbresremarquablesparis2011&rows=500&facet=genre&facet=espece"
    static let urlSanisettes = "https://opendata.paris.fr/api/records/1.0/search/?dataset=sanisettesparis2011&rows=1000&facet=arrondissement&facet=horaires_ouverture"
    static let urlAutolib = "https://opendata.paris.fr/api/records/1.0/search/?dataset=autolib-disponibilite-temps-reel&rows=2000&facet=charging_status&facet=kind&facet=postal_code&facet=slots&facet=status&facet=subscription_status"
    static let urlCapotes = "https://opendata.paris.fr/api/records/1.0/search/?dataset=distributeurspreservatifsmasculinsparis2012&rows=100&facet=annee_installation&facet=arrond&facet=acces"
    static let urlFontaines = "https://opendata.paris.fr/api/records/1.0/search/?dataset=fontaines-a-boire&q=a_boire+%3D+1&rows=915&facet=arro&facet=modele&facet=a_boire"
    static let urlBelib = "https://opendata.paris.fr/api/records/1.0/search/?dataset=station-belib&rows=150&facet=geolocation_city&facet=geolocation_locationtype&facet=status_available&facet=static_accessibility_type&facet=static_brand&facet=static_opening_247"
    static let urlCafe = "https://opendata.paris.fr/api/records/1.0/search/?dataset=liste-des-cafes-a-un-euro&q=prix_salle+%3D+%221%22++or+prix_terasse+%3D+%221%22&rows=200&facet=arrondissement"
    static let urlVelib = "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&rows=1300"
    // MARK: Interets
    struct INTERETS {
        static let ARBRE = 0
        static let CAPOTES = 1
        static let FONTAINE = 2
        static let CAFE = 3
        static let SANISETTES = 4
        static let VELIB = 5
        static let AUTOLIB = 6
        static let BELIB = 7
        static let TAXIS = 8
    }
    static let SERVICES = [
        [
            "service": INTERETS.ARBRE,
            "color": UIColor.green,
            "entity": "Arbres",
            "field": "recordid",
             "listeTabDetail": [Constants.tabListServices[INTERETS.ARBRE]]
        ],
        [
            "service": INTERETS.CAPOTES,
            "color": UIColor.red,
            "entity": "Capotes",
            "field": "recordid",
             "©": [Constants.tabListServices[INTERETS.CAPOTES]]
        ],
        [
            "service": INTERETS.FONTAINE,
            "color": UIColor.cyan,
            "entity": "Fontaines",
            "field": "recordid",
            "listeTabDetail": [Constants.tabListServices[INTERETS.FONTAINE]]
        ],
        [
            "service": INTERETS.CAFE,
            "color": UIColor.brown
        ],
        [
            "service": INTERETS.SANISETTES,
            "color": UIColor.yellow
        ],
        [
            "service": INTERETS.VELIB,
            "color": UIColor.lightGray
        ],
        [
            "service": INTERETS.AUTOLIB,
            "color": UIColor.darkGray
        ],
        [
            "service": INTERETS.BELIB,
            "color": UIColor.blue
        ],
        [
            "service": INTERETS.TAXIS,
            "color": UIColor.black
        ]
    ]
    static let dicoType = ["Velib": "velib", "AutoLib": "autolib", "Taxis": "taxi",
                           "Arbres": "arbres", "Sanisettes": "sanisettes",
                           "Capotes": "capotes", "Fontaines": "fontaines",
                           "Belibs": "belibs", "Cafes": "cafes"] as [String: String]
    static let tabListServices = ["Velibs", "Autolibs", "Taxis", "Arbres remarquables", "Sanisettes", "Préservatifs", "Fontaines à boire", "Stations belib", "Cafés à 1 euro en terasse ou salle"]
    // MARK: detail service
    static let listeTabDetail = [
        tabDetailArbre, // 0
        tabDetailCapote, // 1
        tabDetailFontaine, // 2
        tabDetailCafe // 3
    ]
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
            "property": "en_service"
            ],
        [
            "title": "Ouvert l'hiver",
            "property": "ouv_hiver"
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
    static let tabDetailCapote = [
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
            "property": "prix_terasse"
            ],
        [
            "title": "Prix en salle",
            "property": "prix_salle"
            ],
        [
            "title": "Prix au comptoir",
            "property": "prix_comptoir"
            ]
    ]

    static let cafeFieldsAndKeys = [
        [
            "field": "arrondissement",
            "key": "arrondissement"
        ],
        [
            "field": "prix_terasse",
            "key": "prix_terasse"
        ],
        [
            "field": "prix_comptoir",
            "key": "prix_comptoir"
        ],
        [
            "field": "prix_salle",
            "key": "prix_salle"
        ],
        [
            "field": "nom_du_cafe",
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
            "field": "aggregated_nbplugs",
            "key": "aggregated_nbplugs"
        ],
        [
            "field": "geolocation_postalcode",
            "key": "geolocation_postalcode"
        ],
        [
            "field": "geolocation_route",
            "key": "geolocation_route"
        ],
        [
            "field": "geolocation_streetnumber",
            "key": "geolocation_streetnumber"
        ],
        [
            "field": "static_nbparkingspots",
            "key": "static_nbparkingspots"
        ],
        [
            "field": "static_nbstations",
            "key": "static_nbstations"
        ],
        [
            "field": "static_opening_247",
            "key": "static_opening_247"
        ],
        [
            "field": "status_available",
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
            "field": "en_service",
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
            "field": "ouv_hiver",
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
    static let capoteFieldsAndKeys = [
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
            "field": "horaires_ouverture",
            "key": "horaires_ouverture"
        ],
        [
            "field": "nom_voie",
            "key": "nom_voie"
        ],
        [
            "field": "numero_voie",
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
            "field": "nom_ev",
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
            "field": "postal_code",
            "key": "postal_code"
        ],
        [
            "field": "public_name",
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
            "field": "station_name",
            "key": "station_name"
        ],
        [
            "field": "zip_code",
            "key": "zip_code"
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
    
    static let velibFieldsAndKeys = [
        [
            "field": "name",
            "key": "name"
        ],
        [
            "field": "station_id",
            "key": "station_id"
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
}
