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

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate{

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var ch_latitude = Double()
    var ch_longitude = Double()
    
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
    }
    
    @objc func selectLocation(gestureRecognizer : UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let nokta = gestureRecognizer.location(in: mapView)
            let koordinat = mapView.convert(nokta, toCoordinateFrom: mapView)
            
            ch_latitude = koordinat.latitude
            ch_longitude = koordinat.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = koordinat
            annotation.title = name.text
            annotation.subtitle = note.text
            mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[0].coordinate.latitude)
        //print(locations[0].coordinate.longitude)
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func clickedSaveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let locationEnt = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        
        locationEnt.setValue(name.text, forKey: "name")
        locationEnt.setValue(note.text, forKey: "note")
        
        
    }
}

