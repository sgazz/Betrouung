import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let dataService: any DataService

    init(dataService: any DataService = LocalDataService()) {
        self.dataService = dataService
    }
}

