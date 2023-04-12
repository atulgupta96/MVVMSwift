//
//  PostListingViewModel.swift
//  ProjectMVVM
//
//  Created by Atul Gupta on 04/01/23.
//

import Foundation
import SwiftUI

enum PostListingViewActions {
    case getPosts(_ page: Int)
}

class PostListingViewModel: ObservableObject {
    
    //MARK: Callbacks
    var errorCallback: ((String) -> Void)?
    var getPostsCallback: ((GetPostsOutput) -> Void)?
    
    //MARK: - Action
    func callAsFunction(_ action: PostListingViewActions) {
        switch action {
        case .getPosts(let page): getPosts(page)
        }
    }
    
    //MARK: Private Variables
    private let session = URLSession(configuration: .default)
    
    private func getPosts(_ page: Int) {
        let api = APIService.getPosts(page)
        let router = APIRouter<GetPostsOutput>(session)
        router.request(api) { [weak self] output, statusCode, error in
            guard let self = self else {return}
            if let response = output {
                self.getPostsCallback?(response)
            } else if let error = error {
                self.errorCallback?(error.localizedDescription)
            } else {
                self.errorCallback?("Something went wrong!")
            }
        }
    }
}
