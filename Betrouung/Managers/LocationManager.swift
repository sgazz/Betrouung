import Combine
import CoreLocation
import Foundation

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var locationError: String?

    private let manager: CLLocationManager

    override init() {
        manager = CLLocationManager()
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestWhenInUsePermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestCurrentLocation() {
        // Ensure location services are enabled on the device
        guard CLLocationManager.locationServicesEnabled() else {
            locationError = "Lokacione usluge su isključene."
            return
        }

        switch authorizationStatus {
        case .notDetermined:
            // Do not prompt here; wait for the app to call requestWhenInUsePermission(), then handle in delegate callback
            return
        case .restricted, .denied:
            // Surface a clear error to the UI
            locationError = "Pristup lokaciji je odbijen ili ograničen."
        case .authorizedWhenInUse, .authorizedAlways:
            // Safe to request the current location
            locationError = nil
            manager.requestLocation()
        @unknown default:
            // Handle any future cases conservatively
            locationError = "Nepoznat status autorizacije lokacije."
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            // If we just became authorized, attempt to fetch the location now
            if self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways {
                self.locationError = nil
                self.manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            currentLocation = locations.last
            locationError = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationError = error.localizedDescription
        }
    }
}
