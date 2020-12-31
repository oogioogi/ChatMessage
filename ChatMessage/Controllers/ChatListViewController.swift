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
    
    private var user: User? {
        didSet{
            navigationItem.title = user?.username
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        confirmLoggedInUser()
        fetchLoginUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchChatRoomsInforFirestore()
    }
    
    private func fetchChatRoomsInforFirestore() {
        Firestore.firestore().collection("chatRooms").getDocuments { (snapshots, error) in
            
            if let error = error {
                print("chatRooms의 정보를 취득하는데 실폐 했습니다. \(error)")
                return
            }
            print("chatRooms을 정보를 취득하는데 성공 했습니다: ")
            
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let chatRoom = ChatRoom(dic: dic)
                
                print("dic count : \(dic.count),  dic : \(dic)")
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                chatRoom.members.forEach { (memberUid) in
                    
                    if memberUid != uid {
                        Firestore.firestore().collection("user").document(memberUid).getDocument { (snapshot, error) in
                            if let error = error {
                                print("user의 정보를 취득하는데 실폐 했습니다 \(error)")
                                return
                            }
    
                            guard let snapshot = snapshot else { return }
                            guard let dic = snapshot.data() else { return }
                            
                            let user = User(dic: dic)
                            user.uid = snapshot.documentID
                            chatRoom.partnerUser = user
                            self.chatRoooms.append(chatRoom) //print(" chatRooms count: ", self.chatRoooms.count )
                            
                            self.chatListTableView.reloadData()
                        }
                    }
                }
            })
        }
    }
    
    // 최신 차트 스토리 보드 생성
    @objc private func tappedNavigationRightButton() {
        //print("tappedNavigationRightButton : ")
        let storyboard = UIStoryboard.init(name: "UserList", bundle: nil)
        let userListViewcontroller = storyboard.instantiateViewController(identifier: "UserListViewController")
        
        let navigationViewController = UINavigationController(rootViewController: userListViewcontroller)
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    private func setupViews() {
        self.chatListTableView.dataSource = self
        self.chatListTableView.delegate = self
         
        // 네비게이션 바 배경 색
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "Title"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.white]

        // 네비게이션 바 버턴 오른쪽에 생성
        let rightBarButton = UIBarButtonItem(title: "채팅목록", style: .plain, target: self, action: #selector(tappedNavigationRightButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    private func confirmLoggedInUser() {
        //
        if Auth.auth().currentUser?.uid == nil {
            // MARK: - SignUp View Controller
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpviewcontroller = storyboard.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
            
            signUpviewcontroller.modalPresentationStyle = .fullScreen
            self.present(signUpviewcontroller, animated: true, completion: nil)
        }
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

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController")
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
}

class ChatListTableViewCell: UITableViewCell {
    
//    var user: User? {
//        didSet{
//
//            if let user = user {
//                self.partnerLabel.text = user.username
//                //self.userImageView.image = UIImage(named: String(describing: user.profileImageUrl))
//                print("user Image Name : \(String(describing: user.profileImageUrl))")
//                self.dateLabel.text = dateformatterForDateLabel(date: user.creatAt.dateValue())
//                self.lastedMessageLabel.text = user.email
//            }
//
//        }
//    }
    
    var chatRoom: ChatRoom? {
        didSet{
            
            if let chatRoom = chatRoom {
                self.partnerLabel.text = chatRoom.partnerUser?.username
                self.dateLabel.text = dateformatterForDateLabel(date: chatRoom.creatAt.dateValue())
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
        
        userImageView.layer.cornerRadius = 35
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    private func dateformatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "Ko-Kr")
        return formatter.string(from: date)
    }
}

