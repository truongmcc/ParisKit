//
//  Downloader.swift
//  swiftu
//
//  Created by picshertho on 01/10/2016.
//  Copyright © 2016 tru. All rights reserved.
//

import Foundation
import Alamofire

class Downloader {
    var data = Data()
    var dynamicValue: String?
//    func dataFromUrl(url:String, type:String) {
//        
//        let urlString = URL(string: url)
//        if let url = urlString {
//            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//                if error != nil {
//                    print(error!)
//                } else {
//                    if let usableData = data {
//                        self.data = usableData
//                        NotificationCenter.default.post(name: Notification.Name("dataContentReceivedNotification"), object: nil, userInfo: ["type":type])
//                    }
//                }
//            }
//            task.resume()
//        }
//    }
    // VERSION ALAMOFIRE
    func dataFromUrl(url: String, type: String) {
        // MODE DATA
        Alamofire.request(url).responseData(completionHandler: { (response) in
            if let data = response.data {
                self.data = data
                Constants.MANAGERDATA.parser?.parse(data: self.data, type: type)
            }
        })
        // mode trailing closure
//        Alamofire.request(url).responseData() { (response) in
//            if let data = response.data {
//                self.data = data
//                Constants.MANAGERDATA.parser?.parse(data: self.data, type: type)
//            }
//        }
        // MODE JSON
//        Alamofire.request(url).responseJSON(completionHandler: { (response) in
//            if let responseJson = response.result.value {
//                if let object = responseJson as? [String: Any] {
//                    print(object)
//                }
//            }
//        })
        // VERSION APPLE
//        func dataFromUrl(url: String, type: String) {
//        let myURL = URL(string: url)!
//        var dataStringOrNil: String?
//        let semaphore = DispatchSemaphore(value: 0)
//        let task = URLSession.shared.dataTask(with: myURL) { (data, _, error) in // _ est le param response
//            defer {
//                semaphore.signal()
//            }
//            guard let data = data, error == nil else {
//                print("error")
//                return
//            }
//            self.data = data
//            NotificationCenter.default.post(name: Notification.Name("dataContentReceivedNotification"),
//                                                object: nil,
//                                                userInfo: ["type": type])
//        }
//        task.resume()
//        semaphore.wait()
    }
//    func dynamiciDataFromUrl(url: String, type: String) {
//        // MODE DATA
//        Alamofire.request(url).responseData(completionHandler: { (response) in
//            if let data = response.data {
//                self.data = data
//                guard let result = Constants.MANAGERDATA.parser?.dynamicParse(data: self.data, type: type) else {
//                    print("pas de valeur dynamiques")
//                    return
//                }
//                self.dynamicValue = result
//            }
//        })
//    }
//     Using a semaphore for synchronous request
    func dynamiciDataFromUrl(url: String, type: String) {
        let myURL = URL(string: url)!
        var dataStringOrNil: String?
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: myURL) { (data, _, error) in // _ est le param response
            defer {
                semaphore.signal()
            }
            guard let data = data, error == nil else {
                print("error")
                return
            }
            self.data = data
            NotificationCenter.default.post(name: Notification.Name("dynamicDataContentReceivedNotification"),
                                            object: nil,
                                            userInfo: ["type": type])
        }
        task.resume()
        semaphore.wait()
    }
}
