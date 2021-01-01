//
//  ChatRoom.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/31.
//

import Foundation
import Firebase

class ChatRoom {
    
    let latestMessageId: String
    let members: [String] // ??
    let creatAt: Timestamp
    
    var partnerUser: User?
    var lastedMessage: Messages?
    var documentId: String?
    
    init(dic: [String: Any] ) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.creatAt = dic["creatAt"] as? Timestamp ?? Timestamp()
    }
}


