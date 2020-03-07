//
//  Structs.swift
//  Sleep
//
//  Created by Angelo Domingo on 3/7/20.
//  Copyright © 2020 Angelo Domingo. All rights reserved.
//

import Foundation

enum BackendUrl: String {
    case url = "http://ec2-18-144-89-176.us-west-1.compute.amazonaws.com"
}

enum Endpoints : String{
    case storeSleep = "/storesleep"
    case getAvgHours = "/getavgsleep"
    case weather = "/weather"
}

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

struct JSON {
    static let encoder = JSONEncoder()
}
extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSON.encoder.encode(self))) as? [String: Any] ?? [:]
    }
}
