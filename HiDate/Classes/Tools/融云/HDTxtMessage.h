//
//  HDTxtMessage.h
//  HiDate
//
//  Created by qidangsong on 16/11/2.
//  Copyright © 2016年 HiDate. All rights reserved.
//


#import <RongIMLib/RongIMLib.h>
#import <RongIMLib/RCMessageContentView.h>


#define HDTxtMessageTypeIdentifier @"HdTxtMsg"

/**
 * HiDate自定义文本消息
 */

@interface HDTxtMessage : RCMessageContent <NSCoding, RCMessageContentView>

/** 文本消息内容 */
@property(nonatomic, strong) NSString* content;

/**
 * 附加信息
 */
@property(nonatomic, strong) NSString* extra;

/**
 * 根据参数创建文本消息对象
 * @param content 文本消息内容
 */
+(instancetype)messageWithContent:(NSString *)content;

@end
