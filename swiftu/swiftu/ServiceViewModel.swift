//
//  ServiceViewModel.swift
//  swiftu
//
//  Created by christophe on 28/02/2018.
//  Copyright © 2018 tru. All rights reserved.
//

import UIKit

class ServiceViewModel: NSObject {
    var service: Services
    init(service: Services) {
        self.service = service
        super.init()
    }
}
