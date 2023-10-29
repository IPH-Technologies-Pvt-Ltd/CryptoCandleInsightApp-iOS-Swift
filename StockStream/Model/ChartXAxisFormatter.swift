//
//  ChartXAxisFormatter.swift
//  StockStream
//
//  Created by IPH Technologies Pvt. Ltd. on 20/10/23.
//

import UIKit
import DGCharts

class ChartXAxisFormatter: AxisValueFormatter, ChartViewDelegate {
    var monthNameArray: [String] = []
    var xAxisLabel = " "
    var resolutionSelected = "D"
    var minuteArray = [Int]()
    
    init(monthNameArray: [String], resolutionSelected: String, minuteArray: [Int]) {
        self.monthNameArray = monthNameArray
        self.resolutionSelected = resolutionSelected
        self.minuteArray = minuteArray
    }
    //value can be taken as index.
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let castValueToInt = Int(value)
        print(resolutionSelected)
        if resolutionSelected == "D"{
            if castValueToInt < monthNameArray.count{
                let monthName = monthNameArray[castValueToInt]
                let monthNameShorthandNotation = String(monthName.prefix(3))
                print(monthNameShorthandNotation)
                xAxisLabel = "\(castValueToInt) \(monthNameShorthandNotation)"
                print(xAxisLabel)
            }
        }
        else if resolutionSelected == "60"{
            let castValueToInt = Int(value)
            xAxisLabel = "\(castValueToInt):00  "
        }
        else if resolutionSelected == "30" || resolutionSelected == "15" || resolutionSelected == "5" {
            print("value===\(value)")
            print(minuteArray.count)
            if let time = convertTo24HourFormat(minutes: minuteArray[castValueToInt]) {
                xAxisLabel = "\(time)  "
            }
        }
        return xAxisLabel
    }
    
    func convertTo24HourFormat(minutes: Int) -> String? {
        if minutes < 0 || minutes > 24 * 60 {
            return nil
        }
        let hours = minutes / 60
        let mins = minutes % 60
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let date = Calendar.current.date(bySettingHour: hours, minute: mins, second: 0, of: Date()) {
            return formatter.string(from: date)
        }
        return nil
    }
}
