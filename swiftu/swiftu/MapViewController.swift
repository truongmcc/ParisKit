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
                self.addAnntotation()
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
        if let urlString = servicesManagerViewModel.dynamicSubtitleService(service: annotationCustom.tag!, idRecord: annotationCustom.idRecord!) {
            let type: String? = Constants.SERVICES[annotationCustom.tag!]["type"] as? String
            servicesManagerViewModel.dynamicUpdateService(url: urlString, type: type!) { (result) in
                annotationCustom.subtitle = result
            }
        } else {
            if let entity: String = Constants.SERVICES[annotationCustom.tag!]["entity"] as? String {
                if let field: String = Constants.SERVICES[annotationCustom.tag!]["field"] as? String {
                    let result = servicesManagerViewModel.selectRecordFromEntity(nomEntity: entity, field: field, value: annotationCustom.idRecord!)
                    let service: Services = (result?.first as? Services)!
                    var detailViewController: DetailViewController?
                    detailViewController = self.createDetailViewController(service: service)
                    detailViewController?.detailViewModel.tabService = Constants.listeTabDetail[annotationCustom.tag!] as [AnyObject]
                    detailViewController?.detailViewModel.service = service
                    self.addChildViewController(detailViewController!)
                    detailViewController?.view.frame = self.view.frame
                    self.view.addSubview((detailViewController?.view)!)
                    detailViewController?.didMove(toParentViewController: self)
                    mapView.deselectAnnotation(annotationCustom, animated: true)
                }
            }
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
    // MARK: Delegate function
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
    // MARK: Buttons
    func updateSelectedButtonItems(position: Int) {
        if position == Constants.SERVICEORDER.AUTOLIB {
            butAutolib.tintColor = UIColor.blue
        } else if position == Constants.SERVICEORDER.VELIB {
            butVelib.tintColor = UIColor.blue
        } else if position == Constants.SERVICEORDER.TAXIS {
            butTaxi.tintColor = UIColor.blue
        }
    }
    func disableServiceButtons() {
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
    }
    // MARK: affichage
    func createDetailViewController(service: Services) -> DetailViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController: DetailViewController! = storyboard.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController
        detailViewController.preferredContentSize = CGSize(width: 300.0, height: 500.0)
        detailViewController?.detailViewModel.service = service
        return detailViewController
    }
    func afficher(position: Int) {
        self.servicesManagerViewModel.selectServiceFromMenu(position: position)
        updateAnnotations()
        updateSelectedButtonItems(position: position)
    }
    func addAnntotation() {
        for service in (self.servicesManagerViewModel.service as? [Services])! {
            var myAnnotation: MyAnnotation
            let coord: LocationCoordinate2D? = LocationCoordinate2D(latitude: service.coordinateX, longitude: service.coordinateY)
            if coord != nil {
                let serviceViewModel = ServiceViewModel(typeService: servicesManagerViewModel.selectedService!, location: coord!, service: service)
                myAnnotation = MyAnnotation(serviceViewModel: serviceViewModel)
                laMap.addAnnotation(myAnnotation)
            }
        }
    }
    func updateAnnotations() {
        removeAnnotations()
        disableServiceButtons()
        self.addAnntotation()
    }
    func removeAnnotations() {
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation)
        }
    }
    override func didReceiveMemoryWarning() {
        NSLog("hello baby")
    }
}
