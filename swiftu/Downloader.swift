//
//  Downloader.swift
//  swiftu
//
//  Created by picshertho on 01/10/2016.
//  Copyright © 2016 tru. All rights reserved.
//
//  Check others implementations with oldDownloader File //

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class Downloader {
    var data = Data()
    var dynamicValue: String?
    // ALAMOFIRE & RXSWIFT version
    func rxDataFromUrl(url: String) -> Observable<Data> {
        return Observable<Data>.create({ (observer) -> Disposable in
            Alamofire.request(url).responseData(completionHandler: { (response) in
                if let err = response.error {
                    // If there's an error, send an Error event and finish the sequence
                    observer.onError(err)
                } else {
                    if let data = response.data {
                        observer.onNext(data)
                    } else {
                        observer.onNext(Data())
                    }
                    //Complete the sequence
                    observer.onCompleted()
                }
            })
            //task.resume()
            //Return an AnonymousDisposable
            return Disposables.create(with: {
                //Cancel the connection if disposed
                //task.cancel()
            })
        })
    }
}
