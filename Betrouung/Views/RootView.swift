import SwiftUI

struct RootView: View {
    @StateObject private var container = AppContainer()
    @StateObject private var profilesViewModel: CareProfileViewModel
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isShowingSplash = true
    @State private var hasCompletedCareCartEntry = false
    @State private var flowAccent: AppFlowAccent = .neutral

    init() {
        let container = AppContainer()
        _container = StateObject(wrappedValue: container)
        _profilesViewModel = StateObject(
            wrappedValue: CareProfileViewModel(dataService: container.dataService)
        )
    }

    var body: some View {
        Group {
            if isShowingSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isShowingSplash = false
                    }
                }
            } else if authViewModel.isAuthenticated {
                if hasCompletedCareCartEntry {
                    NavigationStack {
                        HomeView(viewModel: profilesViewModel) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                flowAccent = .neutral
                                hasCompletedCareCartEntry = false
                            }
                        }
                    }
                    .environment(\.appFlowAccent, flowAccent)
                    .tint(flowAccent.primary)
                } else {
                    CareCartEntryView { choice in
                        withAnimation(.easeInOut(duration: 0.25)) {
                            flowAccent = choice
                            hasCompletedCareCartEntry = true
                        }
                    }
                }
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
        .environmentObject(container)
        .animation(.easeInOut(duration: 0.25), value: isShowingSplash)
        .animation(.easeInOut(duration: 0.25), value: authViewModel.isAuthenticated)
        .animation(.easeInOut(duration: 0.25), value: hasCompletedCareCartEntry)
        .onChange(of: authViewModel.isAuthenticated) { _, isAuthed in
            if !isAuthed {
                hasCompletedCareCartEntry = false
                flowAccent = .neutral
            }
        }
    }
}

#Preview {
    RootView()
}
