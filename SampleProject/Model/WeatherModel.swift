//
//  WeatherModel.swift
//  SampleProject
//
//  Created by hideto.higashi on 2022/12/20.
//

import Foundation

struct WeatherModel: Codable, Equatable {
    var publishingOffice: String = ""
    var reportDatetime: String = ""
    var timeSeries: [TimeSeries] = []
    var tempAverage: TempAverage?
    var precipAverage: PrecipAverage?

    struct TimeSeries: Codable, Equatable {
        let timeDefines: [String]
        let areas: [Area]
    }

    struct Area: Codable, Equatable {
        let area: AreaDetail?
        let weatherCodes: [String]?
        let weathers: [String]?
        let winds: [String]?
        let waves: [String]?
        let pops: [String]?
        let reliabilities: [String]?
        let temps: [String]?
        let tempsMax: [String]?
        let tempsMin: [String]?
        let tempsMaxUpper: [String]?
        let tempsMaxLower: [String]?
        let tempsMinUpper: [String]?
        let tempsMinLower: [String]?
    }

    struct AreaDetail: Codable, Equatable {
        let name: String
        let code: String
    }

    struct TempAverage: Codable, Equatable {
        let areas: [TempAverageDetail]
    }

    struct TempAverageDetail: Codable, Equatable {
        let area: AreaDetail
        let min: String
        let max: String
    }

    struct PrecipAverage: Codable, Equatable {
        let areas: [PrecipAverageDetail]
    }

    struct PrecipAverageDetail: Codable, Equatable {
        let area: AreaDetail
        let min: String
        let max: String
    }
}
