//
//  ViewController.swift
//  StockStream
//
//  Created by IPH Technologies Pvt. Ltd. on 12/10/23.
//

import UIKit
import DGCharts

class HomeViewController: UIViewController {
    
    var backButton: UIButton?
    var moreButton: UIButton?
    var hStack: UIStackView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .label
        ChartAPIManager.shared.fetchDataFromSymbolApi()
        let date = Date(timeIntervalSince1970: TimeInterval(1575158400))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy, h:mm a 'GMT'"
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        let dateString = dateFormatter.string(from: date)
    }
    
    @IBAction func moreAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeDetailViewController") as! HomeDetailViewController
        configureItemsOfNavBar()
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backButton!)
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: moreButton!)
        vc.navigationItem.titleView = hStack
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func configureItemsOfNavBar(){
        let bitcoinTitleLabel = UILabel()
        bitcoinTitleLabel.text = "BTC"
        bitcoinTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        bitcoinTitleLabel.textColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
        let imageView = UIImageView()
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 20)
        ])
        imageView.backgroundColor = .clear
        let navBarTitleImage = UIImage(named: "cycle")?.withRenderingMode(.alwaysTemplate)
        imageView.image = navBarTitleImage
        imageView.tintColor = UIColor(red: 171/255, green: 171/255, blue: 182/255, alpha: 1)
        let etheriumTitleLabel = UILabel()
        etheriumTitleLabel.text = "ETH"
        etheriumTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        etheriumTitleLabel.textColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
        hStack = UIStackView(arrangedSubviews: [bitcoinTitleLabel, imageView, etheriumTitleLabel])
        hStack!.spacing = 15
        hStack!.alignment = .center
        backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        backButton!.layer.borderWidth = 0.1
        backButton!.layer.borderColor = UIColor.gray.cgColor
        backButton!.layer.cornerRadius = 10
        backButton!.setImage(UIImage(named: "dotLightMode"), for: .normal)
        moreButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        moreButton!.layer.borderWidth = 0.1
        moreButton!.layer.borderColor = UIColor.gray.cgColor
        moreButton!.layer.cornerRadius = 10
        moreButton!.tintColor = .label
        moreButton!.setImage(UIImage(named: "backLightMode"), for: .normal)
        if self.traitCollection.userInterfaceStyle == .dark{
            backButton!.setImage(UIImage(named: "dotDarkMode"), for: .normal)
            moreButton!.setImage(UIImage(named: "backDarkMode"), for: .normal)
            bitcoinTitleLabel.textColor = UIColor(red: 180/255, green: 179/255, blue: 184/255, alpha: 1)
            etheriumTitleLabel.textColor = UIColor(red: 180/255, green: 179/255, blue: 184/255, alpha: 1)
        }
        moreButton!.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        navigationController?.popViewController(animated: true)
    }
}

