//
//  OptionsViewController.swift
//  swiftu
//
//  Created by picshertho on 20/07/2017.
//  Copyright © 2017 tru. All rights reserved.
//

import UIKit

protocol mapKitDelegate: class {
    func changerTypeMap(type: Int)
    func afficherArbres()
    func afficherVelib()
    func afficherTaxis()
    func afficherAutolib()
    func afficherSanisettes()
    func afficherCapotes()
    func afficherFontaines()
    func afficherBelibs()
    func afficherCafes()
}
class OptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: delegate
    weak var delegate: mapKitDelegate?
    @IBAction func backToMap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: IBAction
    @IBAction func changeType(_ sender: UISegmentedControl) {
        delegate?.changerTypeMap(type: sender.selectedSegmentIndex)
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: IBOutlet
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    // MARK: Property
    var mapType: UInt = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        optionsTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.segmentedControl.selectedSegmentIndex = Int(self.mapType)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.tabListServices.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        cell.textLabel?.text = Constants.tabListServices[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            delegate?.afficherVelib()
        case 1:
            delegate?.afficherAutolib()
        case 2:
            delegate?.afficherTaxis()
        case 3:
            delegate?.afficherArbres()
        case 4:
            delegate?.afficherSanisettes()
        case 5:
            delegate?.afficherCapotes()
        case 6:
            delegate?.afficherFontaines()
        case 7:
            delegate?.afficherBelibs()
        case 8:
            delegate?.afficherCafes()
        default:
            delegate?.afficherArbres()
        }
        self.dismiss(animated: true, completion: nil)
    }
}
