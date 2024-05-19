//
//  ViewController.swift
//  Maps
//
//  Created by Aydın Kutlu on 24.04.2024.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapsViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate{

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var ch_latitude = Double()
    var ch_longitude = Double()
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongtitude = Double()
    
    var ch_name = ""
    var ch_id : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self // delegate map fonksiyonlarını kullanabilmek için kullanırız.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectLocation))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if ch_name != "" {
            if let uuidString = ch_id?.uuidString {
                print(uuidString)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            annotationTitle = name
                            
                            if let note = result.value(forKey: "note") as? String {
                                
                                annotationSubtitle = note
                                
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        annotationLongtitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongtitude)
                                        annotation.coordinate = coordinate
                                        
                                        mapView.addAnnotation(annotation)
                                        nameTextField.text = annotationTitle
                                        noteTextField.text = annotationSubtitle
                                        
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                        
                                    }
                                }
                                
                            }
                            
                        }
                    }
                } catch {
                    print("Error")
                }
            }
        } else {
            
        }
    }
    
    @objc func selectLocation(gestureRecognizer : UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let nokta = gestureRecognizer.location(in: mapView)
            let koordinat = mapView.convert(nokta, toCoordinateFrom: mapView)
            
            ch_latitude = koordinat.latitude
            ch_longitude = koordinat.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = koordinat
            annotation.title = nameTextField.text
            annotation.subtitle = noteTextField.text
            mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[0].coordinate.latitude)
        //print(locations[0].coordinate.longitude)
        if ch_name == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    @IBAction func clickedSaveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let locationEnt = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        
        locationEnt.setValue(nameTextField.text, forKey: "name")
        locationEnt.setValue(noteTextField.text, forKey: "note")
        
        locationEnt.setValue(ch_latitude, forKey: "latitude")
        locationEnt.setValue(ch_longitude, forKey: "longitude")
        
        locationEnt.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("Saved")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("createdNewPlace"), object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    
    
}

