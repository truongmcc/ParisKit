//
//  Downloader.swift
//  swiftu
//
//  Created by picshertho on 01/10/2016.
//  Copyright © 2016 tru. All rights reserved.
//

import Foundation

class Downloader {
    var data = Data()
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
    // Using a semaphore for synchronous request
    func dataFromUrl(url: String, type: String) {
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
            // dispatchQueue.main.async pour régler le pb du main thread checker...
            //DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("dataContentReceivedNotification"),
                                                object: nil,
                                                userInfo: ["type": type])
            //}
        }
        task.resume()
        semaphore.wait()
    }
    // Using a semaphore for synchronous request
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
            //DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("dynamicDataContentReceivedNotification"),
                                            object: nil,
                                            userInfo: ["type": type])
            //}
        }
        task.resume()
        semaphore.wait()
    }
}
