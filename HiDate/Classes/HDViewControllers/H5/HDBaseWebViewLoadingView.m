//
//  HDBaseWebViewLoadingView.m
//  HiParty
//
//  Created by HiDate on 16/3/28.
//  Copyright © 2016年 830clock. All rights reserved.
//

#import "HDBaseWebViewLoadingView.h"
#import "ZHRotationProgressView.h"

@interface HDBaseWebViewLoadingView ()

@property (weak, nonatomic) IBOutlet UILabel *verboseLabel;
@property (weak, nonatomic) IBOutlet UIView *progressLabelsContentView;
@property (strong, nonatomic) IBOutlet ZHRotationProgressView *rotationProgressView;

@property (strong, nonatomic) NSArray *verboseTextArray;

@end

@implementation HDBaseWebViewLoadingView

- (NSArray *)verboseTextArray
{
    if (!_verboseTextArray) {
        _verboseTextArray = @[
                              @"加载模板资源...",
                              @"加载图片资源...",
                              @"加载文字资源...",
                              @"加载动画资源...",
                              @"即将完成加载..."
                             ];
    }
    return _verboseTextArray;
}

- (void)setLoadingType:(HDBaseWebViewLoadingViewType)loadingType
{
    if (_loadingType == loadingType) {
        return;
    }
    
    _loadingType = loadingType;
    
    if (_loadingType == HDBaseWebViewLoadingViewTypeNormal) {
        self.progressLabelsContentView.hidden = YES;
        self.rotationProgressView.isShowProgressText = NO;
    } else {
        self.progressLabelsContentView.hidden = NO;
        self.rotationProgressView.isShowProgressText = YES;
    }
}

- (void)showLoadingViewWithContentView:(UIView *)contentView
{
    [contentView addSubview:self];
    self.frame = CGRectMake(0,
                            0,
                            CGRectGetWidth(contentView.frame),
                            CGRectGetHeight(contentView.frame));
    [self startLoading];
}

- (void)hideLoadingView
{
    [self removeFromSuperview];
    [self stopLoading];
}

- (void)startLoading
{
    [self.rotationProgressView startRound];
}
- (void)stopLoading
{
    [self.rotationProgressView stopRound];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    self.rotationProgressView.progress = _progress;
    
    [self showProgressLabelWithProgress:_progress];
}

- (void)showProgressLabelWithProgress:(CGFloat)progress
{
    NSUInteger progressLevel = 0;
    if (progress < 0.2 && progress >= 0) {
        progressLevel = 0;
    } else if (progress >= 0.2 && progress < 0.4) {
        progressLevel = 1;
    } else if (progress >= 0.4 && progress < 0.6) {
        progressLevel = 2;
    } else if (progress >= 0.6 && progress < 0.8) {
        progressLevel = 3;
    } else {
        progressLevel = 4;
    }
    
    NSString *verboseText = [self.verboseTextArray objectAtIndex:progressLevel];
    
    self.verboseLabel.text = verboseText;
}

@end
