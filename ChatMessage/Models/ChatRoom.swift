//
//  ChatRoom.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/31.
//

import Foundation
import Firebase

class ChatRoom {
    
    let leastMessageId: String
    let members: String
    let creatAt: Timestamp
    
    var partnerUser: User?
    
    init(dic:[String: Any] ) {
        self.leastMessageId = dic["leastMessageId"] as? String ?? ""
        self.members = dic["members"] as? String ?? ""
        self.creatAt = dic["creatAt"] as? Timestamp ?? Timestamp()
    }
}


