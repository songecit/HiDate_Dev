//
//  UIBarButtonItem+Extention.swift
//  WeDate
//
//  Created by 靳志远 on 16/6/21.
//  Copyright © 2016年 HiDate. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    // 定义便利构造函数的原因：在extension中不可以定义指定构造函数
    // 设置参数可以传空
    /// 自定义便利构造函数
    convenience init(title: String? = nil, image:String? = nil, highlightedImage:String? = nil, target: AnyObject? = nil, action: Selector) {
        // 便利构造函数需要调用其他构造函数
        self.init()
        
        let button = UIButton(type: .custom)
        button .addTarget(target, action: action, for: .touchUpInside)
        
        // 标题
        if  let t = title {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            button.setTitleColor(UIColor.white, for: UIControlState())
            button.setTitle(t, for: UIControlState())
        }
        
        // 图片
        if let img = image {
            button.setImage(UIImage(named: img), for: UIControlState())
        }
        
        if let highlightedImg = highlightedImage {
            button.setImage(UIImage(named: highlightedImg), for: .highlighted)
        }
        button.sizeToFit()
        customView = button
    }
}
