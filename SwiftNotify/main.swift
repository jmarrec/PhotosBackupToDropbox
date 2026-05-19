import AppKit
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    let waitForAction = CommandLine.arguments.contains("--wait")
    lazy var filteredArgs: [String] = CommandLine.arguments.filter { $0 != "--wait" }

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard filteredArgs.count >= 3 else {
            fputs("Usage: SwiftNotify [--wait] <title> <message> [subtitle]\n", stderr)
            exit(1)
        }

        let title = filteredArgs[1]
        let message = filteredArgs[2]
        let subtitle = filteredArgs.count >= 4 ? filteredArgs[3] : nil

        let center = UNUserNotificationCenter.current()
        center.delegate = self

        if waitForAction {
            let closeAndStartAction = UNNotificationAction(
                identifier: "CLOSE_AND_START",
                title: "Close Photos & Start",
                options: []
            )
            let skipAction = UNNotificationAction(
                identifier: "SKIP",
                title: "Skip Tonight",
                options: [.destructive]
            )
            let category = UNNotificationCategory(
                identifier: "WAIT_CATEGORY",
                actions: [closeAndStartAction, skipAction],
                intentIdentifiers: [],
                options: [.customDismissAction]
            )
            center.setNotificationCategories([category])
        }

        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else {
                fputs("Notification permission not granted\n", stderr)
                exit(1)
            }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = message
            if let sub = subtitle {
                content.subtitle = sub
            }
            content.sound = .default
            if self.waitForAction {
                content.categoryIdentifier = "WAIT_CATEGORY"
            }

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
            )

            center.add(request) { error in
                if let err = error {
                    fputs("Failed: \(err)\n", stderr)
                    exit(1)
                }
                if !self.waitForAction {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    // Called when user interacts with a --wait notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        switch response.actionIdentifier {
        case "CLOSE_AND_START":
            NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.Photos").first?.terminate()
            exit(0)
        case "SKIP":
            exit(1)
        default:
            exit(0)  // User dismissed the notification
        }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
