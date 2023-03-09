//
//  OfficeModel.swift
//  SampleProject
//
//  Created by hideto.higashi on 2022/12/20.
//

import Foundation

struct OfficeModel: Equatable, Hashable {
    let areaCode: String
    let office: AreaModel.Office
}
