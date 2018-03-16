//
//  ZHRotationProgressView.m
//  GradientLayer
//
//  Created by HiDate on 16/3/28.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "ZHRotationProgressView.h"

#define kProgressWidth 2.0f
#define kMainColor(A) [UIColor colorWithRed:38/255.0 green:236/255.0 blue:171/255.0 alpha:A]

@interface ZHRotationProgressView ()

@property (strong, nonatomic) UILabel *progressLabel;

@property (strong, nonatomic) CABasicAnimation *rotationAnimation;

@property (strong, nonatomic) CAShapeLayer *circularShapeLayer;
@property (strong, nonatomic) CALayer *gradientContentLayer;

@end

@implementation ZHRotationProgressView

- (CABasicAnimation *)rotationAnimation
{
    if (_rotationAnimation == nil) {
        _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        _rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        _rotationAnimation.fromValue = [NSNumber numberWithInt:0];
        _rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
        _rotationAnimation.duration = 2;
        _rotationAnimation.repeatCount = HUGE_VALF;
    }
    
    return _rotationAnimation;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initCustom];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCustom];
    }
    return self;
}

- (void)initCustom
{
    CGRect rect = self.frame;
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    //百分比
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,width - 10 * 2,30)];
    self.progressLabel.font = [UIFont systemFontOfSize:11.0f];
    self.progressLabel.textColor = kMainColor(1.0f);
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.center = CGPointMake(width/2, width/2);
    [self addSubview:self.progressLabel];
    
    //颜色渐变Layer
    self.gradientContentLayer = [CALayer layer];
    CAGradientLayer *gradientLayer1 =  [CAGradientLayer layer];
    gradientLayer1.frame = CGRectMake(0, 0, width/2, width);
    
    UIColor *color1 = kMainColor(1.0f);
    UIColor *color2 = kMainColor(0.5f);
    UIColor *color3 = kMainColor(0.0f);
    
    [gradientLayer1 setColors:[NSArray arrayWithObjects:(id)[color1 CGColor],(id)[color2 CGColor], nil]];

    [self.gradientContentLayer addSublayer:gradientLayer1];
    
    CAGradientLayer *gradientLayer2 =  [CAGradientLayer layer];
    gradientLayer2.frame = CGRectMake(width/2, 0, width/2, width);
    [gradientLayer2 setColors:[NSArray arrayWithObjects:(id)[color3 CGColor],[(id)color2 CGColor], nil]];
    [self.gradientContentLayer addSublayer:gradientLayer2];
    
    self.gradientContentLayer.frame = CGRectMake(0, 0, width, width);
    [self.layer addSublayer:self.gradientContentLayer];

    //圆形shapelayer
    self.circularShapeLayer = [CAShapeLayer layer];
    self.circularShapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.circularShapeLayer.fillMode = kCAFillRuleNonZero;
    self.circularShapeLayer.path = [self circularBezierPathWithRadius:width/2 - kProgressWidth / 2].CGPath;
    self.circularShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.circularShapeLayer.lineWidth = kProgressWidth;
    self.circularShapeLayer.lineJoin = kCALineJoinRound;
    self.circularShapeLayer.lineCap = kCALineCapRound;
    self.circularShapeLayer.frame = CGRectMake(kProgressWidth / 2, kProgressWidth / 2, width - kProgressWidth, width - kProgressWidth);
    
    //mask
    self.gradientContentLayer.mask = self.circularShapeLayer;
}

- (void)setIsShowProgressText:(BOOL)isShowProgressText
{
    _isShowProgressText = isShowProgressText;
    self.progressLabel.hidden = !isShowProgressText;
}

- (void)setProgress:(CGFloat)progress
{
    CGFloat pro = MIN(MAX(0, progress), 1);
    CGFloat tmpPro = pro * 100;
    
    self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",tmpPro];
}

- (void)startRound
{
    [self.gradientContentLayer addAnimation:self.rotationAnimation forKey:@"rotateAniamtion"];
}

- (void)stopRound
{
    [self.gradientContentLayer removeAnimationForKey:@"rotateAniamtion"];
}

- (UIBezierPath *)circularBezierPathWithRadius:(CGFloat)radius
{
    UIBezierPath *circularBezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                    radius:radius
                                                startAngle:3 * M_PI_2 + M_PI / 30.0
                                                  endAngle:3 * M_PI_2 - M_PI / 30.0
                                                 clockwise:YES];
    return circularBezierPath;
}

@end
