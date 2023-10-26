//
//  ChartData.swift
//  StockStream
//
//  Created by IPH Technologies Pvt. Ltd. on 21/10/23.
//

import Foundation
//model for storing the data received from api
struct ChartData: Codable {
    let c, h, l, o: [Double]?
    let s: String?
    let t: [Int]?
    let v: [Double]?
}

struct SymbolDetailModel: Codable {
    let description, displaySymbol, symbol: String?
}
typealias SymbolModel = [SymbolDetailModel]
