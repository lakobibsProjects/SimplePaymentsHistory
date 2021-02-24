//
//  PaymentStruct.swift
//  SimplePaymentsHistory
//
//  Created by user166683 on 2/22/21.
//  Copyright © 2021 Lakobib. All rights reserved.
//

import Foundation

struct PaymentRecord: Decodable {
    var amount: Double
    var created: Int
    var currency: String?    
    var desc: String
}
