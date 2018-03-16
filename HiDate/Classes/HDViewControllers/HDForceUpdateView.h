//
//  HDForceUpdateView.h
//  HiDate
//
//  Created by qidangsong on 16/7/27.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDForceUpdateView : UIView

- (void)Initialization;

- (void)setUpdateVersion:(NSString *)version andContent:(NSString *)content andDownloadUrl:(NSString *)downloadUrl;

@end
