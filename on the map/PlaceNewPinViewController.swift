//
//  ConfirmLocationViewController.swift
//  on the map
//
//  Created by reem katmeh on 28/02/2019
//  Copyright © 2019 reemkt. All rights reserved.
//

import UIKit
import MapKit

class PlaceNewPinViewController: UIViewController {
    
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var mediaURL: UITextField!
    
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        locationField.resignFirstResponder()
        mediaURL.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToNotificationsObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromNotificationsObserver()
    }
    
    @IBAction func findTapped(_ sender: UIButton) {
        
        guard let mediaLink = mediaURL.text,
            let Location = locationField.text,
            mediaLink != "", Location != "" else {
                self.showAlert(title: "Missing information", message: "Please fill the field and try again")
                return
        }
        
        let studentLocation = StudentLocation(mapString: Location, mediaURL: mediaLink)
        geocodeCoordinates(studentLocation)
    }
    
    private func geocodeCoordinates(_ studentLocation: StudentLocation) {
        
        let ai = self.startAnActivityIndicator()
        CLGeocoder().geocodeAddressString(studentLocation.mapString!) { (placeMarks, err) in
            
            
            
            guard let firstLocation = placeMarks?.first?.location else {
                self.showAlert(title: "", message: "can't find location")
                ai.stopAnimating()
                return
                
            }
            
            var location = studentLocation
            location.latitude = firstLocation.coordinate.latitude
            location.longitude = firstLocation.coordinate.longitude
            
            
            self.performSegue(withIdentifier: "confirmLocation", sender: location)
        }
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmLocation", let vc = segue.destination as? ConfirmLocationViewController {
            vc.location = (sender as! StudentLocation)
        }
    }
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.cancelTapped(_:)))
        
        mediaURL.delegate = self
    }
    
    @objc private func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


