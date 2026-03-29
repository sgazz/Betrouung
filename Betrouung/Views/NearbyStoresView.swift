import MapKit
import SwiftUI

struct NearbyStoresView: View {
    let profile: CareProfile
    @Environment(\.appFlowAccent) private var accent
    @StateObject private var viewModel = StoreViewModel()
    @AppStorage("app.language") private var selectedLanguageRaw = AppLanguage.english.rawValue

    private var titleText: String {
        L10n.t("nearby.title", languageCode: selectedLanguageRaw)
    }

    private var loadingText: String {
        L10n.t("nearby.loading", languageCode: selectedLanguageRaw)
    }

    private var permissionDeniedTitle: String {
        L10n.t("nearby.permission_denied_title", languageCode: selectedLanguageRaw)
    }

    private var permissionDeniedDesc: String {
        L10n.t("nearby.permission_denied_desc", languageCode: selectedLanguageRaw)
    }

    private var permissionRestrictedTitle: String {
        L10n.t("nearby.permission_restricted_title", languageCode: selectedLanguageRaw)
    }

    private var permissionRestrictedDesc: String {
        L10n.t("nearby.permission_restricted_desc", languageCode: selectedLanguageRaw)
    }

    private var emptyTitle: String {
        L10n.t("nearby.empty_title", languageCode: selectedLanguageRaw)
    }

    private var emptyDesc: String {
        L10n.t("nearby.empty_desc", languageCode: selectedLanguageRaw)
    }

    private var errorTitle: String {
        L10n.t("nearby.error_title", languageCode: selectedLanguageRaw)
    }

    private var kmAwayFormat: String {
        L10n.t("nearby.km_away_format", languageCode: selectedLanguageRaw)
    }

    private var openText: String {
        L10n.t("nearby.status.open", languageCode: selectedLanguageRaw)
    }

    private var closedText: String {
        L10n.t("nearby.status.closed", languageCode: selectedLanguageRaw)
    }

    private var locationAccessTitle: String {
        L10n.t("nearby.location_access_title", languageCode: selectedLanguageRaw)
    }

    private var locationAccessDesc: String {
        L10n.t("nearby.location_access_desc", languageCode: selectedLanguageRaw)
    }

    private var allowLocationText: String {
        L10n.t("nearby.allow_location", languageCode: selectedLanguageRaw)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            content
        }
        .navigationTitle(titleText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AppBrandTitleView(title: "DailyCareCart")
            }
        }
        .onAppear { viewModel.onAppear() }
    }

    @ViewBuilder
    private var content: some View {
            switch viewModel.state {
            case .idle:
                permissionRequestView
            case .loading:
                VStack(spacing: 12) {
                    ProgressView()
                    Text(loadingText)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .appGlassCard()
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .permissionDenied:
                stateView(
                    title: permissionDeniedTitle,
                    systemImage: "location.slash",
                    description: permissionDeniedDesc
                )
            case .permissionRestricted:
                stateView(
                    title: permissionRestrictedTitle,
                    systemImage: "location.fill.viewfinder",
                    description: permissionRestrictedDesc
                )
            case .empty:
                stateView(
                    title: emptyTitle,
                    systemImage: "building.2.crop.circle",
                    description: emptyDesc
                )
            case .error(let message):
                stateView(
                    title: errorTitle,
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
                                    .foregroundStyle(accent.primary)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(store.name)
                                        .font(.body.weight(.bold))
                                        .foregroundStyle(.primary)
                                    Text(String(format: kmAwayFormat, store.distance))
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(store.isOpen ? openText : closedText)
                                    .font(.body)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background((store.isOpen ? AppPalette.green : AppPalette.red).opacity(0.14))
                                    .foregroundStyle(store.isOpen ? AppPalette.green : AppPalette.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(16)
                            .frame(minHeight: 74)
                            .appGlassCard()
                        }
                        .buttonStyle(SecondaryCardButtonStyle())
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
    }

    private var permissionRequestView: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.circle")
                .font(.system(size: 48))
                .foregroundStyle(accent.primary)
            Text(locationAccessTitle)
                .font(.title2.bold())
            Text(locationAccessDesc)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(.secondary)
            Button(allowLocationText) {
                viewModel.requestPermission()
            }
            .buttonStyle(.borderedProminent)
            .frame(minHeight: 50)
        }
        .padding(20)
        .appGlassCard()
        .padding(.horizontal, 16)
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
        let encodedName = store.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "http://maps.apple.com/?ll=\(latitude),\(longitude)&q=\(encodedName)") else { return }
        UIApplication.shared.open(url)
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
        .appGlassCard()
    }
}

#Preview {
    NavigationStack {
        NearbyStoresView(profile: MockData.profiles[0])
    }
}

