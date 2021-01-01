//
//  LoginViewController.swift
//  ChatMessage
//
//  Created by 이용석 on 2021/01/01.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 15
        dontHaveAccountButton.addTarget(self, action: #selector(tappedDontHaveAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
    }
    
    @objc private func tappedDontHaveAccountButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappedLoginButton() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                print("로그인에 실패했습니다! : \(error)")
                return
            }
            
            print("로그인에 성공 했습니다!.")
            
            let navigation = self.presentingViewController as! UINavigationController
            let chatListViewController = navigation.viewControllers[navigation.viewControllers.count - 1] as? ChatListViewController
            
            chatListViewController?.fetchChatRoomsInforFirestore()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
