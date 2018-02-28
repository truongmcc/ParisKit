//
//  DetailViewController.swift
//  swiftu
//
//  Created by picshertho on 09/08/2017.
//  Copyright © 2017 tru. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    var service: AnyObject?
    var tabService: [AnyObject]?
    var gesture = UIGestureRecognizer()
    var adresse: String?
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var tableViewController: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnScreen(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        tableViewController.tableFooterView = UIView(frame: CGRect.zero)
        tableViewController.isScrollEnabled = false
        recupAdresse()
        adressLabel.textColor = setServiceColor()
        // MARK: manage background colour
        //let color = UIColor.init(red: 0, green: 58, blue: 120, alpha: 0.7)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.showAnimate()
    }
    func recupAdresse() {
        if let fontaine = service as? Fontaines {
            adressLabel.text = fontaine.adresse
        } else if let arbre = service as? Arbres {
            adressLabel.text = arbre.adresse
        } else if let capote = service as? Capotes {
            if let adress = capote.adresse {
                adressLabel.text = adress
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func tapOnScreen(_ sender: UITapGestureRecognizer) {
        self.removeAnimate()
    }
    func showAnimate() {
        self.view.transform = CGAffineTransform.init(scaleX: 2, y: 2)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.40, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        })
    }
    func removeAnimate() {
        UIView.animate(withDuration: 0.20, animations: {
            self.view.transform = CGAffineTransform.init(scaleX: 2, y: 2)
            self.view.alpha = 0.0
        }, completion: {(finished: Bool) in
            if finished {
                self.view.removeFromSuperview()
            }
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tabService!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.textColor = setServiceColor()
        cell.detailTextLabel?.textColor = setServiceColor()
        cell.textLabel?.text = self.tabService?[indexPath.row]["title"] as? String
        let property = self.tabService?[indexPath.row]["property"] as? String
        let value: AnyObject = service?.value(forKey: property!) as AnyObject
        if value is Float {
            let floatToString = String(describing: value)
            if let unit = Constants.tabDetailArbre[indexPath.row]["unit"] {
                cell.detailTextLabel?.text = floatToString + unit
            } else {
                cell.detailTextLabel?.text = floatToString
            }
        } else if value is String {
            cell.detailTextLabel?.text = service?.value(forKey: property!) as? String
        } else {
            cell.isHidden = true
        }
        return cell
    }
    func setServiceColor() -> UIColor {
        if service is Arbres? {
            return UIColor.green
        } else if service is Capotes? {
            return UIColor.red
        } else if service is Fontaines? {
            return UIColor.cyan
        } else if service is Cafes? {
            return UIColor.brown
        } else {
            return UIColor.white
        }
    }
}
