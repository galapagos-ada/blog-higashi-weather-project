//
//  AreaModel.swift
//  SampleProject
//
//  Created by hideto.higashi on 2022/12/20.
//

import Foundation

struct AreaModel: Codable, Equatable, Hashable {
    let centers: [String: Center]
    let offices: [String: Office]

    struct Center: Codable, Equatable, Hashable {
        let name: String
        let enName: String
        let officeName: String
        let children: [String]
    }

    struct Office: Codable, Equatable, Hashable {
        let name: String
        let enName: String
        let officeName: String?
        let parent: String
        let children: [String]
    }
}
