//
//  SampleProjectTests.swift
//  SampleProjectTests
//
//  Created by hideto.higashi on 2022/12/20.
//

import XCTest
import ComposableArchitecture

@testable import SampleProject

@MainActor
final class SampleProjectTests: XCTestCase {
    typealias State = WeatherStore.State
    typealias Reducer = WeatherStore

    func testAreaAPI() async throws {
        let store = TestStore(initialState: State(), reducer: Reducer())
        let data = try await store.dependencies.weatherClient.fetchAreaList()
        print(type(of: data.offices))
    }

    func testWeatherAPI() async throws {
        let store = TestStore(initialState: State(), reducer: Reducer())
        store.exhaustivity = .off
        let data = try await store.dependencies.weatherClient.fetchWeatherInfomation("130000")
        print(data)
    }
}
