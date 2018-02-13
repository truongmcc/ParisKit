//
//  MapViewController.swift
//  swiftu
//
//  Created by picshertho on 01/10/2016.
//  Copyright © 2016 tru. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, UIGestureRecognizerDelegate,
                        CLLocationManagerDelegate,
                        MKMapViewDelegate, mapKitDelegate {
    // MARK: IBOutlet
    @IBOutlet weak var butAutolib: UIBarButtonItem!
    @IBOutlet weak var butVelib: UIBarButtonItem!
    @IBOutlet weak var butTaxi: UIBarButtonItem!
    @IBOutlet var laMap: MKMapView!
    @IBOutlet weak var barItem: UIToolbar!
    // --> ?
    @IBOutlet weak var trackingButton: MKUserTrackingBarButtonItem! {
        didSet {
            trackingButton.mapView = laMap
        }
    }
    // <--
    // MARK: Properties
    var tagAnno: Int?
    var tableau = [AnyObject]()
    var locationManager = CLLocationManager()
    var monDownloader = Downloader()
    var optionViewController: OptionsViewController?
    var dynamicMessage: String?
    var subtitleAnnotation: (Bool, String) -> (String) = { (finish, result) in
        if finish {
            return result
        } else {
            print("données non trouvées")
            return result
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        laMap.delegate = self
        locationManager.delegate = self
        location(self)
        self.monDownloader.dataFromUrl(url: Constants.urlVelib, type: "Velib")
        self.monDownloader.dataFromUrl(url: Constants.urlArbres, type: "Arbres")
        self.monDownloader.dataFromUrl(url: Constants.urlSanisettes, type: "Sanisettes")
        self.monDownloader.dataFromUrl(url: Constants.urlCapotes, type: "Capotes")
        self.monDownloader.dataFromUrl(url: Constants.urlFontaines, type: "Fontaines")
        self.monDownloader.dataFromUrl(url: Constants.urlBelib, type: "Belibs")
        self.monDownloader.dataFromUrl(url: Constants.urlCafe, type: "Cafes")
        self.monDownloader.dataFromUrl(url: Constants.urlAutolib, type: "AutoLib")
        self.monDownloader.dataFromUrl(url: Constants.urlTaxi, type: "Taxis")
    }
    // MARK: User Location
    @IBAction func location(_ sender: Any) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            // The user denied authorization
        } else if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        laMap.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
    }
    // MARK: Affichage des services
    @IBAction func afficherService(_ sender: Any) {
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation)
        }
        if let selectedButton: UIBarButtonItem = self.retournerBoutonService(sender: (sender as? UIBarButtonItem)!) {
            if selectedButton.tintColor == UIColor.black {
                selectedButton.tintColor = UIColor.blue
                MyAnnotation.addAnntotation(tag: tagAnno!, tableau: self.tableau as [AnyObject], laMap: self.laMap)
            } else {
                selectedButton.tintColor = UIColor.black
            }
            let allBarButtonItems = barItem.items
            for buttonItem in allBarButtonItems! where buttonItem != selectedButton {
                buttonItem.tintColor = UIColor.black
            }
        }
    }
    func retournerBoutonService(sender: UIBarButtonItem) -> UIBarButtonItem? {
        if sender == butVelib {
            tagAnno = Constants.INTERETS.VELIB
            tableau = Constants.MANAGERDATA.tableauVelib!
        } else if sender == butAutolib {
            tagAnno = Constants.INTERETS.AUTOLIB
            tableau = Constants.MANAGERDATA.tableauAutolib!
        } else if sender == butTaxi {
            tagAnno = Constants.INTERETS.TAXIS
            tableau = Constants.MANAGERDATA.tableauTaxis!
        }
        return sender
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationCustom: MyAnnotation = (annotation as? MyAnnotation)!
        let lcTag = annotationCustom.tag
        let pinIdentifier = "annotationId"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdentifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: pinIdentifier)
        } else {
            annotationView?.annotation = annotationCustom
        }
        annotationView?.canShowCallout = true
        (annotationView as? MKPinAnnotationView)?.animatesDrop = false
        annotationView?.isEnabled = true
        if let colorAnnotation = Constants.SERVICES[lcTag!]["color"] as? UIColor {
             (annotationView as? MKPinAnnotationView)?.pinTintColor = colorAnnotation
        }
        return annotationView
    }
    // on rajoute un bouton detaildisclosure lorsqu'on sélectionne une annotationView
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation { return }
        // -> récupération du tag (utilisation du cast)
        let annotationCustom: MyAnnotation! = view.annotation as? MyAnnotation
        annotationCustom?.prepareForInterfaceBuilder()
        let lcTag: Int = annotationCustom.tag!
        var detailViewController: DetailViewController?
       // let reuseId = "pin"
        if lcTag == Constants.INTERETS.VELIB {
            let idRecord: String = annotationCustom.idRecord!
            var urlString = "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&q=recordid%3D%22"
            urlString = urlString.appending(idRecord).appending("%22")
            self.monDownloader.dynamiciDataFromUrl(url: urlString, type: "Velib") { (finish, result) in
                if finish { annotationCustom.subtitle = result
                } else { annotationCustom.subtitle = "données non disponibles"}
            }
        } else if lcTag == Constants.INTERETS.AUTOLIB {
            let idRecord: String = annotationCustom.idRecord!
            var urlString = "https://opendata.paris.fr/api/records/1.0/search/?dataset=autolib-disponibilite-temps-reel&q=id+%3D+"
            urlString = urlString.appending(idRecord).appending("&facet=charging_status&facet=kind&facet=postal_code&facet=slots&facet=status&facet=subscription_status")
            self.monDownloader.dynamiciDataFromUrl(url: urlString, type: "AutoLib") { (finish, result) in
                annotationCustom.subtitle = self.subtitleAnnotation(finish, result)
            }
//          --> SI JE VEUX UTILISER LE DETAILDISCLOSURE /
//        } else if lcTag == Constants.INTERETS.CAFE {
//            let calloutButton: UIButton = UIButton(type: .detailDisclosure)
//            view.rightCalloutAccessoryView = calloutButton
//            view.isDraggable = false
//            view.isHighlighted = false
//            view.canShowCallout = true
//         <--
        } else if lcTag == Constants.INTERETS.BELIB {
            let idRecord: String = annotationCustom.idRecord!
            let calloutButton: UIButton = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = calloutButton
            view.isDraggable = false ; view.isHighlighted = false ; view.canShowCallout = true
            var urlString = "https://opendata.paris.fr/api/records/1.0/search/?dataset=station-belib&q=recordid%3D"
            urlString = urlString.appending(idRecord).appending("&rows=1&facet=geolocation_city&facet=geolocation_locationtype&facet=status_available&facet=static_accessibility_type&facet=static_brand&facet=static_opening_247")
            self.monDownloader.dynamiciDataFromUrl(url: urlString, type: "Belibs") { (finish, result) in
                if finish { annotationCustom.subtitle = result } else { annotationCustom.subtitle = "données non disponibles"}
            }
           // annotationCustom.subtitle = self.dynamicMessage
        } else { // arbres, fontaines, preservatifs
            if let entity: String = Constants.SERVICES[lcTag]["entity"] as? String {
                if let field: String = Constants.SERVICES[lcTag]["field"] as? String {
                    let result = Constants.MANAGERDATA.selectRecordFromEntity(nomEntity: entity, field: field, value: annotationCustom.idRecord!)
                    let service: Services = (result.firstObject as? Services)!
                    detailViewController = self.createDetailViewController(service: service)
                    detailViewController?.tabService = Constants.listeTabDetail[lcTag] as [AnyObject]
                    self.addChildViewController(detailViewController!)
                    detailViewController?.view.frame = self.view.frame
                    self.view.addSubview((detailViewController?.view)!)
                    detailViewController?.didMove(toParentViewController: self)
                    mapView.deselectAnnotation(annotationCustom, animated: true)
                }
            }
        }
    }
    func createDetailViewController(service: AnyObject) -> DetailViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController: DetailViewController! = storyboard.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController
        detailViewController.preferredContentSize = CGSize(width: 300.0, height: 500.0)
        detailViewController?.service = service
        return detailViewController
    }
    // delegate sur appui sur le bouton disclosure
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let annotationCustom = view.annotation as? MyAnnotation
        if annotationCustom?.tag == Constants.INTERETS.CAFE {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController: DetailViewController! = storyboard.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController
            detailViewController.preferredContentSize = CGSize(width: 300.0, height: 500.0)
            let result = Constants.MANAGERDATA.selectRecordFromEntity(nomEntity: "Cafes", field: "recordid", value: (annotationCustom?.idRecord!)!)
            let  cafe: Cafes = (result.firstObject as? Cafes)!
            detailViewController.service = cafe
            detailViewController.adresse = cafe.adresse
            detailViewController.tabService = Constants.listeTabDetail[Constants.INTERETS.CAFE] as [AnyObject]
            self.addChildViewController(detailViewController)
            detailViewController.view.frame = self.view.frame
            self.view.addSubview(detailViewController.view)
            detailViewController.didMove(toParentViewController: self)
            mapView.deselectAnnotation(annotationCustom, animated: true)
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapIdentifier" {
            let optionViewController: OptionsViewController? = segue.destination as? OptionsViewController
            optionViewController?.delegate = self
            optionViewController?.mapType = self.laMap.mapType.rawValue
        }
    }
    // MARK: mapKitDelegate
    func changerTypeMap(type: Int) {
        switch type {
        case 0:
            laMap.mapType = .standard
        case 1:
            laMap.mapType = .satellite
        default:
            laMap.mapType = .hybrid
        }
    }
    func afficherTaxis() {
        if butTaxi.tintColor == UIColor.black {
            self.afficherService(butTaxi)
        }
    }
    func afficherVelib() {
        if butVelib.tintColor == UIColor.black {
            self.afficherService(butVelib)
        }
    }
    func afficherAutolib() {
        if butAutolib.tintColor == UIColor.black {
            self.afficherService(butAutolib)
        }
    }
    func afficherArbres() {
        tagAnno = Constants.INTERETS.ARBRE
        tableau = Constants.MANAGERDATA.tableauArbres!
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation)
        }
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
        MyAnnotation.addAnntotation(tag: tagAnno!, tableau: self.tableau, laMap: self.laMap)
    }
    func afficherSanisettes() {
        tagAnno = Constants.INTERETS.SANISETTES
        tableau = Constants.MANAGERDATA.tableauSanisettes!
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation)
        }
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
        MyAnnotation.addAnntotation(tag: tagAnno!, tableau: self.tableau, laMap: self.laMap)
    }
    func afficherCapotes() {
        tagAnno = Constants.INTERETS.CAPOTES
        tableau = Constants.MANAGERDATA.tableauCapotes!
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation)
        }
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
        MyAnnotation.addAnntotation(tag: tagAnno!, tableau: self.tableau, laMap: self.laMap)
    }
    func afficherFontaines() {
        tagAnno = Constants.INTERETS.FONTAINE
        tableau = Constants.MANAGERDATA.tableauFontaines!
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation)
        }
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
        MyAnnotation.addAnntotation(tag: tagAnno!, tableau: self.tableau, laMap: self.laMap)
    }
    func afficherBelibs() {
        tagAnno = Constants.INTERETS.BELIB
        tableau = Constants.MANAGERDATA.tableauBelibs!
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation)
        }
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
        MyAnnotation.addAnntotation(tag: tagAnno!, tableau: self.tableau, laMap: self.laMap)
    }
    func afficherCafes() {
        tagAnno = Constants.INTERETS.CAFE
        tableau = Constants.MANAGERDATA.tableauCafes!
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation)
        }
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
        MyAnnotation.addAnntotation(tag: tagAnno!, tableau: self.tableau, laMap: self.laMap)
    }
}
