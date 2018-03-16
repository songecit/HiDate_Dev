//
//  UIViewController+MainNavigation.m
//  HiParty
//
//  Created by 林祖涵 on 15/11/27.
//  Copyright © 2015年 830clock. All rights reserved.
//

#import "UIViewController+MainNavigation.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

static const char *kViewControllerFromType = "kViewControllerFromType";

@implementation UIViewController (MainNavigation)

- (ViewControllerFromType)fromType
{
    return [objc_getAssociatedObject(self, kViewControllerFromType) unsignedIntegerValue];
}

- (void)setFromType:(ViewControllerFromType)fromType
{
    objc_setAssociatedObject(self, kViewControllerFromType, @(fromType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIViewController *)topViewController
{
    UIViewController *theTopVC = nil;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootViewController = delegate.window.rootViewController;
    
    UIViewController *topVC = nil;
    UIViewController *presentingViewController = rootViewController.presentingViewController;
    
    if (presentingViewController) {
        while (presentingViewController.presentingViewController) {
            topVC = presentingViewController.presentingViewController;
        }
    } else {
        if ([rootViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *rootVC = (UINavigationController *)rootViewController;
            if (rootVC.viewControllers.count > 0) {
                theTopVC = rootVC.topViewController;
            }
        }
    }
    return theTopVC;
}

@end
