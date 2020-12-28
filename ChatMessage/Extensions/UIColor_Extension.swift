//
//  UIColor_Extension.swift
//  ChatMessage
//
//  Created by 이용석 on 2020/12/27.
//

import Foundation
import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}
