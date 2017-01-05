//
//  ServerRequests.swift
//  Decision Time
//
//  Created by Ben Rooke on 1/2/17.
//
//

import Foundation

let DidDownloadTopics = "kServerRequestsDidDownloadTopics"
let WillDownloadTopics = "kServerRequestsWillDownloadTopics"
let FailedToDownloadTopics = "kServerRequestsFailedToDownloadTopics"

fileprivate let host = "ec2-35-163-72-63.us-west-2.compute.amazonaws.com"
fileprivate let port = 9898

enum dtAPI: String {
    case topics = "/api/v1/topics"
    case questions = "/api/v1/questions"
}

enum serverError: Error {
    case JSONConversion
    case ServerError
    case BadStatusCode
    case BadDataType
    case BadURL
}

func sendRequest(forAPI api: dtAPI, withTail tail: String = "", serverData: @escaping (AnyObject?, Error?) -> Void) {
    let urlString = "http://\(host):\(port)\(api.rawValue)\(tail)"
    guard let url = URL(string: urlString) else {
        serverData(nil, serverError.BadURL)
        return
    }
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
        var responseJSON: AnyObject? = nil
        guard let http = response as? HTTPURLResponse else {
            serverData(nil, serverError.ServerError)
            return
        }
        print(http.statusCode)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            // The status code is not 200
            serverData(nil, serverError.BadStatusCode)
            return
        }
        guard error == nil else {
            // Trickle the error down.
            serverData(nil, serverError.ServerError)
            return
        }
        guard let responseData = data else {
            // This is okay, we just don't return any data.
            serverData(nil, nil)
            return
        }
        
        // Parse the result as JSON, since that's what the API provides
        do {
            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String: AnyObject]] {
                responseJSON = json as AnyObject
            } else if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] {
                responseJSON = json as AnyObject
            } else {
                // The resulting serialization was not a list of string: anyobject
                serverData(nil, serverError.BadDataType)
            }
        } catch {
            // Error tryin to convert data to JSON.
            serverData(nil, serverError.JSONConversion)
        }
        serverData(responseJSON, nil)
    })
    task.resume()
}

func getTopics(serverData: @escaping (AnyObject?, Error?) -> Void) {
    sendRequest(forAPI: .topics) { (data, error) in
        serverData(data, error)
    }
}

func getQuestions(forTopic topic: Int, serverData: @escaping (AnyObject?, Error?) -> Void) {
    sendRequest(forAPI: .questions, withTail:"/\(topic)") { (data, error) in
        serverData(data, error)
    }
}
