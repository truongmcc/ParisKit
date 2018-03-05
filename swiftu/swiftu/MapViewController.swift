//
//  MapViewController.swift
//  swiftu
//
//  Created by picshertho on 01/10/2016.
//  Copyright © 2016 tru. All rights reserved.
//

import UIKit
import MapKit
import RxCocoa
import RxSwift

class MapViewController: UIViewController, UIGestureRecognizerDelegate,
                        CLLocationManagerDelegate,
                        MKMapViewDelegate, mapKitDelegate {
    // MARK: IBOutlet
    @IBOutlet var laMap: MKMapView!
    @IBOutlet weak var butAutolib: UIBarButtonItem!
    @IBOutlet weak var butVelib: UIBarButtonItem!
    @IBOutlet weak var butTaxi: UIBarButtonItem!
    @IBOutlet weak var barItem: UIToolbar!
    @IBOutlet weak var trackingButton: MKUserTrackingBarButtonItem! {
        didSet { trackingButton.mapView = laMap }
    }
    // <--
    // MARK: Properties
    var servicesManagerViewModel = ServicesManagerViewModel()
    var locationManager = CLLocationManager()
    var optionViewController: OptionsViewController?
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        laMap.delegate = self
        locationManager.delegate = self
        location(self)
        servicesManagerViewModel.addServices()
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
        removeAnnotations()
        if let selectedButton: UIBarButtonItem = self.retournerBoutonService(sender: (sender as? UIBarButtonItem)!) {
            self.servicesManagerViewModel.selectService(service: (sender as AnyObject).tag)
            if selectedButton.tintColor == UIColor.black {
                selectedButton.tintColor = UIColor.blue
                MyAnnotationServiceViewModel.addAnntotation(servicesManagerViewModel: self.servicesManagerViewModel, laMap: self.laMap)
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
        return sender
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationCustom: MyAnnotationServiceViewModel = (annotation as? MyAnnotationServiceViewModel)!
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
        let annotationCustom: MyAnnotationServiceViewModel! = view.annotation as? MyAnnotationServiceViewModel
        annotationCustom?.prepareForInterfaceBuilder()
        let idRecord: String = annotationCustom.idRecord!
        let lcTag: Int = annotationCustom.tag!
        var detailViewController: DetailViewController?
        if lcTag == Constants.INTERETS.VELIB {
            var urlString = "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&q=recordid%3D%22"
            urlString = urlString.appending(idRecord).appending("%22")
            servicesManagerViewModel.dynamicUpdateService(url: urlString, type: "Velib") { (result) in
                annotationCustom.subtitle = result
            }
        } else if lcTag == Constants.INTERETS.AUTOLIB {
            var urlString = "https://opendata.paris.fr/api/records/1.0/search/?dataset=autolib-disponibilite-temps-reel&q=id+%3D+"
            urlString = urlString.appending(idRecord).appending("&facet=charging_status&facet=kind&facet=postal_code&facet=slots&facet=status&facet=subscription_status")
            servicesManagerViewModel.dynamicUpdateService(url: urlString, type: "AutoLib") { (result) in
                annotationCustom.subtitle = result
            }
        } else if lcTag == Constants.INTERETS.BELIB {
            var urlString = "https://opendata.paris.fr/api/records/1.0/search/?dataset=station-belib&q=recordid%3D"
            urlString = urlString.appending(idRecord).appending("&rows=1&facet=geolocation_city&facet=geolocation_locationtype&facet=status_available&facet=static_accessibility_type&facet=static_brand&facet=static_opening_247")
            servicesManagerViewModel.dynamicUpdateService(url: urlString, type: "Belibs") { (result) in
                annotationCustom.subtitle = result
            }
            //          --> POUR UTILISER LE DETAILDISCLOSURE /
            //        } else if lcTag == Constants.INTERETS.CAFE {
            //            let calloutButton: UIButton = UIButton(type: .detailDisclosure)
            //            view.rightCalloutAccessoryView = calloutButton
            //            view.isDraggable = false
            //            view.isHighlighted = false
            //            view.canShowCallout = true
            //         <--
        } else { // arbres, fontaines, preservatifs
            if let entity: String = Constants.SERVICES[lcTag]["entity"] as? String {
                if let field: String = Constants.SERVICES[lcTag]["field"] as? String {
                    let result = servicesManagerViewModel.selectRecordFromEntity(nomEntity: entity, field: field, value: annotationCustom.idRecord!)
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
        let annotationCustom = view.annotation as? MyAnnotationServiceViewModel
        if annotationCustom?.tag == Constants.INTERETS.CAFE {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController: DetailViewController! = storyboard.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController
            detailViewController.preferredContentSize = CGSize(width: 300.0, height: 500.0)
            let result = servicesManagerViewModel.selectRecordFromEntity(nomEntity: "Cafes", field: "recordid", value: (annotationCustom?.idRecord)!)
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
    // UTILISER DELEGATE POUR MAJ COULEUR BOUTON
//    func afficherTaxis() {
//        if butTaxi.tintColor == UIColor.black {
//            self.afficherService(butTaxi)
//        }
//    }
//    func afficherVelib() {
//        if butVelib.tintColor == UIColor.black {
//            self.afficherService(butVelib)
//        }
//    }
//    func afficherAutolib() {
//        if butAutolib.tintColor == UIColor.black {
//            self.afficherService(butAutolib)
//        }
//    }
    func afficher(position: Int) {
        self.servicesManagerViewModel.service = self.servicesManagerViewModel.tabService(typeService: position)
        for service in Constants.SERVICES {
            if let pos: Int = service["order"] as? Int {
                if position == pos {
                    self.servicesManagerViewModel.selectedService = service["service"] as? Int
                    break
                }
            }
        }
        updateAnnotations()
        updateSelectedButtonItems(position: position)
    }
    func updateSelectedButtonItems(position: Int) {
        if position == Constants.SERVICEORDER.AUTOLIB {
            butAutolib.tintColor = UIColor.blue
        } else if position == Constants.SERVICEORDER.VELIB {
            butVelib.tintColor = UIColor.blue
        } else if position == Constants.SERVICEORDER.TAXIS {
            butTaxi.tintColor = UIColor.blue
        }
    }
    func removeAnnotations() {
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation)
        }
    }
    func disableServiceButtons() {
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
    }
    func updateAnnotations() {
        removeAnnotations()
        disableServiceButtons()
        MyAnnotationServiceViewModel.addAnntotation(servicesManagerViewModel: self.servicesManagerViewModel, laMap: self.laMap)
    }
}
