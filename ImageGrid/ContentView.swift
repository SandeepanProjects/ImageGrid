

import SwiftUI

struct ContentView: View {
  @StateObject private var store = ImageStore()
  var columns: [GridItem] = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
  ]

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 16) {
        ForEach(store.images) { image in
          Image(uiImage: image.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onAppear {
              store.downloadImageWithUrlSession(index: image.id)
            }
        }
      }
      .padding()
    }
    .onAppear {
      store.createImagesArray()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
