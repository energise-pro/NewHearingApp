//
//  APIEnvironment.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 11.01.2022.
//

protocol APIEnvironmentProtocol {
    var host: String { get }
    var apiKey: String { get }
}

struct APIEnvironment: APIEnvironmentProtocol {
    let host: String
    let apiKey: String
}
