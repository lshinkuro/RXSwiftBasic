//
//  Endpoint.swift
//  rx-swift-playground
//
//  Created by nur kholis on 09/02/23.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift

enum Endpoint {
  case fetchFilm
  case fetchStarships(params: String)

  func path() -> String {
    switch self {
    case .fetchFilm:
      return "/films"
    case .fetchStarships:
      return "/starships"
    }
  }

  func method() -> HTTPMethod {
    switch self {
    case .fetchFilm:
      return .get
    default:
      return .post
    }
  }

  var parameters: [String: Any]? {

    switch self {
    case .fetchFilm:
      return nil
    case .fetchStarships(let params):
      let params: [String: Any] = [
        "user_id": params
      ]
      return params
    }
  }

  var headers: HTTPHeaders {
    switch self {
    case .fetchFilm,
        .fetchStarships:
      let params: HTTPHeaders = [
          "Content-Type": "application/json"
      ]
      return params
    }
  }

  var encoding: ParameterEncoding {
      switch self {
      case .fetchFilm,
          .fetchStarships:
          return URLEncoding.queryString
//      default:
//          return JSONEncoding.default
      }
  }

  func urlString() -> String {
    return BaseConstant.baseUrl + self.path()
  }
}


