//
//  SignUpViewController.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/28.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var profileImageMainButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var registorButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    
    private func setupViews() {
        profileImageMainButton.layer.cornerRadius = 85
        profileImageMainButton.layer.borderWidth = 1
        profileImageMainButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        registorButton.layer.cornerRadius = 15

        profileImageMainButton.addTarget(self, action: #selector(tappedProfileImagebutton), for: .touchUpInside)
        registorButton.addTarget(self, action: #selector(tappedRegistorButton), for: .touchUpInside)

        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextfield.delegate = self

        registorButton.isEnabled = false
        registorButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        
        alreadyHaveAccountButton.addTarget(self, action: #selector(tappedAlreadyHaveButton), for: .touchUpInside)
    }
    
    @objc private func tappedAlreadyHaveButton() {
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController")

        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @objc private func tappedProfileImagebutton() {
         
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func tappedRegistorButton() {
        
        guard let image = profileImageMainButton.imageView?.image else { return } // 포로필 이미지를 파이어 베이스 스토리지에 저장
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return } // 이미지를 JEPG로 변형
        
        let filename = NSUUID().uuidString // 임이의 파일 이름을 생성
        let storageRef = Storage.storage().reference().child("profile_image").child(filename) // "profile_image" 루트 디렉토리 생성후, 임이의 파일 디렉토리 생성
        
        storageRef.putData(uploadImage, metadata: nil) { (matadata, error) in       // 이미지 업 로드
            if let error = error {
                print("파이어 베이스 스토리지에 접속을 할수 없습니다!!: \(error)")
                return
            }
            
            print("파이어 베이스에 접속을 성공 했습니다")
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("파이어 스토리지오 부터 다운 로드를 할수 없습니다! : \(error)")
                    return
                }
                guard let urlString = url?.absoluteString else { return }
                print("파이어 스토리지로부터 다운로드 했습니다: \(urlString)")
                self.creatUserToFirestore(profileImageUrl: urlString)
            }
        }

    }

    private func creatUserToFirestore(profileImageUrl: String) {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                print("레지스트 카운트 접속 실패 : ", error)
                return
            }
            print(" 레지스트 카운트 접속 성공 ")
            
            guard let uid = result?.user.uid else { return }
            guard let username = self.usernameTextfield.text else { return }
            
            let docData = [
                "email": email,
                "username": username,
                "creatAt": Timestamp(),
                "profileImageUrl": profileImageUrl
            ] as [String: Any]
            Firestore.firestore().collection("user").document(uid).setData(docData) { (error) in
                
                if let error = error {
                    print("클라우드 파이어 베이스 콜렉션 유저 생성 실패! :", error)
                }
                print("클라우드 파이어 베이스 콜렉션 유저 생성 성공!")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextfield.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            registorButton.isEnabled = false
            registorButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        }else {
            registorButton.isEnabled = true
            registorButton.backgroundColor = .rgb(red: 0, green: 185, blue: 0)
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate {
    
}

extension SignUpViewController: UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editImage = info[.editedImage] as? UIImage {
            profileImageMainButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let orignalImage = info[.originalImage] as? UIImage {
            profileImageMainButton.setImage(orignalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        // 다시 동그란 원에 이미지 바로 그리기
        profileImageMainButton.setTitle("", for: .normal)
        profileImageMainButton.imageView?.contentMode = .scaleAspectFill
        profileImageMainButton.contentHorizontalAlignment = .fill
        profileImageMainButton.contentVerticalAlignment = .fill
        profileImageMainButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
}
