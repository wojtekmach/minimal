import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var window : NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let menuItemOne = NSMenuItem()
        menuItemOne.submenu = NSMenu(title: "Example")
        menuItemOne.submenu?.items = [
            NSMenuItem(title: "Quit Example", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        ]
        let menu = NSMenu()
        menu.items = [menuItemOne]
        NSApp.mainMenu = menu

        window = NSWindow(contentRect: NSMakeRect(0, -1000, 200, 200),
                          styleMask: [.titled, .closable],
                          backing: .buffered,
                          defer: true)
        window.orderFrontRegardless()
        window.title = "Minimal"
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool {
        return true
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
