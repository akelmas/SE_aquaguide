import UIKit
import Flutter
import Firebase
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDRtV1jgzCpDcSB6n7g7HFzk7BMBSZdmPE")
    GeneratedPluginRegistrant.register(with: self)
    if(FirebaseApp.app() == nil){
        FirebaseApp.configure()
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
    

}
