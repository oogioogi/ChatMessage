//
//  Messages.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/31.
//

import Foundation
import Firebase

class Messages {
    
    let creatAt: Timestamp
    let uid: String
    let message: String // ??
    let name: String
    let profileImageUrl: String
    
    init(dic: [String: Any] ) {
        self.creatAt = dic["creatAt"] as? Timestamp ?? Timestamp()
        self.uid = dic["uid"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.name = dic["name"] as? String ?? ""
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
    }
}
