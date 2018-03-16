//
//  UILabel+Extention.swift
//  WeDate
//
//  Created by 靳志远 on 16/6/22.
//  Copyright © 2016年 HiDate. All rights reserved.
//

import UIKit

extension UILabel {
    convenience init(textColor: UIColor, font: UIFont, maxWidth: CGFloat = 0) {
        self.init()
        self.textColor = textColor
        self.font = font
        if maxWidth > 0 {
            numberOfLines = 0
            preferredMaxLayoutWidth = maxWidth
        }
    }
}
