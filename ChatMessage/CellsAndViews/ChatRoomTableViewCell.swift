//
//  ChatRoomTableViewCell.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/27.
//

import UIKit
import Firebase

class ChatRoomTableViewCell: UITableViewCell {
    
    var message: Messages? {
        didSet{
            guard let message = message else { return }
            
            do {
                let url = URL(string: message.profileImageUrl)
                let data = try Data(contentsOf: url!)
                self.userImageView.image = UIImage(data: data)
                
            } catch let error {
                print("error :", error.localizedDescription )
            }
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    @IBOutlet weak var myMessagetextView: UITextView!
    @IBOutlet weak var myDateLabel: UILabel!
    
    @IBOutlet weak var partnerMessageTextViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var myMessageTextViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 30
        partnerMessageTextView.layer.cornerRadius = 15
        myMessagetextView.layer.cornerRadius = 15
        self.backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWhichUserMessage()
    }
    
    private func checkWhichUserMessage() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if uid == message?.uid {
            userImageView.isHidden = true
            partnerMessageTextView.isHidden = true
            partnerDateLabel.isHidden = true
            
            if let message = message {
                let width = estimatefFrameForTextView(text: message.message).width
                myMessageTextViewWidthConstraint.constant = width + 20
                myMessagetextView.text = message.message
                myDateLabel.text = dateformatterForDateLabel(date: message.creatAt.dateValue())
            }
            
            myDateLabel.isHidden = false
            myMessagetextView.isHidden = false
        }else {
            userImageView.isHidden = false
            partnerMessageTextView.isHidden = false
            partnerDateLabel.isHidden = false
            
            if let message = message {
                let width = estimatefFrameForTextView(text: message.message).width
                partnerMessageTextViewWidthConstraint.constant = width + 20
                partnerMessageTextView.text = message.message
                partnerDateLabel.text = dateformatterForDateLabel(date: message.creatAt.dateValue())
            }
            
            myDateLabel.isHidden = true
            myMessagetextView.isHidden = true
        }
        
    }
    
    
    private func estimatefFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
    }
    
    private func dateformatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "Ko-Kr")
        return formatter.string(from: date)
    }
}
