//
//  publishSubject.swift
//  rx-swift-playground
//
//  Created by nur kholis on 08/02/23.
//

import Foundation
import RxSwift


class Person: NSObject {
  private let bag = DisposeBag()
  // publish subject adalah variabel reactive yang datanya belum
  // di inisialisasi di awal maka apabila kita trigger dengan data baru lah dia ada datanya
  let subject = PublishSubject<String>()

  override init(){
    super.init()
    self.loadData()
  }

  func loadData(){
    // tidak akan di exsekusi karena belum di subscribe
    subject.onNext("rusman")
    self.subject.subscribe(onNext: { value in
      print(value)
    }).disposed(by: bag)
    // jika di print akan kosong karena belum di beri nilai
    subject.onNext("Robbi")
    // akan keluar "Robbi"

  }


}
