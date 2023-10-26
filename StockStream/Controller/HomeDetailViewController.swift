//
//  HomeDetailViewController.swift
//  StockStream
//
//  Created by IPH Technologies Pvt. Ltd. on 12/10/23.
//

import UIKit
import DGCharts

class HomeDetailViewController: UIViewController, AxisValueFormatter, ChartAPIManagerDelegate  {

    @IBOutlet weak var candleStickChartView: CandleStickChartView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var portfolioUpdateBAckgroundView: UIView!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var timeframeView: UIView!
    @IBOutlet weak var fiveMinuteTimeframeButton: UIButton!
    @IBOutlet weak var fIfteenMinuteTimeframeButton: UIButton!
    @IBOutlet weak var oneHourTimeframeButton: UIButton!
    @IBOutlet weak var thirtyMinuteTimeframeButton: UIButton!
    @IBOutlet weak var oneDayTimeframeButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    
    var dataEntries: [ChartDataEntry] = []
    var buttonTapped: Bool?
    var dateExtracted: Double?
    var monthName = [String]()
    var resolution = ["5", "15", "30", "60", "D"]
    var resolutionOnButton = "D"
    var time: Double?
    var chooseDate = [String]()
    var dateSelected = " "
    var identifierButtonTap: Bool = false
    var minuteArray = [Int]()
    var hours: Int = 0
    var previousButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let startTime = convertTimestampToDateString(timestamp: ChartAPIManager.shared.startTime)
        extractMonthAndDate(from: startTime)
        let endTime = convertTimestampToDateString(timestamp: ChartAPIManager.shared.endTime)
        extractMonthAndDate(from: endTime)
        ChartAPIManager.shared.delegate = self
        ChartAPIManager.shared.makeUrlAccordingToResolution(resolutionTapped: "D")
        ChartAPIManager.shared.performRequestFromChartApi()
    }
    
    @IBAction func timeframeAction(_ sender: UIButton) {
        identifierButtonTap = !identifierButtonTap //true
        sender.showsMenuAsPrimaryAction = identifierButtonTap
        //UI set up
        if let previousButton = self.previousButton {
            if previousButton != sender {
                previousButton.backgroundColor = UIColor.clear
                sender.backgroundColor = UIColor.timeframeTapBackgroundColor()
                self.previousButton = sender
            }
        } else {
            sender.backgroundColor = UIColor.timeframeTapBackgroundColor()
            self.previousButton = sender
        }
        //update chart
        dataEntries.removeAll()
        resolutionOnButton = (sender.titleLabel?.text)!
        ChartXAxisFormatter(monthNameArray: monthName, resolutionSelected: resolutionOnButton, minuteArray: minuteArray)
        print("resolutionOnButton==========\(String(describing: resolutionOnButton))")
        monthName.removeAll()
        minuteArray.removeAll()
        updateButton(sender: sender)
        ChartAPIManager.shared.makeUrlAccordingToResolution(resolutionTapped: resolutionOnButton)
    }
    
    func setupUI(){
        setupLightDarkModeUI()
        leftButton.layer.cornerRadius = 10
        rightButton.layer.cornerRadius = 10
        sellButton.layer.cornerRadius = 10
        buyButton.layer.cornerRadius = 10
        leftButton.layer.borderWidth = 0.1
        leftButton.layer.borderColor = UIColor.gray.cgColor
        rightButton.layer.borderWidth = 0.1
        rightButton.layer.borderColor = UIColor.gray.cgColor
        fiveMinuteTimeframeButton.layer.cornerRadius = 10
        fIfteenMinuteTimeframeButton.layer.cornerRadius = 10
        oneHourTimeframeButton.layer.cornerRadius = 10
        oneHourTimeframeButton.layer.cornerRadius = 10
        oneDayTimeframeButton.layer.cornerRadius = 10
        thirtyMinuteTimeframeButton.layer.cornerRadius = 10
        timeframeView.layer.cornerRadius = 10
        portfolioUpdateBAckgroundView.layer.cornerRadius = 10
        rightButton.tintColor = .white
        fiveMinuteTimeframeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        fIfteenMinuteTimeframeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        oneHourTimeframeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        oneHourTimeframeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        oneDayTimeframeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }
    
    func updateButton(sender: UIButton){
        //action of menu options
        let actions: [UIAction] = chooseDate.map {
            let action = UIAction(title: $0) { [self] action in
                print("Selected \(action.title)")
                candleStickChartView.data = nil
                dateSelected = action.title
                ChartAPIManager.shared.performRequestFromChartApi()
                ChartAPIManager.shared.delegate = self
                identifierButtonTap = !identifierButtonTap
                sender.showsMenuAsPrimaryAction = identifierButtonTap
            }
            return action
        }
        let menu = UIMenu(children: actions)
        if resolutionOnButton != "D"{
            sender.menu = menu
        } else {
            sender.showsMenuAsPrimaryAction = !identifierButtonTap
            ChartAPIManager.shared.performRequestFromChartApi()
            ChartAPIManager.shared.delegate = self
        }
    }
    
    func didUpdateChart(chart: ChartDataModel) {
        print("printing from delegate function")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            setupChartViewUI(chartData: chart)
        }
    }
    
    func setupChartViewUI(chartData: ChartDataModel){
        buttonTapped = true
        candleStickChartView.leftAxis.enabled = false
        candleStickChartView.xAxis.spaceMin = 0.9
        candleStickChartView.xAxis.labelPosition = .bottom
        let yAxis = candleStickChartView.rightAxis
        let xAxis = candleStickChartView.xAxis
        yAxis.labelTextColor = UIColor.axisLabelTextColor()
        yAxis.drawAxisLineEnabled = false
        yAxis.valueFormatter = self
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        xAxis.axisLineColor = UIColor(white: 1, alpha: 0)
        xAxis.drawAxisLineEnabled = false
        xAxis.labelTextColor = UIColor.axisLabelTextColor()
        xAxis.labelFont = .boldSystemFont(ofSize: 12)
        xAxis.drawAxisLineEnabled = false
        xAxis.axisLineColor = UIColor.clear
        candleStickChartView.legend.enabled = false
        candleStickChartView.scaleYEnabled = false
        candleStickChartView.scaleXEnabled = true
        self.setData(resolution: resolutionOnButton, chartData: chartData)
        if chartData.status == "ok"{
            candleStickChartView.setVisibleXRangeMaximum(10)
            candleStickChartView.setVisibleYRangeMaximum(1800, axis: yAxis.axisDependency)
        }
        let chartXAxisFormatter = ChartXAxisFormatter(monthNameArray: self.monthName, resolutionSelected: resolutionOnButton, minuteArray: minuteArray)
        minuteArray.removeAll()
        monthName.removeAll()
        xAxis.valueFormatter = chartXAxisFormatter
    }
    
    func setupLightDarkModeUI(){
        if self.traitCollection.userInterfaceStyle == .dark {
            // Dark User Interface
            backgroundView.backgroundColor = UIColor.screenBackgroundViewDarkModeColor()
            candleStickChartView.backgroundColor = UIColor.candleStickChartBackgroundDarkModeColor()
            portfolioUpdateBAckgroundView.backgroundColor = UIColor.portfolioUpdateBackgroundViewDarkModeColor()
            candleStickChartView.rightAxis.gridColor = UIColor.candleStickChartRightAxisGridDarkModeColor()
            candleStickChartView.xAxis.gridColor = UIColor.candleStickChartViewXAxisGridDarkModeColor()
            leftButton.backgroundColor = UIColor.rightButtonBackgroundDarkModeColor()
            timeframeView.backgroundColor = UIColor.timeframeDarkModeColor()
            leftButton.tintColor = .white
            fiveMinuteTimeframeButton.backgroundColor = UIColor.timeframeDarkModeColor()
            fIfteenMinuteTimeframeButton.backgroundColor = UIColor.timeframeDarkModeColor()
            oneHourTimeframeButton.backgroundColor = UIColor.timeframeDarkModeColor()
            oneHourTimeframeButton.backgroundColor = UIColor.timeframeDarkModeColor()
            oneDayTimeframeButton.backgroundColor = UIColor.timeframeDarkModeColor()
            separatorView.backgroundColor = UIColor.separatorViewDarkModeColor()
        } else {
            //Light User Interface
            overrideUserInterfaceStyle =  .light
            timeframeView.backgroundColor = UIColor.timeframeViewLightModeColor()
            timeframeView.layer.borderWidth = 0.1
            timeframeView.layer.borderColor = UIColor.gray.cgColor
            candleStickChartView.backgroundColor = .white
            candleStickChartView.rightAxis.gridColor = UIColor.candleStickChartRightAxisGridLightModeColor()
            candleStickChartView.xAxis.gridColor = UIColor.candleStickChartXAxisGridLightModeColor()
            leftButton.tintColor = UIColor.rightButtonLightModeColor()
            fiveMinuteTimeframeButton.backgroundColor = UIColor.timeframeLightModeColor()
            fIfteenMinuteTimeframeButton.backgroundColor = UIColor.timeframeLightModeColor()
            oneHourTimeframeButton.backgroundColor = UIColor.timeframeLightModeColor()
            oneHourTimeframeButton.backgroundColor = UIColor.timeframeLightModeColor()
            oneDayTimeframeButton.backgroundColor = UIColor.timeframeLightModeColor()
        }
    }
    
    func convertTimestampToDateString(timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy, h:mm a 'GMT'"
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func extractMonthAndDate(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy, h:mm a 'GMT'"
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        let calendar = Calendar.current
        print("calendar ==== \(calendar)")
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
        print("components.month ===== \(String(describing: components.month))") //11
        let month = dateFormatter.monthSymbols[components.month! - 1] //-1 done to manage indexing
        print("dateFormatter.monthSymbols ==== \(String(describing: dateFormatter.monthSymbols))")
        if let day = components.day, let hour = components.hour, let minute = components.minute {
            dateExtracted = Double(day)
            monthName.append(month)
            let dateOption = "\(day) \(String(month.prefix(3)))"
            print(dateOption)
            //chooseDate created for storing dates to be displyed in pull down menu.
            chooseDate.append(dateOption)
            print("dateExtracted ===== \(String(describing: dateExtracted))")
            print("Time ======== \(hour):\(minute)")
            return "\(day) \(String(month.prefix(3)))"
        } else {
            return nil
        }
    }
    
    func extractTime(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy, h:mm a 'GMT'"
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        let timeString = timeFormatter.string(from: date)
        return timeString
    }
    
    func timeFormatterConverter(dateAsString: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: date!)
        print("24 hour formatted Date:",date24)        
        let timeArray = date24.components(separatedBy: ":")
        var time24 = " "
        let hour: String = timeArray[0]
        let minutes: String = timeArray[1]
        if resolutionOnButton == "60" {
            time24 = "\(hour)"
        } else if resolutionOnButton == "30" || resolutionOnButton == "15" || resolutionOnButton == "5"  {
            time24 = "\(hour):\(minutes)"
        }
        return time24
    }
    
    func convertToMinutes(timeString: String) -> Int? {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        if let time = timeFormatter.date(from: timeString) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: time)
            if let hour = components.hour, let minute = components.minute {
                return hour * 60 + minute
            }
        }
        return nil
    }
    
    
    func setData(resolution: String, chartData: ChartDataModel) {
        time = 0
        if chartData.status == "ok"{
            let count = chartData.closePrice?.count
            print("count ====== \(String(describing: count))")
            for i in 0..<count! {
                let formattedTime = convertTimestampToDateString(timestamp: (chartData.timeStamp![i]))
                print(formattedTime)
                if resolution == "D"{
                    extractMonthAndDate(from: formattedTime)
                    time = dateExtracted
                } else if resolution == "60" {
                    //extracting day and month
                    let extractedMonthDay = extractMonthAndDate(from: formattedTime)
                    if dateSelected == extractedMonthDay{
                        //extracting time
                        let timeString = extractTime(from: formattedTime)
                        let timeIn24HourFormat = timeFormatterConverter(dateAsString: timeString!)
                        time = Double(timeIn24HourFormat)
                    } else {
                        continue
                    }
                }
                else if resolution == "30" ||  resolution == "15" || resolution == "5"{
                    let extractedMonthDay = extractMonthAndDate(from: formattedTime)
                    if dateSelected == extractedMonthDay{
                        //extracting time
                        let timeString = extractTime(from: formattedTime)
                        let timeIn24HourFormat = timeFormatterConverter(dateAsString: timeString!)
                        print(timeIn24HourFormat)
                        let minutes = convertToMinutes(timeString: "\(timeIn24HourFormat)")
                        if resolution == "30" {
                            hours = minutes! / 30
                            time = Double(hours)
                        }
                        if resolution == "15" {
                            hours = minutes! / 15
                            time = Double(hours)
                        }
                        if resolution == "5" {
                            hours = minutes! / 5
                            time = Double(hours)
                        }
                        minuteArray.append(minutes!)
                    }
                    else {
                        continue
                    }
                }
                else {
                    continue
                }
                let shadowHigh = (chartData.highPrice![i])
                let shadowLow = (chartData.lowPrice![i])
                let open = (chartData.openPrice![i])
                let close = (chartData.closePrice![i])
                let dataEntry = CandleChartDataEntry(x: time!, shadowH: shadowHigh, shadowL: shadowLow, open: open, close: close)
                dataEntries.append(dataEntry)
            }
        }
        let set1 = CandleChartDataSet(entries: dataEntries, label: "")
        set1.axisDependency = .left
        set1.drawIconsEnabled = false
        set1.shadowColorSameAsCandle = true
        set1.shadowWidth = 2.0
        set1.decreasingColor =  UIColor.decreasingCandleStickColor()
        set1.decreasingFilled = true
        set1.increasingColor = UIColor.increasingCandleStickColor()
        set1.increasingFilled = true
        set1.neutralColor = .blue
        set1.drawValuesEnabled = !set1.drawValuesEnabled
        set1.drawVerticalHighlightIndicatorEnabled = false
        set1.barSpace = 0.3
        let data = CandleChartData(dataSet: set1)
        candleStickChartView.data = data
    }
}

extension HomeDetailViewController: ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "$" + String(value)
    }
}
