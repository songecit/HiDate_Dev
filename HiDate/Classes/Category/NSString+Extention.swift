//
//  NSString+Extention.swift
//  WeDate
//
//  Created by 靳志远 on 16/6/21.
//  Copyright © 2016年 HiDate. All rights reserved.
//

import UIKit

extension NSString {
    /// 获取UUID
    class func UUIDString() -> NSString {
        let UUID = CFUUIDCreate(nil)
        let str = CFUUIDCreateString(nil, UUID)
        return CFBridgingRetain(str) as! NSString
    }
    
    /// 获取字符串size
    func size(_ font: UIFont, maxSize:CGSize) -> CGSize {
        let rect = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine] , attributes: [NSFontAttributeName: font], context: nil)
        return rect.size
    }
    
    /// 去除字符串中空格
    func trimWhitespace() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    /// 字符串反转
    func reverse() -> NSString {
        var length = self.length
        
        let mutableString = NSMutableString(capacity: length)
        
        while length > 0 {
            length -= 1
            let ascciCode = self.character(at: length)
            let tempString = String(describing: UnicodeScalar(ascciCode))
            mutableString.append(tempString)
        }
        return mutableString
    }
    
    /// 获取有效长度 英文1个长度 汉字，表情等 2个长度
    func validLength() -> NSInteger {
        var stringLength:NSInteger = 0
        self.enumerateSubstrings(in: NSMakeRange(0, self.length),options: .byComposedCharacterSequences) { (substring, substringRange, enclosingRange, stop) in
            if let subStr = substring {
                let subNSStr = NSString(string: subStr)
                let unsignCode = subNSStr.character(at: 0)
                if subNSStr.length == 1 && unsignCode < 256 {
                    stringLength += 1
                } else {
                    stringLength += 2
                }
            }
        }
        return stringLength
    }
    
    ///判断是否是有效字符，用于密码判断，只能为ASCII 33-126
    func isValidPassword() -> Bool {
        var isValid = true;
        self.enumerateSubstrings(in: NSMakeRange(0, self.length), options: .byComposedCharacterSequences) { (substring, substringRange, enclosingRange, stop) in
            if let subStr = substring {
                let subNSStr = NSString(string: subStr)
                let unsignCode = subNSStr.character(at: 0)
                if subNSStr.length == 1 && (unsignCode > 32 && unsignCode < 127 ) {
                } else {
                    isValid = false
                }
            }
        }
        return isValid
    }
    
    /// 沙盒Document路径
    class func documentPath(_ fileName: String) -> String {
        let path: NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString
        return path.appendingPathComponent(fileName)
    }
    
    /// 沙盒Cache路径
    class func cachePath(_ fileName: String) -> String {
        let path: NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString
        return path.appendingPathComponent(fileName)
    }
    
    /// 沙盒Tmp路径
    class func tmpPath(_ fileName: String) -> String {
        let path: NSString = NSTemporaryDirectory() as NSString
        return path.appendingPathComponent(fileName)
    }
    
    /// base64编码
    func base64Encode() -> String {
        let data = self.data(using: String.Encoding.utf8.rawValue)
        return data!.base64EncodedString(options: [])
    }
    
    /// base64解码
    func base64Decode() -> String {
        let data = Data(base64Encoded: self as String, options: [])
        return String(data: data!, encoding: String.Encoding.utf8)!
    }
    
}
