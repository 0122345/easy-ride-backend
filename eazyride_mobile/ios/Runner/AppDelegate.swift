import Flutter
import UIKit
import GoogleMaps
import CoreLocation
import dotenv

@main
@objc class AppDelegate: FlutterAppDelegate {
  var locationManager: CLLocationManager?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    dotenv.load()

    // Access the API Key from .env file
    let apiKey = dotenv.get("Google_Api_Key") ?? "Your_Fallback_API_Key"

    // Provide the API key to Google Maps SDK
    GMSServices.provideAPIKEY(apiKey)

    // Set up location manager
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager?.requestWhenInUseAuthorization()
    locationManager?.startUpdatingLocation()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

 
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      print("Current Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
  }
}
