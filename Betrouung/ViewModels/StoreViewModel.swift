import Foundation
import CoreLocation
import Combine

@MainActor
final class StoreViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case permissionDenied
        case permissionRestricted
        case error(String)
    }

    @Published private(set) var nearbyStores: [Store] = []
    @Published private(set) var state: ViewState = .idle

    private let locationManager: LocationManager
    private let storeService: StoreService
    private var cancellables = Set<AnyCancellable>()

    init(
        locationManager: LocationManager,
        storeService: StoreService
    ) {
        self.locationManager = locationManager
        self.storeService = storeService

        locationManager.$authorizationStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                self?.handleAuthorizationChange(status)
            }
            .store(in: &cancellables)

        locationManager.$currentLocation
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] location in
                Task { await self?.fetchStores(for: location) }
            }
            .store(in: &cancellables)

        locationManager.$locationError
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.state = .error(error)
            }
            .store(in: &cancellables)
    }

    convenience init() {
        self.init(locationManager: LocationManager(), storeService: StoreService())
    }

    func onAppear() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            requestStoresNearUser()
        case .notDetermined:
            state = .idle
        case .denied:
            state = .permissionDenied
        case .restricted:
            state = .permissionRestricted
        @unknown default:
            state = .error("Nepoznat status dozvole.")
        }
    }

    func requestPermission() {
        locationManager.requestWhenInUsePermission()
    }

    func requestStoresNearUser() {
        state = .loading
        locationManager.requestCurrentLocation()
    }

    private func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            requestStoresNearUser()
        case .denied:
            state = .permissionDenied
        case .restricted:
            state = .permissionRestricted
        case .notDetermined:
            state = .idle
        @unknown default:
            state = .error("Nepoznat status dozvole.")
        }
    }

    private func fetchStores(for location: CLLocation) async {
        state = .loading
        do {
            let stores = try await storeService.fetchNearbyStores(userLocation: location)
            nearbyStores = stores
            state = stores.isEmpty ? .empty : .loaded
        } catch {
            nearbyStores = []
            state = .error(error.localizedDescription)
        }
    }
}

