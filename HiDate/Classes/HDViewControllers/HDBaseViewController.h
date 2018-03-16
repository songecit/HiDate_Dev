//
//  HDBaseViewController.h
//  HiDate
//
//  Created by HiDate on 16/6/23.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDBaseViewController : UIViewController

// 自定义返回方法
- (void)setupBackItemWithAction:(SEL)action;

- (UIBarButtonItem *)createNavSpaceItem:(int)width;

/**
 *  根据文字或者图片信息创建BarButton
 *
 *  @param text  Button显示的文字
 *  @param imageInfo  图片信息（路径或者Base64）
 *  @param tag   Button的tag值，回调时用到
 *  @param action 触发的方法
 */
- (UIBarButtonItem *)createBarItemWithText:(NSString *)text andImage:(NSString *)imageInfo andTag:(NSInteger)tag andAction:(SEL)action;

@end
