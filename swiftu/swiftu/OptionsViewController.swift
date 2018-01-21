//
//  OptionsViewController.swift
//  swiftu
//
//  Created by picshertho on 20/07/2017.
//  Copyright © 2017 tru. All rights reserved.
//

import UIKit

protocol mapKitDelegate {
    func changerTypeMap(type:Int)
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

class OptionsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    //MARK:delegate
    var delegate:mapKitDelegate?
    
    @IBAction func backToMap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK:IBAction
    @IBAction func changeType(_ sender: UISegmentedControl) {
        delegate?.changerTypeMap(type: sender.selectedSegmentIndex)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:IBOutlet
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //MARK:Property
    var mapType:UInt = 0
    
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
        switch (indexPath.row) {
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
    
 
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    // Override to support editing the table view.
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//
//        }
        //        else if editingStyle == .insert {
        //            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        //        }
//    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
