//
//  ZHRotationProgressView.h
//  GradientLayer
//
//  Created by HiDate on 16/3/28.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHRotationProgressView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL isShowProgressText;

- (void)startRound;
- (void)stopRound;

@end
