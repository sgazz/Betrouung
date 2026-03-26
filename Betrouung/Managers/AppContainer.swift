import Combine
import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let dataService: any DataService

    init(dataService: any DataService) {
        self.dataService = dataService
    }

    convenience init() {
        self.init(dataService: LocalDataService())
    }
}

