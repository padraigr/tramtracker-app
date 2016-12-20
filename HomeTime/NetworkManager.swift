//
//  NetworkManager.swift
//  HomeTime
//
//  Created by Padraig Robinson on 18/12/16.
//  Copyright © 2016 REA. All rights reserved.
//

import Foundation
import BrightFutures

typealias JSON = [String: AnyObject]

enum RequestError {
    case parsingError(details: String)
    case networkError(details: String)
}

extension RequestError: Error {
}

class NetworkManager {

    let authEndpoint = "http://ws3.tramtracker.com.au/TramTracker/RestService/GetDeviceToken/?aid=TTIOSJSON&devInfo=HomeTimeiOS"
    var authToken: String?

    func loadTrams(for stopID: String) -> Future<[Tram], RequestError> {
        if let authToken = authToken {
            return requestTrams(for: stopID, authToken: authToken)
        } else {
            return requestAuthToken()
                .flatMap {
                    self.requestTrams(for: stopID, authToken: $0)
                }
        }
    }

    private func requestAuthToken() -> Future<String, RequestError> {
        guard let url = URL(string: authEndpoint) else {
            return Future(error: .networkError(details: "couldn't create URL for Auth request"))
        }

        return tramTrackerRequest(url: url)
            .flatMap { responseObjects -> Future<String, RequestError> in
                guard let authToken = responseObjects.first?["DeviceToken"] as? String else {
                    return Future(error: .parsingError(details: "No auth token in response"))
                }

                return Future(value: authToken)
            }
    }

    private func requestTrams(for stopID: String, authToken: String) -> Future<[Tram], RequestError> {
        guard let url = url(stop: stopID, authToken: authToken) else {
            return Future(error: .networkError(details: "couldn't create URL"))
        }
        
        return tramTrackerRequest(url: url)
            .map { responseObjects in
                responseObjects.flatMap(Tram.init)
            }
    }

    private func tramTrackerRequest(url: URL) -> Future<[JSON], RequestError> {
        let promise = Promise<Data, RequestError>()

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                promise.failure(.networkError(details: error.localizedDescription))
            } else if let data = data {
                promise.success(data)
            } else {
                promise.failure(.networkError(details: "No data from request"))
            }
        }.resume()

        return promise.future
            .flatMap { data -> Future<[JSON], RequestError> in
                guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                      let json = jsonData as? JSON else {
                    return Future(error: .parsingError(details: "Response could not serialize as JSON"))
                }

                guard let responseObject = json["responseObject"] as? [JSON] else {
                    return Future(error: .parsingError(details: "No response object in JSON"))
                }

                return Future(value: responseObject)
            }
    }

    private func url(stop: String, authToken: String) -> URL? {
        return URL(string: "http://ws3.tramtracker.com.au/TramTracker/RestService/GetNextPredictedRoutesCollection/\(stop)/78/false/?aid=TTIOSJSON&cid=2&tkn=\(authToken)")
    }
}
