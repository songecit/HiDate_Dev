//
//  HDBaseNavigationController.m
//  HiDate
//
//  Created by HiDate on 16/6/23.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDBaseNavigationController.h"
@interface HDBaseNavigationController ()<
UINavigationControllerDelegate,
UIGestureRecognizerDelegate
>

@end

@implementation HDBaseNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    // 如果是push根控制器什么也不做
    if (self.childViewControllers.count != 0) {
        // 隐藏底部tabBar
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
//        if (self.viewControllers.count <= 1) {
//            self.interactivePopGestureRecognizer.enabled = NO;
//        } else {
//            self.interactivePopGestureRecognizer.enabled = YES;
//        }
    
        // 2016年08月03日：去掉左滑返回功能
        self.interactivePopGestureRecognizer.enabled = NO;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
//    if (self.viewControllers.count <= 1) {
//        return NO;
//    }
//    
//    return YES;

    // 2016年08月03日：去掉左滑返回功能
    return NO;
}


- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPop) {
        toVC.fromType = ViewControllerFromTypeNaviPop;
    } else if (operation == UINavigationControllerOperationPush) {
        toVC.fromType = ViewControllerFromTypeNaviPush;
    } else {
        toVC.fromType = ViewControllerFromTypeNormal;
    }
    
    return nil;
}

@end

