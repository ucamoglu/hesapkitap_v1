import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    applyFileProtection()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func applyFileProtection() {
    let manager = FileManager.default
    let targets: [FileManager.SearchPathDirectory] = [
      .documentDirectory,
      .applicationSupportDirectory
    ]

    for target in targets {
      guard let url = manager.urls(for: target, in: .userDomainMask).first else {
        continue
      }
      do {
        try manager.setAttributes(
          [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
          ofItemAtPath: url.path
        )
      } catch {
        // Do not block app launch if protection update fails.
      }
    }
  }
}
