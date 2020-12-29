//
//  SignUpViewController.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/28.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var profileImageMainButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var registorButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageMainButton.layer.cornerRadius = 85
        profileImageMainButton.layer.borderWidth = 1
        profileImageMainButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        registorButton.layer.cornerRadius = 15
        
        profileImageMainButton.addTarget(self, action: #selector(tappedProfileImagebutton), for: .touchUpInside)
        
    }
    
    @objc private func tappedProfileImagebutton() {
         
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
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
