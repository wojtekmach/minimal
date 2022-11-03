import SwiftUI

@main
struct Main: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(String(cString: hello()))
        }
        .frame(minWidth: 400, minHeight: 400)
        .padding()
    }
}
