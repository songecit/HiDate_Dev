//
//  HDBaseDataControllerIndicator.h
//  HiParty
//
//  Created by 林祖涵 on 15/11/7.
//  Copyright © 2015年 830clock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HDBaseDataControllerIndicator <NSObject>

- (void)baseDataControllerShowIndicatorView;

- (void)baseDataControllerHideIndicatorView;

- (void)baseDataControllerShowTipsWithError:(NSError *)error;

@end
