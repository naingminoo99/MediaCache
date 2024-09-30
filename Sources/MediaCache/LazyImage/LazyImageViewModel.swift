// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Swift
import Kingfisher

public protocol URLLoader {
    func loadURL(forKey key: String) async throws -> URL?
}
extension LazyImageView {
    
    enum ViewState: Equatable, Hashable {
        case loading, loaded, error(any Error)
        
        
        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.loaded, .loaded):
                return true
            case (.error(_), .error(_)):
                return false
            default:
                return false
            }
        }
        
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .loading:
                hasher.combine("loading")
            case .loaded:
                hasher.combine("loaded")
            case .error(let error):
                hasher.combine((error as NSError).domain)
                hasher.combine((error as NSError).code)
            }
        }
        
    }
    
    
    @Observable
    class ViewModel {
        var viewState: ViewState
        var key: String
        var url: URL?
        private var urlLoader: URLLoader
        
        @MainActor
        init(key: String, urlLoader: URLLoader) {
            self.viewState = .loading
            self.key = key
            self.urlLoader = urlLoader
            loadURL()
        }
        
        // load URL using URLLoader
        @MainActor
        func loadURL() {
            Task {
                do {
                    if let presign = try await urlLoader.loadURL(forKey: key) {
                        DispatchQueue.main.async {
                            withAnimation {
                                self.url = presign
                                self.viewState = .loaded
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.viewState = .error(error)
                    }
                }
            }
        }
    }
}
