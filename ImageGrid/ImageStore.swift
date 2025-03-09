

import SwiftUI

struct DownloadedImage: Identifiable {
  let id: Int
  let url: URL
  var image: UIImage
}

class ImageStore: ObservableObject {
  @Published var images: [DownloadedImage] = []
  var urls: [URL] = []

  func getUrls() {
    guard
      let plist = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
      let contents = try? Data(contentsOf: plist),
      let serial = try? PropertyListSerialization.propertyList(from: contents, format: nil),
      let serialUrls = serial as? [String] else {
      print("Something went horribly wrong!")
      return
    }
    urls = serialUrls.compactMap { URL(string: $0) }
  }

  func createImagesArray() {
    getUrls()
    for (index, url) in urls.enumerated() {
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        self.images.append(
          DownloadedImage(
            id: index,
            url: url,
            image: UIImage(systemName: "questionmark.square") ?? UIImage()))
      }
    }
  }

  func downloadImageOnMainQueue(index: Int) {
    if
      let data = try? Data(contentsOf: self.images[index].url),
      let decodedImage = UIImage(data: data) {
      images[index].image = decodedImage
    }
  }

  func downloadImageOffMainQueue(index: Int) {
    DispatchQueue.global(qos: .utility).async { [weak self] in
      guard let self else { return }
      if
        let data = try? Data(contentsOf: self.images[index].url),
        let decodedImage = UIImage(data: data) {
        DispatchQueue.main.async {
          self.images[index].image = decodedImage
        }
      }
    }
  }

  func downloadImageWithUrlSession(index: Int) {
    // DONE: Episode 6
    URLSession.shared.dataTask(with: images[index].url) {
      [weak self] data, _, _ in
      guard let self else { return }
      if let data, let decodedImage = UIImage(data: data) {
        DispatchQueue.main.async {
          self.images[index].image = decodedImage
        }
      }
    }
    .resume()
  }
}
