//
//  HDBaseWebViewLoadingView.h
//  HiParty
//
//  Created by HiDate on 16/3/28.
//  Copyright © 2016年 830clock. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HDBaseWebViewLoadingViewType) {
    HDBaseWebViewLoadingViewTypeNormal,
    HDBaseWebViewLoadingViewTypeVerbose
};

@interface HDBaseWebViewLoadingView : UIView

@property (nonatomic, assign) HDBaseWebViewLoadingViewType loadingType;

@property (nonatomic, assign) CGFloat progress;

- (void)showLoadingViewWithContentView:(UIView *)contentView;
- (void)hideLoadingView;
- (void)startLoading;
- (void)stopLoading;

@end
