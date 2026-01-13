//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}


