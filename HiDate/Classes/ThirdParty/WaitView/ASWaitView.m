//
//  ASWaitView.m
//
//
//  Created by Mark on 13-11-12.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "ASWaitView.h"
//#import "WpCommonFunction.h"

@interface ASWaitView ()
{
    CGFloat angle;
    BOOL bRotate;
    
//    UIImageView* cBkImageView;
//    UIImageView* cShieldImageView;
    UIImageView* cCircleImageView;
}

@end

@implementation ASWaitView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        
        CGFloat x1 = (screenWidth - 70.0) / 2.0;
        CGFloat y1 = (screenHeight - 70.0) / 2.0;
        UIView *bgview = [[UIView alloc] initWithFrame:CGRectMake(x1, y1, 70.0, 70.0)];
        bgview.backgroundColor = [UIColor blackColor];
        bgview.alpha = 0.8;
        CALayer* layer = bgview.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 10.0f;
        
        [self addSubview:bgview];
//
//        
//        CGFloat x2 = (screenWidth - 25.0) / 2.0;
//        CGFloat y2 = (screenHeight - 20.0) / 2.0;
//        cShieldImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x2, y2, 25.0, 20.0)];
//        cShieldImageView.image = [UIImage imageNamed:@"wait_logo"];
//        [self addSubview:cShieldImageView];
        
        CGFloat x3 = (screenWidth - 26.0) / 2.0;
        CGFloat y3 = (screenHeight - 26.0) / 2.0;
        cCircleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x3, y3, 26.0, 26.0)];
        cCircleImageView.image = [UIImage imageNamed:@"wait_loading"];
        [self addSubview:cCircleImageView];
        
        [self startAnimation];
    }
    return self;
}

- (void)startAnimation
{
    bRotate = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.02];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endAnimation)];
    cCircleImageView.transform = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    [UIView commitAnimations];
}

- (void)endAnimation
{
    angle += 10;
    
    if (bRotate)
    {
        [self startAnimation];
    }
}

- (void)closeView
{
    bRotate = NO;
}

@end
