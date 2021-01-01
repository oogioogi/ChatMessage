//
//  UserListViewController.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/30.
//

import UIKit
import Firebase

class UserListViewController: UIViewController {
    
    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var startChatButton: UIButton!
    
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        startChatButton.layer.cornerRadius = 15
        startChatButton.isEnabled = false
        startChatButton.alpha = 0.5
        
        startChatButton.addTarget(self, action: #selector(tappedStartChatButton), for: .touchUpInside)
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        
        fetchUserInfoFromFirestore()
    }
    
    @objc private func tappedStartChatButton() {
        print("tappedStartChatButton : ")
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUser?.uid else { return }
        
        let members = [uid, partnerUid]
        let docData:[String : Any] = [
            "members": members,
            "leastMessageId": "",
            "creatAt": Timestamp()
        ]
        
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (error) in
            
            if let error = error {
                print("chatRooms을 생성 할수 없습니다! \(error)")
                return
            }
            self.dismiss(animated: true, completion: nil)
            print("chatRooms을 생성에 성공 했습니다")
        }
    }
    
    private func fetchUserInfoFromFirestore() {
        
        Firestore.firestore().collection("user").getDocuments { [self] (snapshots, error) in
            
            if let error = error {
                print("파이어 스토어의 유저 접속을 할수 없습니다 : \(error)")
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                
                let dic = snapshot.data()
                let user = User.init(dic: dic) // User 클래스 생성
                
                user.uid = snapshot.documentID
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                if uid == snapshot.documentID {
                    return
                }
                //self.users.insert(user, at: 0) // users 배열에 추가
                self.users.append(user)
                
                self.userListTableView.reloadData()
                
                print("파이어 스토어 콜렉션 유저 도큐멘트를 다운로드 합니다: data count = \(dic.count) :: ", dic)
            })
        }
    }
    
}

extension UserListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = userListTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? UserListTableViewCell else { return UITableViewCell() }
        cell.user = users[indexPath.row]
        return cell
    }
    
    
    
}

extension UserListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        startChatButton.isEnabled = true
        startChatButton.alpha = 1.0
        let user = users[indexPath.row]
        self.selectedUser = user
        
        print("selected user : \(selectedUser?.username)")
    }
    
}


class UserListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: User? {
        didSet{
            
            do {
                let url = URL(string: user?.profileImageUrl ?? "")
                let data = try Data(contentsOf: url!)
                self.userImageView.image = UIImage(data: data)
                
            } catch let error {
                print("error :", error.localizedDescription )
            }
            self.usernameLabel.text = user?.username
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 32.5

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    
}
