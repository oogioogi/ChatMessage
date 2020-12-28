//
//  ChatInputAccessoryView.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/28.
//

import Foundation
import UIKit

// MARK: - Protocol delegate

protocol ChatInputAccessoryViewDelegate: class {
    func tappedSendButton(text: String)
}

class ChatInputAccessoryView: UIView {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTextView: UITextView!
    
    weak var delegate: ChatInputAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        nibInit()
        setupView()
        autoresizingMask = .flexibleHeight
    }
    
    private func setupView() {
        
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1
        
        sendButton.layer.cornerRadius = 15
        sendButton.imageView?.contentMode = .scaleAspectFill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
        
        chatTextView.text = ""
        chatTextView.delegate = self
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func nibInit() {
        
        let nib =  UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {return}
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.addSubview(view)
    }
    
    @IBAction func tappedSendButton(_ sender: UIButton) {
        
        guard let text = chatTextView.text else { return }
        delegate?.tappedSendButton(text: text)
    }
    
    func removeText() {
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
}

extension ChatInputAccessoryView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        
        print("chatTextView.text : ", textView.text!)
        
        //textView.text.isEmpty ? (sendButton.isEnabled = false) : (sendButton.isEnabled = true)
        if textView.text.isEmpty {
            sendButton.isEnabled = false
        }else {
            sendButton.isEnabled = true
        }
        
    }
}
