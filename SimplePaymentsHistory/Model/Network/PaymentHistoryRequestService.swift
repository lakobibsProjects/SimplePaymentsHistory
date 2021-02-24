//
//  PaymentHistoryRequestService.swift
//  SimplePaymentsHistory
//
//  Created by user166683 on 2/22/21.
//  Copyright © 2021 Lakobib. All rights reserved.
//

import Foundation
import Alamofire

class PaymentHistoryRequestService: PaymentHistoryRequestObservable{    
    internal lazy var observers = [PaymentHistoryRequestObserver]()
    
    private let thread  = DispatchQueue.global(qos: .userInitiated)
    private let defaultURL = "http://82.202.204.94/api/payments"
    
    private let headers = [
        "app-key": "12345",
        "v": "1"
    ]
    
    /// Autorization request
    ///
    /// - parameter token: user token
    func paymentHistoryRequest(token: String){
        //1. insert params
        let parameters = [
            "token": "\(token)"
        ]
        thread.async {
            //2. generate request
            let request = AF.request(self.defaultURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: HTTPHeaders(self.headers)).responseJSON { response in
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    print(error)
                }
            }
            
            //3. response request
            request.responseJSON(completionHandler: { response in
                var result = [PaymentRecord]()
                //payment record tags
                let amountString = "amount"
                let createdString = "created"
                let currencyString = "currency"
                let descString = "desc"
                //3.1 remove from request excess data
                var arrayString = response.description.suffix(from: response.description.firstIndex(of: "{")!)
                arrayString = arrayString.prefix(upTo: arrayString.lastIndex(of: "}")!)
                arrayString = arrayString.suffix(from: arrayString.lastIndex(of: "(")!)
                arrayString = arrayString.prefix(upTo: arrayString.lastIndex(of: ")")!)
                
                //3.2 response to array of payment records
                var end = false
                while !end{
                    //response has next item
                    if let lastIndex = arrayString.firstIndex(of: ","){
                        //create thumb payment record
                        var payment = PaymentRecord(amount: 0.0, created: 0, currency: nil, desc: "")
                        //extract amount
                        if let lb  = arrayString.range(of: amountString)?.lowerBound {
                            let suffix = arrayString.suffix(from: lb)
                            let prefix = suffix.prefix(upTo: suffix.firstIndex(of: ";")!)
                            var result = (prefix.suffix(from: prefix.firstIndex(of: "=")!))
                            if result.contains("\""){
                                result = result.dropFirst(4)
                                result = result.dropLast()
                            }else{
                                result = result.dropFirst(2)
                            }
                            
                            let amount = Double(result)
                            if let amount = amount{
                                payment.amount = amount
                            }
                        }
                        //extract cration date
                        if let lb  = arrayString.range(of: createdString)?.lowerBound {
                            let suffix = arrayString.suffix(from: lb)
                            let prefix = suffix.prefix(upTo: suffix.firstIndex(of: ";")!)
                            var result = (prefix.suffix(from: prefix.firstIndex(of: "=")!))
                            result = result.dropFirst(2)
                            
                            let created = Int(result)
                            if let created = created{
                                payment.created = created
                            }
                        }
                        //extract currency
                        if let lb  = arrayString.range(of: currencyString)?.lowerBound {
                            if lb < lastIndex{
                                let suffix = arrayString.suffix(from: lb)
                                let prefix = suffix.prefix(upTo: suffix.firstIndex(of: ";")!)
                                var result = (prefix.suffix(from: prefix.firstIndex(of: "=")!))
                                result = result.dropFirst(2)
                                
                                let currency = String(result)
                                payment.currency = currency
                            }                            
                        }
                        //extract description
                        if let lb  = arrayString.range(of: descString)?.lowerBound {
                            let suffix = arrayString.suffix(from: lb)
                            let prefix = suffix.prefix(upTo: suffix.firstIndex(of: ";")!)
                            var result = (prefix.suffix(from: prefix.firstIndex(of: "=")!))
                            result = result.dropFirst(2)
                            
                            let desc = String(result)
                            payment.desc = desc
                        }
                        //remove record from response string
                        arrayString = arrayString.suffix(from: lastIndex)
                        arrayString = arrayString.dropFirst()
                        //add record to result array
                        result.append(payment)
                    } else{
                        end = true
                    }
                    
                    //3.3 send observers responsed array of payment history
                    DispatchQueue.main.async {
                        self.notify(paymentHistory: result)
                    }
                }
            })
        }
    }
}

protocol PaymentHistoryRequestObservable: AnyObject{
    var observers:  [PaymentHistoryRequestObserver]{get set}
    
    func attach(_ observer: PaymentHistoryRequestObserver)
    
    func detach(_ observer: PaymentHistoryRequestObserver)
    
    func notify(paymentHistory: [PaymentRecord])
}

extension PaymentHistoryRequestObservable{
    
    func attach(_ observer: PaymentHistoryRequestObserver) {
        observers.append(observer)
    }
    
    func detach(_ observer: PaymentHistoryRequestObserver) {
        observers = observers.filter({$0.id != observer.id})
    }
    
    func notify(paymentHistory: [PaymentRecord]) {
        observers.forEach({ $0.update(paymentHistory: paymentHistory)})
    }
}

protocol PaymentHistoryRequestObserver{
    var id: Int {get}
    func update(paymentHistory: [PaymentRecord])
}
