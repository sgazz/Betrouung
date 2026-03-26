import MapKit
import SwiftUI

struct NearbyStoresView: View {
    let profile: CareProfile
    @StateObject private var viewModel = StoreViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                permissionRequestView
            case .loading:
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading nearby stores...")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .permissionDenied:
                stateView(
                    title: "Dozvola odbijena",
                    systemImage: "location.slash",
                    description: "Omogući lokaciju u Settings da bismo prikazali markete u blizini."
                )
            case .permissionRestricted:
                stateView(
                    title: "Lokacija nije dostupna",
                    systemImage: "location.fill.viewfinder",
                    description: "Pristup lokaciji je ograničen na ovom uređaju."
                )
            case .empty:
                stateView(
                    title: "No stores found",
                    systemImage: "building.2.crop.circle",
                    description: "Try again in a different area."
                )
            case .error(let message):
                stateView(
                    title: "Greška",
                    systemImage: "exclamationmark.triangle",
                    description: message
                )
            case .loaded:
                List {
                    if !storesWithCoordinates.isEmpty {
                        Section {
                            mapPreview
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowBackground(Color.clear)
                        }
                    }

                    ForEach(viewModel.nearbyStores) { store in
                        Button {
                            openInAppleMaps(store)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "building.2.crop.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.accentColor)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(store.name)
                                        .font(.body.weight(.bold))
                                        .foregroundStyle(.primary)
                                    Text(String(format: "%.1f km away", store.distance))
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(store.isOpen ? "Open" : "Closed")
                                    .font(.body)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(.tertiarySystemBackground))
                                    .foregroundStyle(store.isOpen ? .accentColor : .secondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(16)
                            .frame(minHeight: 74)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Marketi")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.onAppear() }
    }

    private var permissionRequestView: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.circle")
                .font(.system(size: 48))
                .foregroundStyle(.accentColor)
            Text("Pristup lokaciji")
                .font(.title2.bold())
            Text("Za prikaz marketa u blizini potrebno je da dozvoliš pristup lokaciji.")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(.secondary)
            Button("Dozvoli lokaciju") {
                viewModel.requestPermission()
            }
            .buttonStyle(.borderedProminent)
            .frame(minHeight: 50)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func stateView(title: String, systemImage: String, description: String) -> some View {
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: Text(description)
        )
    }

    private func openInAppleMaps(_ store: Store) {
        guard let latitude = store.latitude, let longitude = store.longitude else { return }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = store.name
        mapItem.openInMaps()
    }

    private var storesWithCoordinates: [Store] {
        viewModel.nearbyStores.filter { $0.latitude != nil && $0.longitude != nil }
    }

    private var mapRegion: MKCoordinateRegion {
        guard let first = storesWithCoordinates.first,
              let latitude = first.latitude,
              let longitude = first.longitude else {
            return MKCoordinateRegion()
        }
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    private var mapPreview: some View {
        Map(position: .constant(.region(mapRegion))) {
            ForEach(storesWithCoordinates) { store in
                if let latitude = store.latitude, let longitude = store.longitude {
                    Marker(store.name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                }
            }
        }
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        NearbyStoresView(profile: MockData.profiles[0])
    }
}

