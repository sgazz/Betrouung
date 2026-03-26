import SwiftUI

struct RootView: View {
    @StateObject private var container = AppContainer()
    @StateObject private var profilesViewModel: CareProfileViewModel

    init() {
        let container = AppContainer()
        _container = StateObject(wrappedValue: container)
        _profilesViewModel = StateObject(
            wrappedValue: CareProfileViewModel(dataService: container.dataService)
        )
    }

    var body: some View {
        NavigationStack {
            HomeView(viewModel: profilesViewModel)
        }
        .environmentObject(container)
    }
}

#Preview {
    RootView()
}

