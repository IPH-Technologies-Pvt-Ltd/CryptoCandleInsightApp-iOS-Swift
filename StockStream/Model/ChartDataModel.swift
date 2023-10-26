//
//  ChartDataModel.swift
//  StockStream
//
//  Created by IPH Technologies Pvt. Ltd. on 22/10/23.
//

import Foundation
//model for updating the ui
struct ChartDataModel {
    let openPrice, highPrice, lowPrice, closePrice: [Double]?
    let status: String?
    let timeStamp: [Int]?
    let volume: [Double]?
}
