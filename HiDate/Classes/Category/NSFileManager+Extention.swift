//
//  NSFileManager+Extention.swift
//  HiDate
//
//  Created by 靳志远 on 16/6/30.
//  Copyright © 2016年 HiDate. All rights reserved.
//

import Foundation

extension FileManager {
    /// 根据路径获取大小（文件、文件夹都可以）
    class func getSizeWithPath(path: String) -> (Float) {
        let manager = FileManager.default
        if manager.fileExists(atPath: path) == false {
            // 文件不存在
            return 0
        }
        
        var size: Float = 0
        
        // 判断是否是文件夹
        var isDirectory: ObjCBool = ObjCBool(false)
        let exists: Bool = manager.fileExists(atPath: path, isDirectory: &isDirectory)
        if exists && isDirectory.boolValue {
            // 文件夹
            do {
                let files: NSArray = try manager.subpathsOfDirectory(atPath: path) as NSArray
                let dirEnumerator = files.objectEnumerator ()
                while let file: String = dirEnumerator.nextObject() as? String {
                    
                    let filePath = path.appending("/\(file)");
                    size = size + FileManager.getFileSizeWithPath(path: filePath)
                }
                
            }catch {
                print(error)
                return 0
            }
            
        } else if exists {
            // 文件
            size = self.getFileSizeWithPath(path: path)
        }
        return size
    }
    
    /// 根据路径获取文件大小（注意：文件不是文件夹）
    private class func getFileSizeWithPath(path: String) -> (Float) {
        let manager = FileManager.default
        
        if manager.fileExists(atPath: path) == false {
            // 文件不存在
            return 0
        }
        
        do {
            let result = try manager.attributesOfItem(atPath: path)
            let size = result[FileAttributeKey.size]
            return Float("\(size!)")!
            
        }catch {
            print(error)
            return 0
        }
    }
}
