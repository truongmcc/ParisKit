//
//  MyAnnotation.swift
//  swiftu
//
//  Created by christophe on 28/02/2018.
//  Copyright © 2018 tru. All rights reserved.
//

import MapKit

class MyAnnotation: NSObject, MKAnnotation {
    var serviceViewModel: ServiceViewModel?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var number: String?
    var tag: Int?
    var idRecord: String?
    init(location coord: CLLocationCoordinate2D) {
        self.coordinate = CLLocationCoordinate2D(latitude: (self.serviceViewModel?.coordinate?.latitude)!,
                                                 longitude: (self.serviceViewModel?.coordinate?.longitude)!)
    }
    // MARK: Constructeurs
    init(serviceViewModel: ServiceViewModel) {
        self.coordinate = CLLocationCoordinate2D(latitude: (serviceViewModel.coordinate!.latitude), longitude: (serviceViewModel.coordinate!.longitude))
        self.tag = serviceViewModel.tag
        self.title = serviceViewModel.title
        self.subtitle = serviceViewModel.subtitle
        self.number = serviceViewModel.number
        self.idRecord = serviceViewModel.idRecord
    }
    class func addAnntotation(servicesManagerViewModel: ServicesManagerViewModel, laMap: MKMapView) {
        for service in (servicesManagerViewModel.service as? [Services])! {
            var myAnnotation: MyAnnotation
            if let coord: LocationCoordinate2D = LocationCoordinate2D(latitude: Double(service.coordinateX), longitude: Double(service.coordinateY)) {
                let serviceViewModel = ServiceViewModel(typeService: servicesManagerViewModel.selectedService!, location: coord, service: service)
                myAnnotation = MyAnnotation(serviceViewModel: serviceViewModel)
                laMap.addAnnotation(myAnnotation)
            }
        }
    }
}
