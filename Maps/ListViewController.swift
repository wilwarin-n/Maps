//
//  ListViewController.swift
//  Maps
//
//  Created by Aydın Kutlu on 9.05.2024.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var nameList = [String]()
    var idList = [UUID]()
    
    var chosen_name = ""
    var chosen_id : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickedAddButton))
        // Do any additional setup after loading the view.
        
        getData()
    }
    
    func getData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                nameList.removeAll(keepingCapacity: false)
                idList.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    
                    if let name = result.value(forKey: "name") as? String{
                        nameList.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        idList.append(id)
                    }
                    
                    
                    
                }
                tableView.reloadData()
            }
        } catch{
            print("Error")
        }
    }
    
    @objc func clickedAddButton() {
        chosen_name = ""
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameList[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosen_name = nameList[indexPath.row]
        chosen_id = idList[indexPath.row]
        
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinationVC = segue.destination as! MapsViewController
            destinationVC.ch_name = chosen_name
            destinationVC.ch_id = chosen_id
            
        }
    }

}
