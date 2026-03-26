import CoreLocation
import Foundation
import MapKit

@MainActor
final class StoreService {
    private let queries = ["supermarket", "grocery", "Lebensmittel"]

    func fetchNearbyStores(userLocation: CLLocation) async throws -> [Store] {
        var allMapItems: [MKMapItem] = []
        let region = MKCoordinateRegion(
            center: userLocation.coordinate,
            latitudinalMeters: 6_000,
            longitudinalMeters: 6_000
        )

        for query in queries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = region

            let response = try await search(request: request)
            allMapItems.append(contentsOf: response.mapItems)
        }

        let uniqueMapItems = deduplicate(allMapItems)
        return uniqueMapItems.map { item in
            let coordinate = item.placemark.coordinate
            let itemLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distanceKm = userLocation.distance(from: itemLocation) / 1_000

            return Store(
                name: item.name ?? "Nepoznat market",
                distance: distanceKm,
                isOpen: false,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        }
        .sorted { $0.distance < $1.distance }
    }

    private func search(request: MKLocalSearch.Request) async throws -> MKLocalSearch.Response {
        try await withCheckedThrowingContinuation { continuation in
            MKLocalSearch(request: request).start { response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response else {
                    continuation.resume(throwing: NSError(domain: "StoreService", code: -1))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }

    private func deduplicate(_ items: [MKMapItem]) -> [MKMapItem] {
        var seen = Set<String>()
        var result: [MKMapItem] = []

        for item in items {
            let name = item.name ?? ""
            let lat = item.placemark.coordinate.latitude
            let lon = item.placemark.coordinate.longitude
            let key = "\(name.lowercased())_\(lat)_\(lon)"
            if seen.insert(key).inserted {
                result.append(item)
            }
        }

        return result
    }
}

