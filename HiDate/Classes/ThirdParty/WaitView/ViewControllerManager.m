//
//  ViewControllerManager.m
//  AS
//
//  Created by qids on 15/7/10.
//  Copyright (c) 2015年 AngusNi. All rights reserved.
//

#import "ViewControllerManager.h"
#import "ASWaitView.h"

static ViewControllerManager *controllerManager = nil;

@interface ViewControllerManager ()

@property (nonatomic, strong) ASWaitView *waitView;

@end

@implementation ViewControllerManager

+(ViewControllerManager *) shareManager
{
    if (!controllerManager)
    {
        controllerManager = [[ViewControllerManager alloc] init];
    }
    return controllerManager;
}

// 显示等待框
- (void)showWaitView:(UIView*)parentView
{
    if (_waitView)  return;
    
    _waitView = [[ASWaitView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    [parentView addSubview:_waitView];
}

// 关闭等待框
- (void)hideWaitView
{
    if (_waitView == nil) return;
    
    [_waitView closeView];
    
    [_waitView removeFromSuperview];
    
    _waitView = nil; 
}

@end
