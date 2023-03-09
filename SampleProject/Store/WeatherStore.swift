//
//  WeatherStore.swift
//  SampleProject
//
//  Created by hideto.higashi on 2022/12/20.
//

import Foundation
import ComposableArchitecture
import UIKit

struct WeatherStore: ReducerProtocol {
    struct State: Equatable {
        var areaOffices: [OfficeModel] = []
        var areaWeather: WeatherModel = WeatherModel()
        var isLoading: Bool = false
        var currentIndex: Int = 0
        var alert: AlertState<Action>?
        var searchBarText: String?
        var placeholder: String? = "都道府県を検索"
        var isEnabled: Bool = true
    }

    enum Action: Equatable {
        case fetchAreaList(FetchAreaAction)
        case fetchAreaWeather
        case fetchAreaWeatherResponse(TaskResult<WeatherModel>)
        case onTapCell(Int)
        case alertDismiss
        case searchBarChanged(String)
        case onTappedSwitchButton
        case onTappedClearButton

        enum FetchAreaAction: Equatable {
            case fetchAreaList
            case fetchAreaListResponse(TaskResult<AreaModel>)
        }
    }

    @Dependency(\.weatherClient) var weatherClient

    enum CancelID {}

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .fetchAreaList(let action):
            return featchAreaReduce(state: &state, action: action)
        case .fetchAreaWeather:
            state.isLoading = true
            state.areaWeather = WeatherModel()
            let areaCode: String = state.areaOffices[state.currentIndex].areaCode
            return .task {
                await .fetchAreaWeatherResponse(TaskResult{ try await weatherClient.fetchWeatherInfomation(areaCode) })
            }
        case .fetchAreaWeatherResponse(.success(let response)):
            state.isLoading = false
            state.areaWeather = response
            return .none
        case .fetchAreaWeatherResponse(.failure):
            state.alert = AlertState(title: TextState("エラー"), message: TextState("データ読み込みが失敗しました"))
            state.isLoading = false
            return .none
        case .onTapCell(let indexPathRow):
            state.currentIndex = indexPathRow
            return .none
        case .alertDismiss:
            state.alert = nil
            return .none
        case .searchBarChanged(let text):
            state.searchBarText = text
            return .merge(
                .cancel(id: CancelID.self),
                .task {
                    .fetchAreaList(.fetchAreaList)
                }
            )
        case .onTappedSwitchButton:
            state.isEnabled = !state.isEnabled
            state.placeholder = state.isEnabled ? "都道府県を検索" : "使用不可"
            return .none
        case .onTappedClearButton:
            guard let searchBarText = state.searchBarText,
                  !searchBarText.isEmpty
            else {
                return .none
            }
            state.searchBarText = nil
            return .task {
                .fetchAreaList(.fetchAreaList)
            }
        }
    }
}

extension WeatherStore {
    func featchAreaReduce(state: inout State, action: Action.FetchAreaAction) -> EffectTask<Action> {
        switch action {
        case .fetchAreaList:
            state.isLoading = true
            state.areaOffices = []
            return .task {
                await .fetchAreaList(.fetchAreaListResponse(TaskResult{ try await weatherClient.fetchAreaList() }))
            }
            .cancellable(id: CancelID.self)
        case .fetchAreaListResponse(.success(let response)):
            state.isLoading = false
            var responseOffices: [OfficeModel] = []
            response.offices.forEach {
                responseOffices.append(OfficeModel(areaCode: $0.key, office: $0.value))
            }
            responseOffices = responseOffices.sorted(by: {
                $0.areaCode < $1.areaCode
            })
            if let searchBarText = state.searchBarText, !searchBarText.isEmpty {
                state.areaOffices = responseOffices.filter{ $0.office.name.contains(searchBarText) }
            } else {
                state.areaOffices = responseOffices
            }
            return .none
        case .fetchAreaListResponse(.failure):
            state.alert = AlertState(title: TextState("エラー"), message: TextState("データ読み込みが失敗しました"))
            state.isLoading = false
            return .none
        }
    }
}

extension WeatherStore {
    enum Section: Hashable, CaseIterable {
        case areaOffices
    }

    enum Item: Hashable, Equatable {
        case areaOffices(OfficeModel)
    }
}

extension WeatherStore.State {
    typealias Section = WeatherStore.Section
    typealias Item = WeatherStore.Item
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    var snapshot: Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.areaOffices])
        snapshot.appendItems(areaOffices.map(Item.areaOffices))
        return snapshot
    }
}
