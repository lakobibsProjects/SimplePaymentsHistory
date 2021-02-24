//
//  AuthRequestService.swift
//  SimplePaymentsHistory
//
//  Created by user166683 on 2/22/21.
//  Copyright © 2021 Lakobib. All rights reserved.
//

import Foundation
import Alamofire

class AuthRequestService: AuthObservable{
    internal lazy var observers: [AuthObserver] = [AuthObserver]()
    
    private let thread  = DispatchQueue.global(qos: .userInteractive)
    private let defaultURL = "http://82.202.204.94/api/login"
    
    private let headers = [
        "app-key": "12345",
        "v": "1"
    ]
    
    ///Requset autorization
    ///
    /// - parameter login: input login
    /// - parameter password: imput password
    func authRequest(login: String, password: String){
        let parameters = [
            "login": "login",
            "password": "password"
        ]
        thread.async {
            let request = AF.request(self.defaultURL,
                                     method: .post,
                                     parameters: parameters,
                                     encoding: URLEncoding.default,
                                     headers: HTTPHeaders(self.headers))
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        break
                    case .failure(let error):
                        self.notify(authResult: false, token: nil, error: error.localizedDescription)
                    }
            }
            
            var token: String? = nil
            var success: String? = nil
            let tokenString = "token"
            let soccessString = "success"
            request.responseJSON(completionHandler: { response in
                let description = response.description.suffix(from: response.description.firstIndex(of: "{")!)
                if let lb  = description.range(of: tokenString)?.lowerBound {
                    let suffix = description.suffix(from: lb)
                    let prefix = suffix.prefix(upTo: suffix.firstIndex(of: ";")!)
                    var result = (prefix.suffix(from: prefix.firstIndex(of: "=")!))
                    result = result.dropFirst(2)
                    //TODO: Save token to UserDefaults
                    token = String(result)
                }
                
                if let lb  = description.range(of: soccessString)?.lowerBound {
                    let suffix = description.suffix(from: lb)
                    let prefix = suffix.prefix(upTo: suffix.firstIndex(of: ";")!)
                    var result = (prefix.suffix(from: prefix.firstIndex(of: "=")!))
                    result = result.dropFirst(2)
                    success = String(result)
                }
                
                if success! == "true"{
                    DispatchQueue.main.async {
                        self.notify(authResult: true, token: token, error: nil)
                    }                    
                } else{
                    DispatchQueue.main.async {
                        self.notify(authResult: false, token: nil, error: "Autorization failed")
                    }
                }
            })
        }
    }
}

protocol AuthObservable: AnyObject{
    var observers:  [AuthObserver]{get set}
    
    func attach(_ observer: AuthObserver)
    
    func detach(_ observer: AuthObserver)
    
    func notify(authResult: Bool, token: String?, error: String?)
}

extension AuthObservable{
    
    func attach(_ observer: AuthObserver) {
        observers.append(observer)
    }
    
    func detach(_ observer: AuthObserver) {
        observers = observers.filter({$0.id != observer.id})
    }
    
    func notify(authResult: Bool, token: String?, error: String? = nil) {
        observers.forEach({ $0.update(result: authResult, token: token, error: error)})
    }
}

protocol AuthObserver{
    var id: Int {get}
    func update(result: Bool, token: String?, error: String?)
}
