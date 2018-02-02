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
    static let dicoType = ["Velib": "velib", "AutoLib": "autolib", "Taxis": "taxi",
                           "Arbres": "arbres", "Sanisettes": "sanisettes",
                           "Capotes": "capotes", "Fontaines": "fontaines",
                           "Belibs": "belibs", "Cafes": "cafes"] as [String: String]
    static let tabListServices = ["Velibs", "Autolibs", "Taxis", "Arbres remarquables", "Sanisettes", /*"Préservatifs", */"Fontaines à boire", /*"Stations belib", */"Cafés à 1 euro en terasse ou salle"]
    // MARK: detail service
    static let listeTabDetail = [
        tabDetailArbre, // 0
        tabDetailCapote, // 1
        tabDetailFontaine // 2
        //tabDetailCafe // 3
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
    static let  tabDetailCapote = [
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
//    static let  tabDetailCafe = [
//        [
//            "title": "Prix en terasse",
//            "property": "prix_terasse"
//            ],
//        [
//            "title": "Prix en salle",
//            "property": "prix_salle"
//            ],
//        [
//            "title": "Prix au comptoir",
//            "property": "prix_comptoir"
//            ]
//    ]

}
