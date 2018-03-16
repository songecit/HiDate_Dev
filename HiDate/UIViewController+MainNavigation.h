//
//  UIViewController+MainNavigation.h
//  HiParty
//
//  Created by 林祖涵 on 15/11/27.
//  Copyright © 2015年 830clock. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ViewControllerFromType) {
    ViewControllerFromTypeNormal,
    ViewControllerFromTypeNaviPush,
    ViewControllerFromTypeNaviPop
};

@interface UIViewController (MainNavigation)

@property (nonatomic, assign) ViewControllerFromType fromType;

+ (UIViewController *)topViewController;

@end
