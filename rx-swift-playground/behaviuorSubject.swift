//
//  behaviuorSubject.swift
//  rx-swift-playground
//
//  Created by nur kholis on 08/02/23.
//

import Foundation
import RxSwift

class Home: NSObject {
  private let bag = DisposeBag()
  // behaviour subject adalah variabel reactive yang datanya sudah
  // di inisialisasi di awal jadi bisa kita ubah diawal sebelum di subscribe
  let behaviour = BehaviorSubject<String>(value: "Ujang")

  override init(){
    super.init()
    self.loadData()
  }

  func loadData(){
    // akan merubah inisialisai di awal Ujang menjadi rusman
    behaviour.onNext("rusman")
    self.behaviour.subscribe(onNext: { value in
      print(value)
    }).disposed(by: bag)
    behaviour.onNext("Robbi")
    // akan diubah lagi menjadi "Robbi"
  }
}

