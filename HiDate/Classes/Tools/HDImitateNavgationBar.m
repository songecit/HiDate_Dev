//
//  HDImitateNavgationBar.m
//  HiDate
//
//  Created by qidangsong on 16/9/23.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDImitateNavgationBar.h"


@interface HDImitateNavgationBar ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIButton *backButton;

@end


@implementation HDImitateNavgationBar

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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 32, HD_SCREEN_WIDTH - 80, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18.0f];
    [self addSubview:label];
    self.titleLabel = label;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 27, 100, 30);
    [btn setTitle:@"              " forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"back_pressed"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

- (void)updateTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (IBAction)clickBackButton:(id)sender
{
    if (self.clickBackButtonBlock) {
        self.clickBackButtonBlock();
    }
}

@end
