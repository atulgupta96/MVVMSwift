//
//  Post.swift
//  ProjectMVVM
//
//  Created by Atul Gupta on 03/01/23.
//

import Foundation

struct GetPostsOutput: Codable {
    let posts: [Post]
    let total, limit: Int
}

struct Post: Codable {
    let id: Int
    let title, body: String
}
