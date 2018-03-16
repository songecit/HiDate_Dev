//
//  HDImitateNavgationBar.h
//  HiDate
//
//  Created by qidangsong on 16/9/23.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDImitateNavgationBar : UIView

@property (nonatomic, copy) void (^clickBackButtonBlock) ();

- (void)updateTitle:(NSString *)title;

@end
