//
//  HDReceivedRedPaperViewController.m
//  HiDate
//
//  Created by qidangsong on 16/9/23.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDReceivedRedPaperViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HDBaseWebViewController.h"
#include <QuartzCore/CoreAnimation.h>
#import "H5Update.h"

@interface HDReceivedRedPaperViewController ()

@property (weak, nonatomic) IBOutlet UIView *redPaperBgView;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomTipBgView;

- (IBAction)clickCloseButton:(UIButton *)sender;
- (IBAction)clickRecordLinkButton:(UIButton *)sender;

@end

@implementation HDReceivedRedPaperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:self.shotImage];
    
    NSString *avatar = [self.infoData[@"avatar"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *nickname = [self.infoData[@"nickName"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self updateAvatar:avatar andNickName:nickname andAmount:[self.infoData[@"amount"] integerValue]];
    
    NSString *redpaperType = [self.infoData[@"type"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([redpaperType isEqualToString:@"TASK"]) {
        // 任务红包，隐藏tipView
        self.bottomTipBgView.hidden = YES;
    }
   
    // 增加动画效果
    [self animateShakeToShow];
}

- (void)animateShakeToShow
{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
//    NSMutableArray *values = [NSMutableArray array];
////    for (int i = 30; i < 91; i ++) {
////        CGFloat radian = (CGFloat)i * M_PI / 180.0f;
////        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(sinf(radian), sinf(radian), 1.0)]];
////    }
//
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
//    animation.values = values;
    
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(HD_SCREEN_WIDTH / 4, HD_SCREEN_HEIGHT / 4, HD_SCREEN_WIDTH / 2, HD_SCREEN_HEIGHT / 2)];
//    animation.path = path.CGPath;
//    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25 :-0.5 :0.78 :1.45];
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;

    // animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25 :0.5 :0.78 :1.45];
    
    [self.redPaperBgView.layer addAnimation:animation forKey:nil];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (void)updateAvatar:(NSString *)imageUrl andNickName:(NSString *)name andAmount:(NSInteger)amount
{
//    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2.0f;
//    self.avatarImageView.layer.masksToBounds = YES;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                            placeholderImage:nil
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       // self.avatarImageView.image = image;
                                   }];
    self.nickNameLabel.text = [NSString stringWithFormat:@"%@的红包奖励", name];
    
    NSString *str = @"";
    if (amount % 100 == 0) {
        str = [NSString stringWithFormat:@"%ld元", amount / 100];
    } else if (amount % 10 == 0) {
        str = [NSString stringWithFormat:@"%.1f元", amount / 100.0f];
    } else {
        str = [NSString stringWithFormat:@"%.2f元", amount / 100.0f];
    }
    NSMutableAttributedString *amountStr = [[NSMutableAttributedString alloc] initWithString:str];
    // [amountStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,5)];
    [amountStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.0f] range:NSMakeRange(str.length - 1, 1)];
    self.amountLabel.attributedText = amountStr;
    
    
    // 创建一个富文本
    //    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:@"只限泡吧；每天只算完成第一笔泡吧订单"];
    //    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    //    attch.image = [UIImage imageNamed:@"hongbaoshuoming"];
    //    attch.bounds = CGRectMake(-4, 0, 15, 15);
    //    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    //    [attri insertAttributedString:string atIndex:0];
    //    self.tipLabel.attributedText = attri;
}

- (IBAction)clickCloseButton:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickRecordLinkButton:(UIButton *)sender
{
    NSString *recordlink = [self.infoData[@"recordLink"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *absoluteRecordLink = [[H5Update getNewH5AppSanboxPath] stringByAppendingPathComponent:recordlink];
    [HDBaseWebViewController openNewWebViewWithPage:absoluteRecordLink isCloseBefore:NO andController:self];
}


@end
