//
//  API.swift
//  on the map
//
//  Created by reem katmeh on 28/02/2019
//  Copyright © 2019 reemkt. All rights reserved.
//

import Foundation

class API {
    
    private static var userInfo = UserInfo()
    private static var sessionId: String?
    
    static func postSession(username: String, password: String, completion: @escaping (String?)->Void) {
        guard let url = URL(string: APIConstants.SESSION) else {
            completion("Supplied url is invalid")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var errString: String?
            if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                if statusCode >= 200 && statusCode < 300 { //Response is ok
                    
                    let newData = data?.subdata(in: 5..<data!.count)
                    if let json = try? JSONSerialization.jsonObject(with: newData!, options: []),
                        let dict = json as? [String:Any],
                        let sessionDict = dict["session"] as? [String: Any],
                        let accountDict = dict["account"] as? [String: Any]  {
                        
                        self.userInfo.key = accountDict["key"] as? String // This is used in getUserInfo(completion:)
                        self.sessionId = sessionDict["id"] as? String
                        
                        self.getUserInfo(completion: { err in
                            
                        })
                    } else { //Err in parsing data
                        errString = "Couldn't parse response"
                    }
                } else { //Err in given login credintials
                    errString = "Provided login credintials didn't match our records"
                }
            } else { //Request failed to sent
                errString = "Check your internet connection"
            }
            DispatchQueue.main.async {
                completion(errString)
            }
            
        }
        task.resume()
    }
    
    static func getUserInfo(completion: @escaping (Error?)->Void) {
        guard let url = URL(string: "\(APIConstants.PUBLIC_USER)\(self.userInfo.key!)") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode >= 200 && statusCode < 300 {
                    
                    guard let data = data else { return }
                    let range = (5..<data.count)
                    let newData = data.subdata(in: range)
                    
                    if let json = try? JSONSerialization.jsonObject(with: newData, options: [.allowFragments]),
                        let dictionary = json as? [String:Any] {
                        let name = dictionary["name"] as? String ?? " "
                        let firstName = dictionary["first_name"] as? String ?? name
                        let lastName = dictionary["last_name"] as? String ?? name
                        
                        userInfo.firstName = firstName
                        userInfo.lastName = lastName
                    }
                    
                } else {
                    completion(error)
                }
            }
            DispatchQueue.main.async {
                completion(nil)
            }
            
        }
        task.resume()
    }
    
    static func deleteSession(completion: @escaping (String?)->Void) {
        guard let url = URL(string: APIConstants.SESSION) else {
            completion("URL is invalid")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var errString: String?
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode >= 200 && statusCode < 300 {
                    let range = (5..<data!.count)
                    if let data = data {
                        let newData = data.subdata(in: range)
                    } else {
                        errString = "Failed reading response"
                    }
                } else {
                    errString = "Request failed"
                }
            } else {
                errString = "No internet connection"
            }
            DispatchQueue.main.async {
                completion(errString)
            }
            
        }
        task.resume()
    }
    
    class Parser {
        
        static func getStudentLocations(limit: Int = 100, skip: Int = 0, orderBy: SLParam = .updatedAt, completion: @escaping (LocationsData?)->Void) {
            guard let url = URL(string: "\(APIConstants.STUDENT_LOCATION)?\(APIConstants.ParameterKeys.LIMIT)=\(limit)&\(APIConstants.ParameterKeys.SKIP)=\(skip)&\(APIConstants.ParameterKeys.ORDER)=-\(orderBy.rawValue)") else {
                completion(nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.get.rawValue
            request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
            request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                var studentLocations: [StudentLocation] = []
                if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                    if statusCode >= 200 && statusCode < 300 { //Response is ok
                        
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []),
                            let dict = json as? [String:Any],
                            let results = dict["results"] as? [Any] {
                            
                            for location in results {
                                let data = try! JSONSerialization.data(withJSONObject: location)
                                let studentLocation = try! JSONDecoder().decode(StudentLocation.self, from: data)
                                studentLocations.append(studentLocation)
                            }
                            
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    completion(LocationsData(studentLocations: studentLocations))
                }
                
            }
            task.resume()
        }
        
        static func postLocation(_ location: StudentLocation, completion: @escaping (String?)->Void) {
            guard let url = URL(string: APIConstants.STUDENT_LOCATION) else {
                completion("URL is invalid")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
            request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
            request.addValue("application/json", forHTTPHeaderField: APIConstants.HeaderKeys.CONTENT_TYPE)
            var locationData = location
            locationData.uniqueKey = userInfo.key
            locationData.firstName = userInfo.firstName
            locationData.lastName = userInfo.lastName
            
            let jsonData = try! JSONEncoder().encode(locationData)
            request.httpBody = jsonData
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                var errString: String?
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if statusCode >= 200 && statusCode < 300 { // Success response
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []),
                            let _ = json as? [String:Any] {
                            print("Successfully posted a new location")
                        } else { // Error while reading data
                            errString = "Couldn't parse response"
                        }
                    } else { // Error in given login credintials
                        errString = "Courldn't post a new location"
                    }
                } else { // Request failed to sent
                    errString = "No internet connection"
                }
                DispatchQueue.main.async {
                    completion(errString)
                }
                
            }
            task.resume()
        }
        
    }
    
    
    
}
