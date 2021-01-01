//
//  ChatListViewController.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/27.
//

import UIKit
import Firebase

class ChatListViewController: UIViewController {

    @IBOutlet weak var chatListTableView: UITableView!
    
    private let cellId = "cellId"
    private var chatRoooms = [ChatRoom]()
    private var chatRoomListener: ListenerRegistration?
    
    private var user: User? {
        didSet{
            navigationItem.title = user?.username
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        confirmLoggedInUser()
        fetchChatRoomsInforFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchLoginUserInfo()
    }
    
    func fetchChatRoomsInforFirestore() {
        
        chatRoomListener?.remove()
        chatRoooms.removeAll()
        chatListTableView.reloadData()
        
        chatRoomListener = Firestore.firestore().collection("chatRooms").addSnapshotListener { (snapshots, error) in   //getDocuments { (snapshots, error) in
            if let error = error {
                print("chatRooms의 정보를 취득하는데 실폐 했습니다. \(error)")
                return
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                
                switch documentChange.type {
                case .added:
                    self.handleAddedDocumentChange(documentChange: documentChange)
                case .modified:
                    print("nothing to do")
                case .removed:
                    print("nothing to do")
                }
            })
        }
    }
    
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        
        let dic = documentChange.document.data()
        let chatRoom = ChatRoom(dic: dic)
        chatRoom.documentId = documentChange.document.documentID
            
        print("dic count : \(dic.count),  dic : \(dic)")
            
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let isContain = chatRoom.members.contains(uid)
        
        if !isContain { return }
        
        chatRoom.members.forEach { (memberUid) in
                
            if memberUid != uid {
                Firestore.firestore().collection("user").document(memberUid).getDocument { (userSnapshot, error) in
                    if let error = error {
                        print("user의 정보를 취득하는데 실폐 했습니다 \(error)")
                        return
                    }

                    guard let userDic = userSnapshot?.data() else { return }
                    let user = User(dic: userDic)
                    user.uid = documentChange.document.documentID
                    chatRoom.partnerUser = user
                    
                    guard let chatRoomDocumentId = chatRoom.documentId else { return }
                    let lastedMessageId = chatRoom.latestMessageId
                    
                    if lastedMessageId == "" {
                        self.chatRoooms.append(chatRoom)
                        self.chatListTableView.reloadData()
                        return
                    }
                    
                    Firestore.firestore().collection("chatRooms").document(chatRoomDocumentId).collection("messages").document(lastedMessageId).getDocument { (messageSnapshot, error) in
                        
                        if let error = error {
                            print("chatRoom 의 최신정보를 취득하는데 실폐 했습니다 \(error)")
                            return
                        }
                     
                        guard let messageDic = messageSnapshot?.data() else { return }
                        let message = Messages(dic: messageDic)
                        chatRoom.lastedMessage = message

                        self.chatRoooms.append(chatRoom) //print(" chatRooms count: ", self.chatRoooms.count )
                        self.chatListTableView.reloadData()
                    }
                }
            }
        }
    }

    
    private func setupViews() {
        
        self.chatListTableView.tableFooterView = UIView()
        self.chatListTableView.dataSource = self
        self.chatListTableView.delegate = self
        
        // 네비게이션 바 배경 색
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "Title"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.white]
        
        // 네비게이션 바 버턴 생성
        let rightBarButton = UIBarButtonItem(title: "친구 목록", style: .plain, target: self, action: #selector(tappedNavigationRightButton))
        let logoutBarButton = UIBarButtonItem(title: "로그 아웃", style: .plain, target: self, action: #selector(tappedNavigationLogoutButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem = logoutBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    
    // 최신 차트 스토리 보드 생성
    @objc private func tappedNavigationRightButton() {
        //print("tappedNavigationRightButton : ")
        let storyboard = UIStoryboard.init(name: "UserList", bundle: nil)
        let userListViewcontroller = storyboard.instantiateViewController(identifier: "UserListViewController")
        
        let navigationViewController = UINavigationController(rootViewController: userListViewcontroller)
        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    @objc private func tappedNavigationLogoutButton() {
        
        do {
            try Auth.auth().signOut()
            pushLoginViewController()
            
        } catch let error {
            print("로그 아웃 에러 발생 : \(error.localizedDescription)")
        }
        
    }
    
    
    private func confirmLoggedInUser() {
        //
        if Auth.auth().currentUser?.uid == nil {
            pushLoginViewController()
        }
    }
    
    private func pushLoginViewController() {
        
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let signUpViewcontroller = storyboard.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        let navigation = UINavigationController(rootViewController: signUpViewcontroller)
        navigation.modalPresentationStyle = .fullScreen
        self.present(navigation, animated: true, completion: nil)
    }
    
    private func fetchLoginUserInfo() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("user").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("파이어 스토어의 유저 접속을 할수 없습니다 : \(error)")
                return
            }
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            
            let user = User(dic: dic)
            self.user = user
            
            //self.chatListTableView.reloadData()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UITableViewDataSource
extension ChatListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = chatListTableView.dequeueReusableCell(withIdentifier: "ChatListTableViewCell", for: indexPath) as? ChatListTableViewCell else { return UITableViewCell()}
        cell.chatRoom = chatRoooms[indexPath.row]
        return cell
    }
    
}
// MARK: - UITableViewDelegate
extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.user = user
        chatRoomViewController.chatRooms = chatRoooms[indexPath.row]
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
}

class ChatListTableViewCell: UITableViewCell {
    
    var chatRoom: ChatRoom? {
        // chatRoom에 데이터가 들오온 직후 didset 호출
        didSet{
            if let chatRoom = chatRoom {
                self.partnerLabel.text = chatRoom.partnerUser?.username
                self.dateLabel.text = dateformatterForDateLabel(date: chatRoom.lastedMessage?.creatAt.dateValue() ?? Date())
                self.lastedMessageLabel.text = chatRoom.lastedMessage?.message
                do {
                    let url = URL(string: chatRoom.partnerUser?.profileImageUrl ?? "")
                    let data = try Data(contentsOf: url!)
                    self.userImageView.image = UIImage(data: data)
                    
                } catch let error {
                    print("error :", error.localizedDescription )
                }
            }
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var lastedMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 30
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    private func dateformatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "Ko-Kr")
        return formatter.string(from: date)
    }
}

