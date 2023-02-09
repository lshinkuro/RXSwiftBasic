//
//  NetworkManager.swift
//  rx-swift-playground
//
//  Created by nur kholis on 09/02/23.
//

import Foundation
import UIKit
import RxAlamofire
import Alamofire
import Combine
import RxSwift

enum ErrorHandler: Error {
    case invalidLink
    case failedParsing
    case unknownError
    case dataEmpty
    case unauthorized
}

enum RequestType {
  case api
}

class ApiManager {

  private static let session: Session = {
    let session = Session()
    return session
  }()

  func requestAPI<T: Codable>(endpoint: Endpoint, timeout: TimeInterval = 60) -> Observable<T> {
      return Observable.create { observer in
          ApiManager.session.request(
              endpoint.urlString(),
              method: endpoint.method(),
              parameters: endpoint.parameters,
              encoding: endpoint.encoding,
              headers: endpoint.headers,
              interceptor: nil,
              requestModifier: { $0.timeoutInterval = timeout })
          .rx
          .responseData()
          .observe(on: MainScheduler.instance)
          .map { $0.1 }
          .decode(type: T.self, decoder: JSONDecoder())
          .subscribe { data in
              observer.onNext(data)
              observer.onCompleted()
          } onError: { error in
              print(error.localizedDescription)
              observer.onError(error)
          }
      }
  }
}
