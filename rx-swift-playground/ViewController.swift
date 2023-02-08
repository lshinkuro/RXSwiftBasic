//
//  ViewController.swift
//  rx-swift-playground
//
//  Created by nur kholis on 11/04/22.
//

import UIKit
import RxSwift
import RxGesture

// RXGesture itu di gunakan untuk reactive pada component 2 di swift seperti button, textfield, view
//kita bisa memberinya fungsi tekan atau merubah isi textfield tanpa perlu menggunakan delegate untuk textfield atau yang lain2

// publishsubject adalah variabel reactive yang datanya belum di inisialisasi di awal maka apabila kita trigger dengan data baru lah dia ada datanya
// behaviourSubject kebalikanya ada data yang di inisialisasi ketika awal pembuatanya gaes


class ViewController: UIViewController {
    
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var behaveLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!

  @IBOutlet weak var testBtn: UIButton!
  @IBOutlet weak var viewBtn: UIView!
  @IBOutlet weak var nameField: UITextField!

  private let bag = DisposeBag()


    let subjects = PublishSubject<String>()
    let isShow = PublishSubject<Bool>()
    let behavior = BehaviorSubject<String>(value: "Kintil")
    let arrayInt = BehaviorSubject<Int>(value: 0)

    var textBaru = String("Initial")
    var isNumberOnly = false


    lazy var formatText = Binder<String>(self.nameField) { [weak self] textField, value in
        guard let self = self else { return }
        print("value is \(value)")

      if self.isNumberOnly {
          let filterStr = value.filter { $0.isWholeNumber }
        if filterStr.count > textField.maxLength {
              textField.text = "\(filterStr)"
              textField.deleteBackward()
          } else {
              textField.text = "\(filterStr)"
          }
      } else {
          if value.count > textField.maxLength {
              textField.text = "\(value)"
              textField.deleteBackward()
          } else {
              textField.text = "\(value)"
          }
      }
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupAction()
    }
    
    func setup() {
       // baris ini tidak akan di eksekusi karena belum di subscribe
        subjects.onNext("Kholis")
        subjects.subscribe(onNext: {
            [weak self] data in
            print(data)
            self?.titleLabel.text = data
        }).disposed(by: bag)
       // baris ini akan di eksekusi dan data akan di binding ke variable subject
        subjects.onNext("Kholis")
      isShow.subscribe(onNext: {
        [weak self] item in
        print(item)

        if item {
          self?.statusLabel.text = "Alive"
        } else {
          self?.statusLabel.text = "Dead"
        }
      }).disposed(by: bag)
      isShow.onNext(true)
      isShow.onNext(false)

      behavior.subscribe(onNext: {
        [weak self] item in
        self?.behaveLabel.text = item.uppercased()
        print(item)
      }).disposed(by: bag)
      behavior.onNext("Bagus")

      arrayInt
      // akan mengabaikan semua inputan yang masuk tapi akan menjadi never setelahnya
//        .ignoreElements()
       // hanya mengambil value di trigerr index ke 1
        .element(at: 1)
      // kalo ada item yang double ga akan di eksekusi sampe ada item input yang berubah
        .distinctUntilChanged()
      // hanya mengambil 6 trigger awal
        .take(6)
      // akan berhenti trigger data ketika observable lain di trigger ambil value sebelumnya
        .take(until: isShow)
      // akan di eksekusi setelah observable lain di  triger ambil item setelahnya
        .skip(until: isShow)
      // akan menskip value yang kondisinya sesuai sama yang di bawah ini
        .skip(while: {$0 % 2 == 0})
      // untuk filter item di rx
        .filter{ $0 > 0 }
      // merubah value di dalamnya menjadi betuk lain
        .map{$0 * 2}
        .subscribe(onNext: {[weak self] item in
        guard let self = self else {
          return
        }
         print("item \(item)")
      }).disposed(by: bag)

      arrayInt.onNext(0)
      arrayInt.onNext(2)
      arrayInt.onNext(3)
      arrayInt.onNext(4)
      arrayInt.onNext(4)
      arrayInt.onNext(5)

      isShow.onNext(true)

      arrayInt.onNext(6)

      isShow.onNext(false)

      Observable.zip(subjects, behavior).subscribe(onNext: {[weak self] item1, item2 in
        print(item1+"asda")
        print(item2+"kholis")
      }).disposed(by: bag)

      subjects.onNext("apaa")

    }

