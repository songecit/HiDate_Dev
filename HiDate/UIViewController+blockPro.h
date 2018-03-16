//
//  UIViewController+blockPro.h
//  HiParty
//
//  Created by HiDate on 16/1/21.
//  Copyright © 2016年 830clock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (blockPro)

@property (nonatomic, copy) void (^additionalBlock) (NSDictionary *additionParam);

@end
