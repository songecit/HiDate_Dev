//
//  HDUploadVideoProgressView.m
//  HiDate
//
//  Created by qidangsong on 16/11/8.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDUploadVideoProgressView.h"

@interface HDUploadVideoProgressView ()

@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *uploadProgressValueLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)clickCancleButton:(UIButton *)sender;

@end

@implementation HDUploadVideoProgressView

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
}


- (void)setUploadProgressValue:(CGFloat)uploadProgressValue
{
    _uploadProgressValue = uploadProgressValue;
    [self.uploadProgressView setProgress:uploadProgressValue animated:YES];
    NSString *tmpChar = @"%";
    self.uploadProgressValueLabel.text = [NSString stringWithFormat:@"%d%@", (int)(uploadProgressValue * 100), tmpChar];
}

- (IBAction)clickCancleButton:(UIButton *)sender
{
    if (self.cancelUploadOprete) {
        self.cancelUploadOprete();
    }
    [self removeFromSuperview];
}

@end
