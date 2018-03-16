//
//  HPVideoTool.swift
//  videoTest
//
//  Created by 靳志远 on 16/6/28.
//  Copyright © 2016年 830clock. All rights reserved.
//

import UIKit
import AVFoundation

class HDCompressVideoTool: NSObject {
    typealias CompleteClosure = (_ isSuccess: Bool, _ outputURL: URL?, _ inputURL: URL) -> ()
    
    /// 压缩视频
    class func compress(_ url: URL, complete: CompleteClosure?) -> () {
        // 移除上一个压缩的视频
        self.removeBeforeCopressVideo()
        
        let inputURL = url
        let outputURL = URL(fileURLWithPath: self.tmpVideoPath())
        
        let asset = AVURLAsset(url: url, options: nil)
        let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
        session?.outputFileType = AVFileTypeMPEG4
        session?.outputURL = outputURL
        
        session?.exportAsynchronously(completionHandler: {
            if session?.status == AVAssetExportSessionStatus.completed {
                // 压缩成功
                if complete != nil {
                    complete!(true, outputURL, inputURL)
                }
            }else {
                // 压缩失败
                if complete != nil {
                    complete!(false, outputURL, inputURL)
                }
            }
        })
    }
    
    /// 获取视频时长
    class func getDurationWithURL(_ url: URL) -> Double {
        var duration = 0.0
        let asset = AVURLAsset(url: url, options: nil)
        duration = Double(asset.duration.value) / Double(asset.duration.timescale)
        return duration
    }
    
    /// 压缩成功后储存路径
    fileprivate class func tmpVideoPath() -> String {
        var path = NSTemporaryDirectory() as NSString
        path = path.appendingPathComponent("compress") as NSString
        path = path.appending(".mp4") as NSString
        return path as String
    }
    
    /// 移除上一个压缩的视频
    fileprivate class func removeBeforeCopressVideo() -> () {
        do {
            let path = self.tmpVideoPath()
            
            let isExists = FileManager.default.fileExists(atPath: path)
            if isExists == true {
                try FileManager.default.removeItem(atPath: self.tmpVideoPath())
            }
            
        }catch {
            print(error)
        }
    }
}
