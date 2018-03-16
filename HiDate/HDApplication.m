//
//  HDApplication.m
//  HiDate
//
//  Created by HiDate on 16/6/23.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDApplication.h"

#if DEBUG
#import "FLEXManager.h"
#endif

@implementation HDApplication

- (void)motionBegan:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event
{
#if DEBUG
    if (motion == UIEventSubtypeMotionShake) {
        [[FLEXManager sharedManager] showExplorer];
    }
#endif
}

@end
