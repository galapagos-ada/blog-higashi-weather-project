//
//  WeatherClient.swift
//  SampleProject
//
//  Created by hideto.higashi on 2022/12/20.
//

import Foundation
import ComposableArchitecture

struct WeatherClient {
    var fetchAreaList: @Sendable () async throws -> AreaModel
    var fetchWeatherInfomation: @Sendable (_ areaCode: String) async throws -> WeatherModel
}

extension DependencyValues {
    var weatherClient: WeatherClient {
        get { self[WeatherClient.self] }
        set { self[WeatherClient.self] = newValue }
    }
}

extension WeatherClient: DependencyKey {
    static var liveValue: WeatherClient {
        Value(fetchAreaList: {
            let areApiUrl: String = "https://www.jma.go.jp/bosai/common/const/area.json"
            let (data, _) = try await APICaller.shared.fetch(url: areApiUrl)
            let jsonDecoder = JSONDecoder()
            try await Task.sleep(nanoseconds: 500_000_000)
            return try jsonDecoder.decode(AreaModel.self, from: data)
        }, fetchWeatherInfomation: { areaCode in
            let weatherApiUrl: String = "https://www.jma.go.jp/bosai/forecast/data/forecast/\(areaCode).json"
            let (data, _) = try await APICaller.shared.fetch(url: weatherApiUrl)
            let dictData = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [Any]
            let json = try JSONSerialization.data(withJSONObject: dictData)
            return try APICaller.shared.decode(data: json)
        })
    }

    static var testValue: WeatherClient {
        Value(fetchAreaList: {
            let areApiUrl: String = "https://www.jma.go.jp/bosai/common/const/area.json"
            let (data, _) = try await APICaller.shared.fetch(url: areApiUrl)
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(AreaModel.self, from: data)
        }, fetchWeatherInfomation: { areaCode in
            let weatherApiUrl: String = "https://www.jma.go.jp/bosai/forecast/data/forecast/\(areaCode).json"
            let (data, _) = try await APICaller.shared.fetch(url: weatherApiUrl)
            let dictData = try JSONSerialization.jsonObject(with: data) as! [Any]
            let json = try JSONSerialization.data(withJSONObject: dictData)
            return try APICaller.shared.decode(data: json)
        })
    }
}
