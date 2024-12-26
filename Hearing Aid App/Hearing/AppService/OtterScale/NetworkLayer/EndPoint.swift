//
//  Request.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 11.01.2022.
//

protocol EndPoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any] { get }
    var headers: [String: String] { get }
}
