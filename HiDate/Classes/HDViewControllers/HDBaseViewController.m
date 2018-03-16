//
//  HDBaseViewController.m
//  HiDate
//
//  Created by HiDate on 16/6/23.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDBaseViewController.h"
#import "H5WebPackPath.h"
#import "HiDate-Swift.h"

@implementation HDBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // 9以下系统
    // if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.49) {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // }
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : HDColorBarTitleColor}];
    
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = HDColorTitleBarColor;
    [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:HDColorTitleBarColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:HDColorTitleBarColor] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

// 自定义返回方法
- (void)setupBackItemWithAction:(SEL)action
{
    // 若是第一，返回按钮则不创建
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItems = @[[self createNavSpaceItem:10], [self createBackItemWithAction:action]];
    }
}

- (UIBarButtonItem *)createNavSpaceItem:(int)width
{
    UIBarButtonItem *navSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    navSpaceItem.width = - width;
    
    return navSpaceItem;
}

- (UIBarButtonItem *)createBackItemWithAction:(SEL)action
{
    UIImage *image = [UIImage imageNamed:@"back"];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    
    [btn setBackgroundImage:[UIImage imageNamed:@"back_pressed"] forState:UIControlStateHighlighted];
    
    if (action) {
        [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return btnItem;
}


- (UIBarButtonItem *)createBarItemWithText:(NSString *)text andImage:(NSString *)imageInfo andTag:(NSInteger)tag andAction:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    
    // 根据字体大小和长度计算宽度
    CGSize size = CGSizeZero;
    if (text.length > 0) {
        CGRect rect = [text boundingRectWithSize:CGSizeMake(200, 40)//限制最大的宽度和高度
                                           options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                        attributes:@{NSFontAttributeName: btn.titleLabel.font}//传人的字体字典
                                           context:nil];
        size = rect.size;
        [btn setTitle:text forState:UIControlStateNormal];
    } else {
        size = CGSizeMake(20, 40);
    }
    
    btn.frame = CGRectMake(0, 0, size.width + 10, 26);
    
    if (imageInfo.length > 0) {
       
        //图片
        UIImage *image = nil;
        UIImage* (^decodeBase64ImageString)(NSString *base64ImageString) = ^(NSString *base64ImageString){
            NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:base64ImageString
                                                                           options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *image = [UIImage imageWithData:decodedImageData];
            return image;
        };
        
        if ([imageInfo hasPrefix:@"data:image/jpeg;base64,"]) {
            //base64图片 jpeg
            imageInfo = [imageInfo stringByReplacingOccurrencesOfString:@"data:image/jpeg;base64," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 30)];
            image = decodeBase64ImageString(imageInfo);
            
        } else if ([imageInfo hasPrefix:@"data:image/png;base64,"]) {
            //base64图片 png
            imageInfo = [imageInfo stringByReplacingOccurrencesOfString:@"data:image/png;base64," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 30)];
            image = decodeBase64ImageString(imageInfo);
        } else {
            //下载到h5里面的图片(相对路径)
            NSString *H5AppSanboxPath = [HDUserDefaultTool getH5AppSanboxPath];
            if (H5AppSanboxPath && H5AppSanboxPath.length > 0) {
                imageInfo = [[[H5WebPackPath fileBaseDirectory] stringByAppendingPathComponent:H5AppSanboxPath] stringByAppendingPathComponent:imageInfo];
                image = [UIImage imageWithContentsOfFile:imageInfo];
            }
        }
        
        if (image) {
            [btn setImage:image forState:UIControlStateNormal];
        }
    }
    
    [btn.titleLabel setTextAlignment:NSTextAlignmentRight];
    
    if (action) {
        [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return btnItem;
}

@end
