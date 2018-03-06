//
//  DetailViewController.swift
//  swiftu
//
//  Created by picshertho on 09/08/2017.
//  Copyright © 2017 tru. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    var gesture = UIGestureRecognizer()
    var adresse: String?
    var detailViewModel = DetailViewModel()
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var tableViewController: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnScreen(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        self.showAnimate()
        // MARK: tableViewController
        tableViewController.tableFooterView = UIView(frame: CGRect.zero)
        tableViewController.isScrollEnabled = false
        // MARK: manage background colour
        adressLabel.textColor = self.detailViewModel.serviceColor()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
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
        return self.detailViewModel.tabService!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.textColor = self.detailViewModel.serviceColor()
        cell.detailTextLabel?.textColor = self.detailViewModel.serviceColor()
        cell.textLabel?.text = self.detailViewModel.tabService?[indexPath.row]["title"] as? String
        guard let detailTextLabel = self.detailViewModel.detailText(index: indexPath.row) else {
            cell.isHidden = true
            return cell
        }
        cell.detailTextLabel?.text = detailTextLabel
        return cell
    }
}
