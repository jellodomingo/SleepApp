//
//  Structs.swift
//  Sleep
//
//  Created by Angelo Domingo on 3/7/20.
//  Copyright © 2020 Angelo Domingo. All rights reserved.
//

import Foundation

struct Location : Encodable {
    var lat: Double
    var lng: Double
}

struct StoreSleepRequest : Encodable{
    var date: String
    var start: String
    var end: String
}

struct GetAvgSleepResponse : Decodable {
    var age: String
}

struct WeatherRequest : Encodable {
    var lat: String
    var lon: String
}

struct WeatherResponse : Decodable {
    var recommendation: String
}
