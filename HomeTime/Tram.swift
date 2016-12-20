//
//  Tram.swift
//  HomeTime
//
//  Created by Padraig Robinson on 18/12/16.
//  Copyright © 2016 REA. All rights reserved.
//

import Foundation

struct Tram {
    let destination          : String
    let predictedArrivalDate : Date
    let routeNo              : String
}

extension Tram {
    init?(json: JSON) {
        guard let destination     = json["Destination"]          as? String,
            let arrivalDateString = json["PredictedArrivalDateTime"] as? String,
            let routeNo           = json["RouteNo"]              as? String,
            let arrivalDate       = arrivalDateString.dateFromDotNetFormatted() else { return nil }

        self.destination = destination
        self.predictedArrivalDate = arrivalDate
        self.routeNo = routeNo
    }
}
