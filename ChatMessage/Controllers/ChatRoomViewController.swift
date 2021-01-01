//
//  ChatRoomViewController.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/27.
//

import UIKit
import Firebase

class ChatRoomViewController: UIViewController {

    var user: User?
    var chatRooms: ChatRoom?
    
    private let cellId = "cellId"
    private var message = [Messages]()
    
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chatRoomTableView.dataSource = self
        chatRoomTableView.delegate = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        chatRoomTableView.contentInset = .init(top: 0, left: 0, bottom: 40, right: 0)
        chatRoomTableView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 40, right: 0)
        
        fetchMessages()
        
    }
    
    override var inputAccessoryView: UIView? {
        get{
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func fetchMessages() {
        
        guard let documentId = chatRooms?.documentId else { return }
        
        Firestore.firestore().collection("chatRooms").document(documentId).collection("messages").addSnapshotListener { (snapshots, error) in
            
            if let error = error {
                print("messages 정보의 취득에 실패 했습니다 : \(error)")
                return
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let message = Messages(dic: dic)
                    self.message.append(message)
                    
                    // 시간 정렬
                    self.message.sort { (m1, m2) -> Bool in
                        
                        let m1Time = m1.creatAt.dateValue()
                        let m2Time = m2.creatAt.dateValue()
                        
                        return m1Time < m2Time
                    }
                    self.chatRoomTableView.reloadData()
                    self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.message.count - 1, section: 0), at: .bottom, animated: true)
                    
                    //print("message : \(dic)")
                case .modified:
                    print("nothing to do")
                case .removed:
                    print("nothing to do")
                }
            })
            
        }
    }
    
}

extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
    }
    
    private func addMessageToFirestore(text: String) {
        guard let documentId = chatRooms?.documentId else { return }
        
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let profileImageUrl = user?.profileImageUrl else { return }
        chatInputAccessoryView.removeText()
        
        let messageId = randomString(lenth: 20)
        
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text,
            "profileImageUrl" : profileImageUrl
        ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(documentId).collection("messages").document(messageId).setData(docData) { (error) in
            
            if let error = error {
                print("messages 정보의 저장에 실패 했습니다 : \(error)")
                return
            }
            
            let latestMessageData = [
                "latestMessageId": messageId
            ] as [String: Any]
            Firestore.firestore().collection("chatRooms").document(documentId).updateData(latestMessageData) { (error) in
                if let error = error {
                    print("messages 정보의 저장에 실패 했습니다 : \(error)")
                    return
                }
            }
            print("messages 정보의 저장에 성공 했습니다 : ")
        }
    }
    
    // MARK: - 메세지 아이디 생성 을 위한 랜덤 함수
    func randomString(lenth: Int) -> String {
        
        let letter: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letter.length)
        
        var randomString = ""
        for _ in 0..<lenth {
            let rand = arc4random_uniform(len)
            var nextchar = letter.character(at: Int(rand))
            randomString += NSString(characters: &nextchar, length: 1) as String
        }
        return randomString
    }
    
}

extension ChatRoomViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 30
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? ChatRoomTableViewCell else { return UITableViewCell() }
        cell.message = message[indexPath.row]
        return cell
    }
    
}

extension ChatRoomViewController: UITableViewDelegate {
    
}
