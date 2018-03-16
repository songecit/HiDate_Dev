//
//  HDUploadVideoProgressView.h
//  HiDate
//
//  Created by qidangsong on 16/11/8.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDUploadVideoProgressView : UIView

@property (assign, nonatomic) CGFloat uploadProgressValue;


// 增加回调
@property (nonatomic, copy) void(^cancelUploadOprete)();

@end
