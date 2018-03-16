//
//  HDShareContentHandle.h
//  HiParty
//
//  Created by HiDate on 16/3/11.
//  Copyright © 2016年 830clock. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HDShareContentHandleType) {
    HDShareContentHandleTypeSinaWeiBo,
    HDShareContentHandleTypeWeChat,
    HDShareContentHandleTypePengYouQuan,
    HDShareContentHandleTypeQQ
};

@interface HDShareContentHandle : NSObject

+ (void)shareContentWithData:(NSDictionary *)shareData
               withShareType:(HDShareContentHandleType)shareType
           withCompleteBlock:(void(^)(BOOL))completeBlock;

@end
