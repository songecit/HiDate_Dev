//
//  HDReceivedRedPaperView.m
//  HiDate
//
//  Created by qidangsong on 16/9/21.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDReceivedRedPaperView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HDReceivedRedPaperView ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordLinkButton;

- (IBAction)clickCloseButton:(UIButton *)sender;
- (IBAction)clickRecordLinkButton:(UIButton *)sender;

@end

@implementation HDReceivedRedPaperView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self Initialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self Initialization];
    }
    return self;
}

- (void)Initialization
{
    self.frame = CGRectMake(0, 0, HD_SCREEN_WIDTH, HD_SCREEN_HEIGHT);
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2.0f;
}

- (void)updateAvatar:(NSString *)imageUrl andNickName:(NSString *)name andAmount:(NSInteger)amount
{
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                            placeholderImage:[UIImage imageNamed:@"morentouxiang"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

                                   }];

    self.avatarImageView.image = [UIImage imageWithData:imageData];
    self.nickNameLabel.text = [NSString stringWithFormat:@"%@的红包奖励", name];
    
    
    NSString *str = [NSString stringWithFormat:@"%.2f元", amount / 100.0f];
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
    if (self.clickBackButtonBlock) {
        self.clickBackButtonBlock();
    }
}

- (IBAction)clickRecordLinkButton:(UIButton *)sender
{
    if (self.jumpToRecordLinkBlock) {
        self.jumpToRecordLinkBlock();
    }
}

@end