  func setupAction() {
    testBtn.rx.tap
      .subscribe(onNext: {
        [weak self] _ in
        print("hello world")
        guard let self = self else { return }
        self.subjects.onNext(self.textBaru)
      }).disposed(by: bag)


    // memasukan data bisa dengan dua cara ada yang langsung di masukan ke variable ada pula yang di binding
    nameField.rx.text
        .compactMap { $0 }
        .filter { $0.isEmpty || $0.count > 4 }
        .subscribe { [weak self] data in
            guard let self = self else { return }
            self.textBaru = data
            print("item is \(data)")
        }.disposed(by: bag)

    // ini kita membinding data lalu hasilnya di masukan ke lazy format tapi ini mah kadang dipake cuma buat nyeting tampilan validasi di textfieldnya aja ya gaes yak
    nameField.rx.text
        .compactMap { $0 }
        .bind(to: formatText)
        .disposed(by: bag)

    viewBtn.rx
    // any gesture itu bisa banyak gesture ya gaes
      .anyGesture(.tap(), .swipe(direction: .right))
//      .tapGesture()
      .when(.recognized)
      .subscribe(onNext: { [weak self]  _ in
        // Called whenever a tap, a swipe-up or a swipe-down is recognized (state == .recognized)
        guard let self = self else { return }
        self.subjects.onNext(self.textBaru)
        print("tap")
      }).disposed(by: bag)


  }
}

private var maxLengths = [UITextField: Int]()
extension UITextField {
  @IBInspectable var maxLength: Int {
    get {
      guard let length = maxLengths[self] else {
        return 150 // (global default-limit. or just, Int.max)
      }
      return length
    }
    set {
      maxLengths[self] = newValue
      addTarget(self, action: #selector(fix), for: .editingChanged)
    }
  }

  @objc func fix(textField: UITextField) {
      if let text = textField.text {
          textField.text = String(text.prefix(maxLength))
      }
  }
}


//view.rx.tapGesture()           -> ControlEvent<UITapGestureRecognizer>
//view.rx.pinchGesture()         -> ControlEvent<UIPinchGestureRecognizer>
//view.rx.swipeGesture(.left)    -> ControlEvent<UISwipeGestureRecognizer>
//view.rx.panGesture()           -> ControlEvent<UIPanGestureRecognizer>
//view.rx.longPressGesture()     -> ControlEvent<UILongPressGestureRecognizer>
//view.rx.rotationGesture()      -> ControlEvent<UIRotationGestureRecognizer>
//view.rx.screenEdgePanGesture() -> ControlEvent<UIScreenEdgePanGestureRecognizer>
//view.rx.hoverGesture()         -> ControlEvent<UIHoverGestureRecognizer>
//
//view.rx.anyGesture(.tap(), ...)           -> ControlEvent<UIGestureRecognizer>
//view.rx.anyGesture(.pinch(), ...)         -> ControlEvent<UIGestureRecognizer>
//view.rx.anyGesture(.swipe(.left), ...)    -> ControlEvent<UIGestureRecognizer>
//view.rx.anyGesture(.pan(), ...)           -> ControlEvent<UIGestureRecognizer>
//view.rx.anyGesture(.longPress(), ...)     -> ControlEvent<UIGestureRecognizer>
//view.rx.anyGesture(.rotation(), ...)      -> ControlEvent<UIGestureRecognizer>
//view.rx.anyGesture(.screenEdgePan(), ...) -> ControlEvent<UIGestureRecognizer>
//view.rx.anyGesture(.hover(), ...)         -> ControlEvent<UIGestureRecognizer>

