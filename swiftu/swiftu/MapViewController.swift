//
//  MapViewController.swift
//  swiftu
//
//  Created by picshertho on 01/10/2016.
//  Copyright © 2016 tru. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController,UIGestureRecognizerDelegate,CLLocationManagerDelegate,MKMapViewDelegate,mapKitDelegate {

    //MARK:IBOutlet
    @IBOutlet weak var butAutolib: UIBarButtonItem!
    @IBOutlet weak var butVelib: UIBarButtonItem!
    @IBOutlet weak var butTaxi: UIBarButtonItem!
    @IBOutlet var laMap:MKMapView!
    @IBOutlet weak var barItem: UIToolbar!
    
    // --> ?
    @IBOutlet weak var trackingButton: MKUserTrackingBarButtonItem! {
        didSet {
            trackingButton.mapView = laMap;
        }
    }
    // <--
    
    //MARK:Properties
    var tagAnno:Int?
    var tableau:NSMutableArray? = []
    var locationManager = CLLocationManager()
    var monDownloader = Downloader()
    var optionViewController: OptionsViewController?
    var dynamicMessage:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        laMap.delegate = self
        locationManager.delegate = self
        location(self)
        
        //--> notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(parseFromNotif(notification:)),
            name: NSNotification.Name(rawValue: "dataContentReceivedNotification"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dynamicParseFromNotif(notification:)),
            name: NSNotification.Name(rawValue: "dynamicDataContentReceivedNotification"),
            object: nil)
        //<--

        // from bundle
        Constants.MANAGER_DATA.parser?.parseFileWithType(type:"Velib")
        Constants.MANAGER_DATA.parser?.parseFileWithType(type:"Taxis")
        // from url
        self.monDownloader.dataFromUrl(url:Constants.urlAutolib,type:"AutoLib")
        self.monDownloader.dataFromUrl(url:Constants.urlArbres,type:"Arbres")
        self.monDownloader.dataFromUrl(url:Constants.urlSanisettes,type:"Sanisettes")
        self.monDownloader.dataFromUrl(url:Constants.urlCapotes,type:"Capotes")
        self.monDownloader.dataFromUrl(url:Constants.urlFontaines,type:"Fontaines")
        //self.monDownloader.dataFromUrl(url:Constants.urlBelib,type:"Belibs")
        self.monDownloader.dataFromUrl(url:Constants.urlCafe,type:"Cafes")
    }
    
    @objc func parseFromNotif(notification:Notification) {
        if let type = notification.userInfo?["type"] {
            NSLog("parseFromNotif %@",type as! String)
            Constants.MANAGER_DATA.parser?.parse(data:self.monDownloader.data,type:type as! String)
        }
    }
    
    @objc func dynamicParseFromNotif(notification:Notification) {
        if let type = notification.userInfo?["type"] {
            NSLog("dynamicParseFromNotif %@",type as! String)
            self.dynamicMessage = Constants.MANAGER_DATA.parser?.dynamicParse(data:self.monDownloader.data,type:type as! String)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("dataContentReceivedNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("dynamicDataContentReceivedNotification"), object: nil)
    }
    
    //MARK:User Location
    @IBAction func location(_ sender: Any) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            // The user denied authorization
        } else if (status == CLAuthorizationStatus.authorizedWhenInUse) {
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

    //MARK:Affichage des services
    @IBAction func afficherService(_ sender: Any) {
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation);
        }
        let selectedButton:UIBarButtonItem = self.retournerBoutonService(sender:sender as! UIBarButtonItem)
        if (selectedButton.tintColor == UIColor.black) {
            selectedButton.tintColor = UIColor.blue
            MyAnnotation.addAnntotation(tag:tagAnno!,tableau:self.tableau!,laMap:self.laMap)
        } else {
            selectedButton.tintColor = UIColor.black
        }
        
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            if (buttonItem != selectedButton) {
                buttonItem.tintColor = UIColor.black
            }
        }
    }
    
    func retournerBoutonService(sender:UIBarButtonItem)->UIBarButtonItem {
        if (sender == butVelib) {
            tagAnno = Constants.INTERETS.VELIB;
            tableau = Constants.MANAGER_DATA.tableauVelib;
        } else if (sender == butAutolib) {

            tagAnno = Constants.INTERETS.AUTOLIB;
            tableau = Constants.MANAGER_DATA.tableauAutolib!;
        } else if (sender == butTaxi) {
            
            tagAnno = Constants.INTERETS.TAXIS;
            tableau = Constants.MANAGER_DATA.tableauTaxis!;
        }
        return sender
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        let annotationCustom:MyAnnotation = annotation as! MyAnnotation
        let lcTag = annotationCustom.tag
        let pinIdentifier = "annotationId"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdentifier)
        
        if (annotationView == nil ) {
            annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: pinIdentifier)
        } else {
            annotationView?.annotation = annotationCustom
        }
        annotationView?.canShowCallout = true
        (annotationView as! MKPinAnnotationView).animatesDrop = false
        annotationView?.isEnabled = true
        
        if (lcTag == Constants.INTERETS.VELIB) {
            (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.lightGray
        } else if (lcTag == Constants.INTERETS.AUTOLIB) {
            (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.darkGray
        } else if (lcTag == Constants.INTERETS.ARBRE) {
            (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.green
        } else if (lcTag == Constants.INTERETS.TAXIS) {
            (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.black
        } else if (lcTag == Constants.INTERETS.SANISETTES) {
            (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.yellow
        } else if (lcTag == Constants.INTERETS.CAPOTES) {
            (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.red
        } else if (lcTag == Constants.INTERETS.FONTAINE) {
            (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.cyan
        } else if (lcTag == Constants.INTERETS.BELIB) {
            (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.blue
        } else if (lcTag == Constants.INTERETS.CAFE) {
            (annotationView as! MKPinAnnotationView).pinTintColor = UIColor.brown
        }
        return annotationView
    }
    
    // on rajoute un bouton detaildisclosure lorsqu'on sélectionne une annotationView
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if (view.annotation is MKUserLocation) {
            return
        }
        // -> récupération du tag (utilisation du cast)
        let annotationCustom = view.annotation as! MyAnnotation
        annotationCustom.prepareForInterfaceBuilder()
        let lcTag:Int = annotationCustom.tag!
        
       // let reuseId = "pin"
        if (lcTag == Constants.INTERETS.VELIB) {
            let number:String = annotationCustom.number!
            var urlString = "https://api.jcdecaux.com/vls/v1/stations/"
            urlString = urlString.appending(number)
            urlString = urlString.appending("/?contract=Paris&apiKey=f6b16206b4d7753e702784d6f7df149b2142da22")
            self.monDownloader.dynamiciDataFromUrl(url:urlString,type:"Velib")
            annotationCustom.subtitle = self.dynamicMessage
        } else if (lcTag == Constants.INTERETS.AUTOLIB) {
            let id:String = annotationCustom.id!
            var urlString = "https://opendata.paris.fr/api/records/1.0/search/?dataset=autolib-disponibilite-temps-reel&q=id+%3D+"
            urlString = urlString.appending(id)
            urlString = urlString.appending("&facet=charging_status&facet=kind&facet=postal_code&facet=slots&facet=status&facet=subscription_status")
            self.monDownloader.dynamiciDataFromUrl(url:urlString,type:"AutoLib")
            annotationCustom.subtitle = self.dynamicMessage
//        } else if (lcTag == Constants.INTERETS.CAFE) {
//            let calloutButton:UIButton = UIButton(type: .detailDisclosure)
//            view.rightCalloutAccessoryView = calloutButton
//            view.isDraggable = false;
//            view.isHighlighted = false;
//            view.canShowCallout = true;
        } else if (lcTag == Constants.INTERETS.BELIB) {
            let id:String = annotationCustom.id!
            let calloutButton:UIButton = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = calloutButton
            view.isDraggable = false;
            view.isHighlighted = false;
            view.canShowCallout = true;
            var urlString = "https://opendata.paris.fr/api/records/1.0/search/?dataset=station-belib&q=recordid%3D"
            urlString = urlString.appending(id)
            urlString = urlString.appending("&rows=1&facet=geolocation_city&facet=geolocation_locationtype&facet=status_available&facet=static_accessibility_type&facet=static_brand&facet=static_opening_247")
            self.monDownloader.dynamiciDataFromUrl(url:urlString,type:"Belibs")
            annotationCustom.subtitle = self.dynamicMessage
        } else if (lcTag == Constants.INTERETS.ARBRE) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController = storyboard.instantiateViewController(withIdentifier :"detailViewController") as! DetailViewController
            detailViewController.preferredContentSize = CGSize(width: 300.0, height: 500.0)
            let result = Constants.MANAGER_DATA.selectRecordFromEntity(nomEntity: "Arbres",field: "recordid",value: annotationCustom.id!)
            let  arbre:Arbres = result.firstObject as! Arbres
            detailViewController.service = arbre
            detailViewController.adresse = arbre.adresse
            detailViewController.tabService = Constants.listeTabDetail[Constants.INTERETS.ARBRE] as Array<AnyObject>
            self.addChildViewController(detailViewController)
            detailViewController.view.frame = self.view.frame
            self.view.addSubview(detailViewController.view)
            detailViewController.didMove(toParentViewController: self)
            mapView.deselectAnnotation(annotationCustom, animated: true)
        } else if (lcTag == Constants.INTERETS.CAPOTES) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController = storyboard.instantiateViewController(withIdentifier :"detailViewController") as! DetailViewController
            detailViewController.preferredContentSize = CGSize(width: 300.0, height: 500.0)
            let result = Constants.MANAGER_DATA.selectRecordFromEntity(nomEntity: "Capotes",field: "recordid",value: annotationCustom.id!)
            let  capote:Capotes = result.firstObject as! Capotes
            detailViewController.service = capote
            detailViewController.adresse = capote.adresse
            detailViewController.tabService = Constants.listeTabDetail[Constants.INTERETS.CAPOTES] as Array<AnyObject>
            self.addChildViewController(detailViewController)
            detailViewController.view.frame = self.view.frame
            self.view.addSubview(detailViewController.view)
            detailViewController.didMove(toParentViewController: self)
            mapView.deselectAnnotation(annotationCustom, animated: true)
        } else if (lcTag == Constants.INTERETS.FONTAINE) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController = storyboard.instantiateViewController(withIdentifier :"detailViewController") as! DetailViewController
            detailViewController.preferredContentSize = CGSize(width: 300.0, height: 500.0)
            let result = Constants.MANAGER_DATA.selectRecordFromEntity(nomEntity: "Fontaines",field: "recordid",value: annotationCustom.id!)
            let  fontaine:Fontaines = result.firstObject as! Fontaines
            detailViewController.service = fontaine
            detailViewController.adresse = fontaine.adresse
            detailViewController.tabService = Constants.listeTabDetail[Constants.INTERETS.FONTAINE] as Array<AnyObject>
            self.addChildViewController(detailViewController)
            detailViewController.view.frame = self.view.frame
            self.view.addSubview(detailViewController.view)
            detailViewController.didMove(toParentViewController: self)
            mapView.deselectAnnotation(annotationCustom, animated: true)
        }
    }

    // delegate sur appui sur le bouton disclosure
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let annotationCustom = view.annotation as! MyAnnotation
        if (annotationCustom.tag == Constants.INTERETS.CAFE) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController = storyboard.instantiateViewController(withIdentifier :"detailViewController") as! DetailViewController
            detailViewController.preferredContentSize = CGSize(width: 300.0, height: 500.0)
            let result = Constants.MANAGER_DATA.selectRecordFromEntity(nomEntity: "Cafes",field: "recordid",value: annotationCustom.id!)
            let  cafe:Cafes = result.firstObject as! Cafes
            detailViewController.service = cafe
            detailViewController.adresse = cafe.adresse
            detailViewController.tabService = Constants.listeTabDetail[Constants.INTERETS.CAFE] as Array<AnyObject>
            self.addChildViewController(detailViewController)
            detailViewController.view.frame = self.view.frame
            self.view.addSubview(detailViewController.view)
            detailViewController.didMove(toParentViewController: self)
            mapView.deselectAnnotation(annotationCustom, animated: true)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "mapIdentifier") {
            let optionViewController:OptionsViewController = segue.destination as! OptionsViewController
            optionViewController.delegate = self
            optionViewController.mapType = self.laMap.mapType.rawValue
        }
    }

    //MARK:mapKitDelegate
    func changerTypeMap(type: Int) {
        switch (type) {
        case 0:
            laMap.mapType = .standard
        case 1:
            laMap.mapType = .satellite
        default:
            laMap.mapType = .hybrid
        }
    }
    
    func afficherTaxis() {
        if(butTaxi.tintColor == UIColor.black) {
            self.afficherService(butTaxi)
        }
    }
    
    func afficherVelib() {
        if(butVelib.tintColor == UIColor.black) {
            self.afficherService(butVelib)
        }
    }
    
    func afficherAutolib() {
        if(butAutolib.tintColor == UIColor.black) {
            self.afficherService(butAutolib)
        }
    }
    
    
    func afficherArbres() {
        tagAnno = Constants.INTERETS.ARBRE;
        tableau = Constants.MANAGER_DATA.tableauArbres;
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation);
        }
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
        MyAnnotation.addAnntotation(tag:tagAnno!,tableau:self.tableau!,laMap:self.laMap)
    }
    
    func afficherSanisettes() {
        tagAnno = Constants.INTERETS.SANISETTES;
        tableau = Constants.MANAGER_DATA.tableauSanisettes;
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation);
        }
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
        MyAnnotation.addAnntotation(tag:tagAnno!,tableau:self.tableau!,laMap:self.laMap)
    }
    
    func afficherCapotes() {
        tagAnno = Constants.INTERETS.CAPOTES;
        tableau = Constants.MANAGER_DATA.tableauCapotes;
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation);
        }
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
        MyAnnotation.addAnntotation(tag:tagAnno!,tableau:self.tableau!,laMap:self.laMap)
    }
    
    func afficherFontaines() {
        tagAnno = Constants.INTERETS.FONTAINE;
        tableau = Constants.MANAGER_DATA.tableauFontaines;
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation);
        }
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
        MyAnnotation.addAnntotation(tag:tagAnno!,tableau:self.tableau!,laMap:self.laMap)
    }
    
    func afficherBelibs() {
        tagAnno = Constants.INTERETS.BELIB;
        tableau = Constants.MANAGER_DATA.tableauBelibs;
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation);
        }
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
        MyAnnotation.addAnntotation(tag:tagAnno!,tableau:self.tableau!,laMap:self.laMap)
    }
    
    func afficherCafes() {
        tagAnno = Constants.INTERETS.CAFE;
        tableau = Constants.MANAGER_DATA.tableauCafes;
        for annotation in laMap.annotations {
            laMap.removeAnnotation(annotation);
        }
        let allBarButtonItems = barItem.items
        for buttonItem in allBarButtonItems! {
            buttonItem.tintColor = UIColor.black
        }
        MyAnnotation.addAnntotation(tag:tagAnno!,tableau:self.tableau!,laMap:self.laMap)
    }
}


