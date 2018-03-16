//
//  HDTxtMessage.m
//  HiDate
//
//  Created by qidangsong on 16/11/2.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDTxtMessage.h"

#import <RongIMLib/RCUtilities.h>
//#import <RongIMLib/RCJSONConverter.h>

@implementation HDTxtMessage

+(instancetype)messageWithContent:(NSString *)content {
    HDTxtMessage *msg = [[HDTxtMessage alloc] init];
    if (msg) {
        msg.content = content;
    }
    
    return msg;
}

+(RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

#pragma mark – NSCoding protocol methods
#define KEY_VCMSG_CONTENT @"content"
#define KEY_VCMSG_EXTRA @"extra"

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        
        self.content = [aDecoder decodeObjectForKey:KEY_VCMSG_CONTENT];
        self.extra = [aDecoder decodeObjectForKey:KEY_VCMSG_EXTRA];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.content forKey:KEY_VCMSG_CONTENT];
    [aCoder encodeObject:self.extra forKey:KEY_VCMSG_EXTRA];
}

#pragma mark – RCMessageCoding delegate methods

-(NSData *)encode {
    
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    [dataDict setObject:self.content forKey:KEY_VCMSG_CONTENT];
    if (self.extra) {
        [dataDict setObject:self.extra forKey:KEY_VCMSG_EXTRA];
    }

    if (self.senderUserInfo) {
        NSMutableDictionary *__dic=[[NSMutableDictionary alloc]init];
        if (self.senderUserInfo.name) {
            [__dic setObject:self.senderUserInfo.name forKeyedSubscript:@"name"];
        }
        if (self.senderUserInfo.portraitUri) {
            [__dic setObject:self.senderUserInfo.portraitUri forKeyedSubscript:@"icon"];
        }
        if (self.senderUserInfo.userId) {
            [__dic setObject:self.senderUserInfo.userId forKeyedSubscript:@"id"];
        }
        [dataDict setObject:__dic forKey:@"user"];
    }
    
    //NSDictionary* dataDict = [NSDictionary dictionaryWithObjectsAndKeys:self.content, @"content", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                   options:kNilOptions
                                                     error:nil];
    return data;
}

-(void)decodeWithData:(NSData *)data {
#if 1
    __autoreleasing NSError* __error = nil;
    if (!data) {
        return;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&__error];
#else
    //    NSString *jsonStream = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    NSDictionary *json = [RCJSONConverter dictionaryWithJSONString:jsonStream];
#endif
    if (json) {
        self.content = json[KEY_VCMSG_CONTENT];
        self.extra = json[KEY_VCMSG_EXTRA];
        NSObject *__object = [json objectForKey:@"user"];
        NSDictionary *userinfoDic = nil;
        if (__object &&[__object isMemberOfClass:[NSDictionary class]]) {
            userinfoDic =(NSDictionary *)__object;
        }
        if (userinfoDic) {
            RCUserInfo *userinfo =[RCUserInfo new];
            userinfo.userId = [userinfoDic objectForKey:@"id"];
            userinfo.name =[userinfoDic objectForKey:@"name"];
            userinfo.portraitUri =[userinfoDic objectForKey:@"icon"];
            self.senderUserInfo = userinfo;
        }
        
    }
}
- (NSString *)conversationDigest
{
    return @"HdTxtMsg";
}

+(NSString *)getObjectName {
    return HDTxtMessageTypeIdentifier;
}
#if ! __has_feature(objc_arc)
-(void)dealloc
{
    [super dealloc];
}
#endif//__has_feature(objc_arc)


@end
