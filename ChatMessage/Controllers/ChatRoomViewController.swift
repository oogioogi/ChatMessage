//
//  ChatRoomViewController.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/27.
//

import UIKit

class ChatRoomViewController: UIViewController {

    private let cellId = "cellId"
    private var message = [String]()
    
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
        
    }
    
    override var inputAccessoryView: UIView? {
        get{
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
}

extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    
    func tappedSendButton(text: String) {
        message.append(text)
        chatInputAccessoryView.removeText()
        chatRoomTableView.reloadData()
        //print(" ChatInputAccessoryViewDelegate text: ", text)
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
        cell.messageText = message[indexPath.row]
        return cell
    }
    
}

extension ChatRoomViewController: UITableViewDelegate {
    
}
