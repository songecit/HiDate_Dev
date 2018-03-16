//
//  HDBaseDataControllerUserCodeAction.h
//  HiParty
//
//  Created by 林祖涵 on 15/11/17.
//  Copyright © 2015年 830clock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HDBaseDataControllerUserCodeAction <NSObject>

@optional
- (void)baseDataControllerUserLoginOtherDevice;

- (void)baseDataControllerVersionUpdate;

@end
