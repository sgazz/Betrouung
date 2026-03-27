import SwiftUI

struct RootView: View {
    @StateObject private var container = AppContainer()
    @StateObject private var profilesViewModel: CareProfileViewModel
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isShowingSplash = true

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
                NavigationStack {
                    HomeView(viewModel: profilesViewModel)
                }
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
        .environmentObject(container)
        .animation(.easeInOut(duration: 0.25), value: isShowingSplash)
        .animation(.easeInOut(duration: 0.25), value: authViewModel.isAuthenticated)
    }
}

#Preview {
    RootView()
}

