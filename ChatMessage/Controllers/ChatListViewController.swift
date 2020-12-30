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
    
    private var users = [User]() // 클래스 User를 배열 생성
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chatListTableView.dataSource = self
        chatListTableView.delegate = self
        
        // 네비게이션 바 배경 색
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "Title"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.white]

        // 네비게이션 바 버턴 오른쪽에 생성
        let rightBarButton = UIBarButtonItem(title: "최신 차트", style: .plain, target: self, action: #selector(tappedNavigationRightButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        
        //
        if Auth.auth().currentUser?.uid == nil {
            // MARK: - SignUp View Controller
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpviewcontroller = storyboard.instantiateViewController(identifier: "SignUpViewController")
            
            signUpviewcontroller.modalPresentationStyle = .fullScreen
            self.present(signUpviewcontroller, animated: true, completion: nil)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 파이어 스토어에서 대화방 가져와서 리스트 테이블에 뿌려줌!
        fetchUserInfoFromFirestore()
    }
    
    // 최신 차트 스토리 보드 생성
    @objc private func tappedNavigationRightButton() {
        //print("tappedNavigationRightButton : ")
        let storyboard = UIStoryboard.init(name: "UserList", bundle: nil)
        let userListViewcontroller = storyboard.instantiateViewController(identifier: "UserListViewController")
        
        let navigationViewController = UINavigationController(rootViewController: userListViewcontroller)
        self.present(navigationViewController, animated: true, completion: nil)
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
                
                //self.users.insert(user, at: 0) // users 배열에 추가
                self.users.append(user)
                
                self.chatListTableView.reloadData()
                
//                self.users.forEach { (user) in
//                    print("username: \(user.username)")
//                }
                
                //print("파이어 스토어 콜렉션 유저 도큐멘트를 다운로드 합니다: data count = \(dic.count) :: ", dic)
            })
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
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = chatListTableView.dequeueReusableCell(withIdentifier: "ChatListTableViewCell", for: indexPath) as? ChatListTableViewCell else { return UITableViewCell()}
        cell.user = users[indexPath.row]
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
    
    var user: User? {
        didSet{
            
            if let user = user {
                self.partnerLabel.text = user.username
                //self.userImageView.image = UIImage(named: String(describing: user.profileImageUrl))
                print("user Image Name : \(String(describing: user.profileImageUrl))")
                self.dateLabel.text = dateformatterForDateLabel(date: user.creatAt.dateValue())
                self.lastedMessageLabel.text = user.email
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
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "Ko-Kr")
        return formatter.string(from: date)
    }
}

