//
//  HDReceivedRedPaperView.h
//  HiDate
//
//  Created by qidangsong on 16/9/21.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDReceivedRedPaperView : UIView

@property (nonatomic, copy) void (^clickBackButtonBlock) ();

@property (nonatomic, copy) void (^jumpToRecordLinkBlock) ();

- (void)Initialization;

/**
 *  更新数据
 */
- (void)updateAvatar:(NSString *)imageUrl andNickName:(NSString *)name andAmount:(NSInteger)amount;

@end
