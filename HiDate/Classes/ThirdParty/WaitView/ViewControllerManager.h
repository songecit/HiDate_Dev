//
//  ViewControllerManager.h
//  AS
//
//  Created by qids on 15/7/10.
//  Copyright (c) 2015年 AngusNi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ViewControllerManager : NSObject

+(ViewControllerManager *) shareManager;

// 显示等待框
- (void)showWaitView:(UIView*)parentView;

// 关闭等待框
- (void)hideWaitView;

@end
