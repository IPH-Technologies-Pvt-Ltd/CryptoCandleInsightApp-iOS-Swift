//
//  APICall.swift
//  StockStream
//
//  Created by IPH Technologies Pvt. Ltd. on 19/10/23.
//

import Foundation

protocol ChartAPIManagerDelegate {
    func didUpdateChart(chart: ChartDataModel)
}

struct ChartAPIManager{
    
    static var shared = ChartAPIManager()
    let apiKey = "ckobshpr01qjh1e0nt30ckobshpr01qjh1e0nt3g"
    var chartUrlString: String?
    var startTime = 1572651390
    var endTime = 1575243390
    var delegate: ChartAPIManagerDelegate?
    
    mutating func makeUrlAccordingToResolution(resolutionTapped: String){
        chartUrlString = "https://finnhub.io/api/v1/crypto/candle?symbol=BINANCE:BTCUSDT&resolution=\(resolutionTapped)&from=\(startTime)&to=\(endTime)&token=\(apiKey)"
        print("chartUrlString======\(String(describing: chartUrlString))")
    }
    
    func fetchDataFromSymbolApi(){
        
        let symbolUrlString = "https://finnhub.io/api/v1/crypto/symbol?exchange=binance&token=\(apiKey)"
        guard let symbolUrl = URL(string: symbolUrlString) else{
            print("Invalid symbolURL string")
            return
        }
        //make request to endpoint
        let task = URLSession.shared.dataTask(with: symbolUrl) { (data, response, error) in
            guard let data = data else{
                print("Data was nil")
                return
            }
            //decode json to struct
            guard let symbolList = try? JSONDecoder().decode(SymbolModel.self, from: data) else{
                print("Couldn't decode the JSON data.")
                return
            }
            print(symbolList[0].symbol!)
            print(symbolList.count)
        }
        task.resume()
    }
    
    func performRequestFromChartApi(){
        
        guard let chartUrl = URL(string: chartUrlString!) else{
            print("Invalid cryptoCandleUrl string")
            return
        } 
        //make request to endpoint
        let task = URLSession.shared.dataTask(with: chartUrl) { (data, response, error) in
            if error != nil{
                print(error)
                return
            }
            guard let data = data else {
                print("Data was nil")
                return
            }
            //decode json to struct
            print("data: \(data)")
            if let chart = self.parseJSON(chartData: data) {
                self.delegate?.didUpdateChart(chart: chart)
            }
        }
        task.resume()
    }
    
    func parseJSON(chartData: Data) -> ChartDataModel?{
        let decoder = JSONDecoder()
        do {
            let decodedChartData = try decoder.decode(ChartData.self, from: chartData)
            //extract values from the overall parsed data that you need in the UI
            let openPrice = decodedChartData.o
            let highPrice = decodedChartData.h
            let lowPrice = decodedChartData.l
            let closePrice = decodedChartData.c
            let status = decodedChartData.s
            let timeStamp = decodedChartData.t
            let volume = decodedChartData.v
            
            let chart = ChartDataModel(openPrice: openPrice, highPrice: highPrice, lowPrice: lowPrice, closePrice: closePrice, status: status, timeStamp: timeStamp, volume: volume)
            return chart
        } catch {
            print(error)
            return nil
        }
    }
}
