//
//  ViewController.swift
//  rx-swift-playground
//
//  Created by nur kholis on 11/04/22.
//

import UIKit
import RxSwift
import RxGesture
import Alamofire
import RxAlamofire


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
  private var api = ApiManager()


    let subjects = PublishSubject<String>()
    let isShow = PublishSubject<Bool>()
    let behavior = BehaviorSubject<String>(value: "Kintil")
    let arrayInt = BehaviorSubject<Int>(value: 0)
    let array = BehaviorSubject<[Int]>(value: [2, 3, 4])
    var tmpArr = [9]

    var filmData: Films?

    var textBaru = String("Initial")
    var isNumberOnly = false

    let person = Person()
    let home = Home()

    // variable ini hanya aktiv ketika di trigger jadi ga makan memori
    lazy var updatePrefix = Binder<String>(nameField) { textField, value in
        if value.hasPrefix("62") {
            if let range = textField.text?.range(of: "62") {
                textField.text = textField.text?.replacingCharacters(in: range, with: "0")
            }
        }
    }



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
        fetchFilms(of: Films.self) { items in
          print(items.results.first?.title ?? "kokok")

        }
        searchStarships(for: "Wing")
        person.subject.onNext("di ganti bro")
        home.behaviour.onNext("behaviour subject")
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

      behavior.onNext("lukman")
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
        .subscribe(onNext: { item in
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

      // cara merubah filter array di rx dengan map kemudian di filter
      array.asObservable()
        .map { $0.filter{ $0%2 == 0 }}
        .subscribe(onNext: { item in
        print("hey \(item)")
      })
        .disposed(by: bag)

      // bind di gunakan untuk memasukan data ketujuan tertentu
      nameField.rx.text
          .compactMap { $0 }
          .bind(to: updatePrefix)
          .disposed(by: bag)


      // manggabungkan dua variable rx dan mengeksekusinya bersama sama sesuai kondisi value terakhir ya gaes
      Observable
        .zip(subjects, behavior)
        .subscribe(onNext: { item1, item2 in
        print(item1+"asda")
        print(item2+"kholis")
      }).disposed(by: bag)

      subjects.onNext("apaa")


      fetchDefaultMenu().subscribe(onNext: { [weak self] data in
        guard let self = self else {
          return
        }
        self.title = "Kholis"
        self.filmData = data
        self.titleLabel.text = self.filmData?.results.first?.title

      }).disposed(by: bag)

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


extension ViewController {
  func fetchFilms<T: Decodable>(of: T.Type, completion:@escaping (_ data: T) -> Void) {
    let request = AF.request("https://swapi.dev/api/films")
    request.validate().responseDecodable(of: T.self) { (response) in
      guard let items = response.value else { return }
      completion(items)
      }
    }


  func searchStarships(for name: String) {
    // 1
    let url = "https://swapi.dev/api/starships"
    // 2
    let parameters: [String: String] = ["search": name]
    // 3
    AF.request(url, parameters: parameters)
      .validate()
      .responseDecodable(of: Starships.self) { response in
        // 4
        guard let starships = response.value else { return }
        print(starships.results)
      }
  }


}

extension ViewController {

  // fetch data dengan menggunakan rxalamofire
  func fetchDefaultMenu() -> PublishSubject<Films> {
      let subject = PublishSubject<Films>()
      api.requestAPI(endpoint: .fetchFilm)
          .subscribe { (data: Films) in
              subject.onNext(data)
          } onError: { error in
              subject.onError(error)
          }
          .disposed(by: bag)
      return subject
  }
}


// MARK: - Welcome
struct Films: Codable {
    let count: Int
    let next, previous: String?
    let results: [Result]
}

// MARK: - Result
struct Result: Codable {
    let title: String
    let episodeID: Int
    let openingCrawl, director, producer, releaseDate: String
    let characters, planets, starships, vehicles: [String]
    let species: [String]
    let created, edited: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case title
        case episodeID = "episode_id"
        case openingCrawl = "opening_crawl"
        case director, producer
        case releaseDate = "release_date"
        case characters, planets, starships, vehicles, species, created, edited, url
    }
}

// MARK: - Welcome
struct Starships: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Starship]
}

// MARK: - Result
struct Starship: Codable {
    let name, model, manufacturer, costInCredits: String
    let length, maxAtmospheringSpeed, crew, passengers: String
    let cargoCapacity, consumables, hyperdriveRating, mglt: String
    let starshipClass: String
    let pilots, films: [String]
    let created, edited: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case name, model, manufacturer
        case costInCredits = "cost_in_credits"
        case length
        case maxAtmospheringSpeed = "max_atmosphering_speed"
        case crew, passengers
        case cargoCapacity = "cargo_capacity"
        case consumables
        case hyperdriveRating = "hyperdrive_rating"
        case mglt = "MGLT"
        case starshipClass = "starship_class"
        case pilots, films, created, edited, url
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

