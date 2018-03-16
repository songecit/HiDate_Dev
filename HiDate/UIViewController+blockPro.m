//
//  UIViewController+blockPro.m
//  HiParty
//
//  Created by HiDate on 16/1/21.
//  Copyright © 2016年 830clock. All rights reserved.
//

#import "UIViewController+blockPro.h"
#import <objc/runtime.h>

static const char *kAdditionalBlock = "kAdditionalBlock";

@implementation UIViewController (blockPro)

- (void)setAdditionalBlock:(void (^)(NSDictionary *))additionalBlock
{
    objc_setAssociatedObject(self, kAdditionalBlock, additionalBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSDictionary *))additionalBlock
{
    return objc_getAssociatedObject(self, kAdditionalBlock);
}

@end
