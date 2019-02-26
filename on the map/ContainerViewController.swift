//
//  ContainerViewController.swift
//  on the map
//
//  Created by reem katmeh on 28/02/2019
//  Copyright © 2019 reemkt. All rights reserved.
//

import UIKit
    
    class ContainerViewController: UIViewController {
        
        var locationsData: LocationsData?
        
        override func viewDidLoad() {
            super.viewDidLoad()
             setupUI()
         
        }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
             loadStudentLocations()
            
        }
        
        
        func setupUI() {
            
            let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addLocationTapped(_:)))
            let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self.logoutTapped(_:)))
            
            
            navigationItem.rightBarButtonItem = plusButton
            navigationItem.leftBarButtonItem = logoutButton
        }
        
        
        @IBAction func logoutTapped(_ sender: Any) {
            API.deleteSession() { err  in
                guard err == nil else {
                    self.showAlert(title: "Error", message: err!)
                    return
                }
                
                let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
                
                self.present(navController, animated: true, completion: nil)
            }
            
            
    
        }

        
        @objc private func addLocationTapped(_ sender: Any) {
            let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addLocation") as! UINavigationController
            
            present(navController, animated: true, completion: nil)
        }
        
        
        private func loadStudentLocations() {
            API.Parser.getStudentLocations { (data) in
                guard let data = data else {
                    self.showAlert(title: "Error", message: "No internet connection found")
                    return
                }
                guard data.studentLocations.count > 0 else {
                    self.showAlert(title: "Error", message: "No locations found")
                    return
                }
                self.locationsData = data
            }
        }
        
}
