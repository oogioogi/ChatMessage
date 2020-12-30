//
//  User.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/30.
//

import Foundation
import Firebase

class User {
    
    let email: String
    let username: String
    let creatAt: Timestamp
    let profileImageUrl: String
    
    init(dic: [String : Any]) {
        
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.creatAt = dic["creatAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        
    }
}
