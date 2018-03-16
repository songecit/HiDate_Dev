//
//  HDForceUpdateView.m
//  HiDate
//
//  Created by qidangsong on 16/7/27.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDForceUpdateView.h"
#import "HiDate-Swift.h"

@interface HDForceUpdateView ()

@property (strong, nonatomic) NSString *downloadUrl;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *currentVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
- (IBAction)clickUpdateButton:(UIButton *)sender;

@end

@implementation HDForceUpdateView

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
        // [self Initialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // [self Initialization];
    }
    return self;
}

- (void)Initialization
{
    self.frame = CGRectMake(0, 0, HD_SCREEN_WIDTH, HD_SCREEN_HEIGHT);
    
    self.mainView.layer.cornerRadius = 8;
    self.mainView.layer.masksToBounds = YES;
    
    // 设置圆角 4
    self.updateButton.layer.cornerRadius = 3;
    self.updateButton.layer.masksToBounds = YES;

    [self.updateButton setBackgroundImage:[CommonUtils createImageWithColor:HDColor_C1995C] forState:UIControlStateNormal];
}

- (void)setUpdateVersion:(NSString *)version andContent:(NSString *)content andDownloadUrl:(NSString *)downloadUrl
{
    self.currentVersionLabel.text = [HDVersionTool getCurrentBundleShortVersion];
    self.updateVersionLabel.text = version;
    self.updateContentLabel.text = content;
    self.downloadUrl = downloadUrl;
}

- (IBAction)clickUpdateButton:(UIButton *)sender
{
    // 去升级
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.downloadUrl]];
    // 升级时退出APP
    abort();
}
@end
