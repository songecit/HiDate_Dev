//
//  HDBaseDataController.m
//  HiParty
//
//  Created by lzh on 15/10/19.
//  Copyright © 2015年 lzh. All rights reserved.
//

#import "HDBaseDataController.h"
#import "AFHTTPRequestOperation.h"
#import "OpenUDID.h"
#import "HDBaseDataControllerIndicator.h"
#import "HDBaseDataControllerUserCodeAction.h"
#import "HiDate-Swift.h"

static NSMutableDictionary *sharedInstances = nil;

NSString *const DataControllerErrorDomain = @"HDBaseDataControllerErrorDomain";

@interface HDBaseDataController ()

@property (nonatomic, weak) id<HDBaseDataControllerIndicator> tipsHostViewController;
@property (nonatomic, assign) BOOL isShowDefaultIndicatorView;

@property (nonatomic, strong) AFHTTPRequestOperation *httpOperation;
@property (nonatomic, strong) NSDictionary *requestArgs;
@property (nonatomic, strong) NSString *responseString;
@property (nonatomic, strong) NSDictionary *responseDic;

@property (nonatomic, strong) void (^selfRetainBlock)(void);

@property (nonatomic, strong) void (^successBlock)(HDBaseDataController *);
@property (nonatomic, strong) void (^failureBlock)(HDBaseDataController *, NSError *);

- (void)requestWithPath:(NSString *)path
                    Method:(HDBaseRequestMethod)requestMethod
    tipsHostViewController:(id<HDBaseDataControllerIndicator>)hostViewController
isShowLoadingIndicatorView:(BOOL)isShow
                 arguments:(NSDictionary *)args
              successBlock:(void (^)(HDBaseDataController *dataController))successBlock
              failureBlock:(void (^)(HDBaseDataController *dataController, NSError *error)) failureBlock;

- (void)requestWithPath:(NSString *)path
                 Method:(HDBaseRequestMethod)requestMethod
              arguments:(NSDictionary *)args
           successBlock:(void (^)(HDBaseDataController *dataController))successBlock
           failureBlock:(void (^)(HDBaseDataController *dataController, NSError *error)) failureBlock;

- (NSURL *)makeURLWithArgs:(NSDictionary *)args
               requestPath:(NSString *)requestPath;

- (void)requestWithAFNetworking:(NSURLRequest *)request;

- (void)getResponseInfoWithAFNetworking:(AFHTTPRequestOperation *)operation;
- (void)requestFinishedWithAFNetworking:(AFHTTPRequestOperation *)operation;
- (void)requestFailedWithAFNetworking:(AFHTTPRequestOperation *)operation;

- (void)requestCancelWithAFNetworking;

@end

@implementation HDBaseDataController

+ (instancetype)sharedDataController
{
    HDBaseDataController *aController;
    
    @synchronized(self)
    {
        if (sharedInstances == nil) {
            sharedInstances = [[NSMutableDictionary alloc] init];
        }
        
        NSString *keyName = NSStringFromClass([self class]);
        
        aController = [sharedInstances objectForKey:keyName];
        
        if (aController == nil) {
            aController = [[self alloc] init];
            
            [sharedInstances setObject:aController
                                forKey:keyName];
        }
    }
    
    return aController;
}

+ (id<HDBaseDataControllerUserCodeAction>)appDelegate
{
    return (id<HDBaseDataControllerUserCodeAction>)[UIApplication sharedApplication].delegate;
}

- (void)dealloc
{
    HDLog(@"%@ has dealloc",NSStringFromClass(self.class));
    
    _requestArgs = nil;
    
    if (self.httpOperation != nil) {
        [self.httpOperation cancel];
        self.httpOperation = nil;
    }
}

- (NSURL *)makeURLWithArgs:(NSDictionary *)args
               requestPath:(NSString *)requestPath
{
    NSDictionary *newArgument = nil;
    
    id commonArgument = [HDBaseDataController createCommonArgument];
    if (commonArgument == nil) {
        newArgument = args;
    } else if ([commonArgument isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *newCommonArgument = [NSMutableDictionary dictionaryWithDictionary:commonArgument];
        [newCommonArgument addEntriesFromDictionary:args];  // args里面的Key会覆盖默认的key
        newArgument = newCommonArgument;
    } else {
        newArgument = args;
        NSAssert(NO, @"方法:createCommonArgument 返回参数类型务必类型是:NSMutableDictionary");
    }
    
    NSMutableString *formatString = nil;
    
    for (NSString *key in newArgument) {
        if (formatString == nil) {
            formatString = [NSMutableString stringWithFormat:@"%@=%@", key, [newArgument valueForKey:key]];
        } else {
            [formatString appendFormat:@"&%@=%@", key, [newArgument valueForKey:key]];
        }
    }
    
    if (formatString) {
        if ([requestPath rangeOfString:@"?"].location == NSNotFound) {
            self.aURLString = [NSString stringWithFormat:@"%@?%@", requestPath, formatString];
        } else {
            self.aURLString = [NSString stringWithFormat:@"%@&%@", requestPath, formatString];
        }
    } else {
        self.aURLString = requestPath;
    }
    
    return [NSURL URLWithString:self.aURLString];
}

- (NSString *)postBodyStringWithArgs:(NSDictionary *)args
{
    NSDictionary *commonArgument = [HDBaseDataController createCommonArgument];
    
    NSMutableDictionary *commonArgDic = [NSMutableDictionary dictionaryWithDictionary:commonArgument];
    
    [commonArgDic addEntriesFromDictionary:args];
    
    return [self jsonStringFromDictionary:commonArgDic];
}

- (NSString *)jsonStringFromDictionary:(NSDictionary *)dic
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        HDLog(@"json Serialization error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

+ (NSMutableDictionary *)createCommonArgument
{
    NSMutableDictionary *newArgument = [NSMutableDictionary dictionaryWithDictionary:@{@"channel":@"IOS", @"version":[HDVersionTool getCurrentBundleShortVersion]}];

    // accessToken由H5注入，故不放入基本入参
//    NSString *accessToken = [HDLocalService getAccessToken];
//    
//    // 若用户已登录，accessToken作为通用参数
//    if (accessToken.length > 0) {
//        [newArgument setObject:accessToken forKey:@"accessToken"];
//    }
    
    return newArgument;
}

+ (HDBaseDataController *)requestWithPath:(NSString *)path
                                   Method:(HDBaseRequestMethod)requestMethod
                   tipsHostViewController:(id<HDBaseDataControllerIndicator>)hostViewController
               isShowLoadingIndicatorView:(BOOL)isShow
                                arguments:(NSDictionary *)args
                             successBlock:(void (^)(HDBaseDataController *dataController))successBlock
                             failureBlock:(void (^)(HDBaseDataController *dataController, NSError *error)) failureBlock
{
    HDBaseDataController *dataController = [[HDBaseDataController alloc] init];

    [dataController requestWithPath:[NSString stringWithFormat:@"%@%@",[dataController basePath],path]
                             Method:requestMethod
             tipsHostViewController:hostViewController
         isShowLoadingIndicatorView:isShow
                          arguments:args
                       successBlock:successBlock
                       failureBlock:failureBlock];
    
    return dataController;
}

+ (HDBaseDataController *)requestWithPath:(NSString *)path
                                   Method:(HDBaseRequestMethod)requestMethod
                                arguments:(NSDictionary *)args
                             successBlock:(void (^)(HDBaseDataController *dataController))successBlock
                             failureBlock:(void (^)(HDBaseDataController *dataController, NSError *error)) failureBlock
{
   return [self requestWithPath:path
                         Method:requestMethod
         tipsHostViewController:nil
     isShowLoadingIndicatorView:NO
                      arguments:args
                   successBlock:successBlock
                   failureBlock:failureBlock];
}

- (void)requestWithPath:(NSString *)path
                 Method:(HDBaseRequestMethod)requestMethod
              arguments:(NSDictionary *)args
           successBlock:(void (^)(HDBaseDataController *dataController))successBlock
           failureBlock:(void (^)(HDBaseDataController *dataController, NSError *error)) failureBlock
{
    [self  requestWithPath:path
                    Method:requestMethod
    tipsHostViewController:nil
isShowLoadingIndicatorView:NO
                 arguments:args
              successBlock:successBlock
              failureBlock:failureBlock];
}

- (void)requestWithPath:(NSString *)path
                    Method:(HDBaseRequestMethod)requestMethod
    tipsHostViewController:(id<HDBaseDataControllerIndicator>)hostViewController
isShowLoadingIndicatorView:(BOOL)isShow
                 arguments:(NSDictionary *)args
              successBlock:(void (^)(HDBaseDataController *dataController))successBlock
              failureBlock:(void (^)(HDBaseDataController *dataController, NSError *error)) failureBlock
{
    self.tipsHostViewController = hostViewController;
    self.isShowDefaultIndicatorView = isShow;
    
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    
    NSMutableDictionary *commoArgument = [HDBaseDataController createCommonArgument];
    [commoArgument addEntriesFromDictionary:args];
    self.requestArgs = [NSDictionary dictionaryWithDictionary:commoArgument];
    
    // 取消当前的请求
    [self requestCancel];
    
    NSMutableURLRequest *urlRequest = nil;
    
    NSString *method = requestMethod == HDBaseRequestMethodPost ? @"POST" : @"GET";
    
    if ([method isEqualToString:@"GET"]) {
        urlRequest = [NSMutableURLRequest requestWithURL:[self makeURLWithArgs:args requestPath:path]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:[self requestTimeout]];
        [urlRequest setHTTPMethod:@"GET"];
    } else if ([method isEqualToString:@"POST"]) {
        urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:[self requestTimeout]];
        
        [urlRequest setHTTPMethod:@"POST"];
        
        [urlRequest setHTTPBody:[[self postBodyStringWithArgs:args] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //设置Http header
    if (self.requestHTTPHeaderField && self.requestHTTPHeaderField.count > 0) {
        [self.requestHTTPHeaderField enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
            [urlRequest addValue:value
              forHTTPHeaderField:key];
        }];
    }
    
    HDLog(@"AFNetworking Request \n URL: %@ \n Method: %@ \n Args: \n%@ \n",urlRequest.URL,method,self.requestArgs);
    
    [self requestWithAFNetworking:urlRequest];
}

- (void)requestWithAFNetworking:(NSURLRequest *)request
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    // 通过自引用，使datacontroller在请求时不被释放。
    self.selfRetainBlock = ^ {
        [self description];
    };
#pragma clang diagnostic pop
    
    HDLog(@"AFNetworking Request: %@", request.URL);
        
    [self willStartRequest:request];
    
    AFHTTPRequestOperation *newHttpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.httpOperation = newHttpOperation;
    newHttpOperation = nil;
    
    __weak HDBaseDataController *weakSelf = self;
    [self.httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf hideIndicatorView];
        [weakSelf requestFinishedWithAFNetworking:operation];
        
        weakSelf.selfRetainBlock = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf hideIndicatorView];
        [weakSelf requestFailedWithAFNetworking:operation];
        
        weakSelf.selfRetainBlock = nil;
    }];
    
    [self showIndicatorView];
    
    [self.httpOperation start];
}

- (void)willStartRequest:(NSURLRequest *)request
{
    // 空实现
}

- (void)requestCancel
{
    [self requestCancelWithAFNetworking];
}

- (void)requestCancelWithAFNetworking
{
    if (self.httpOperation != nil) {
        [self.httpOperation cancel];
        self.httpOperation = nil;
    }
}

#pragma mark - AFNetworking Method
- (void)getResponseInfoWithAFNetworking:(AFHTTPRequestOperation *)operation
{

}

- (void)requestFinishedWithAFNetworking:(AFHTTPRequestOperation *)operation
{
    HDLog(@"AFNetworking operation successed");
    
    [self getResponseInfoWithAFNetworking:operation];
    
    NSInteger statusCode = operation.response.statusCode;
    
    if (200 == statusCode) {
        self.responseString = [operation responseString];
        
        if (self.responseString) {
            NSError *error;
            NSData *data = [self.responseString dataUsingEncoding:NSUTF8StringEncoding];
            self.responseDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            HDLog(@"AFNetworking Response \n%@",self.responseDic);
            
            NSDictionary *headerDic = [self.responseDic objectForKey:@"header"];
            
            if(error != nil || headerDic == nil){
                [self operationErrorAndShow:[self requestErrorWithCode:HDBaseRequestErrorCodeParseFail]];
                return;
            }
            
            NSString *code = [headerDic objectForKey:@"code"];
            if ([code isEqualToString:@"0000"]) {
                if (self.successBlock) {
                    self.successBlock(self);
                }
            } else {
                if ([code isEqualToString:@"6002"]) {
                    id<HDBaseDataControllerUserCodeAction> delegate = [HDBaseDataController appDelegate];
                    if ([delegate respondsToSelector:@selector(baseDataControllerUserLoginOtherDevice)]) {
                        [delegate baseDataControllerUserLoginOtherDevice];
                    }
                } else if ([code isEqualToString:@"0009"]) {
                    id<HDBaseDataControllerUserCodeAction> delegate = [HDBaseDataController appDelegate];
                    if ([delegate respondsToSelector:@selector(baseDataControllerVersionUpdate)]) {
                        [delegate baseDataControllerVersionUpdate];
                    }
                }
                
                NSString *errorMessage = [headerDic objectForKey:@"msg"];
                
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey:errorMessage?errorMessage:@""
                                           };
                
                NSError *error = [NSError errorWithDomain:DataControllerErrorDomain
                                                     code:[code integerValue]
                                                 userInfo:userInfo];
                
                [self showTipsWithError:error];
                
                if (self.failureBlock) {
                    self.failureBlock(self, error);
                }
                
                HDLog(@"request error URL: %@  responseDic: %@",operation.request.URL,self.responseDic);
            }
            
            self.successBlock = nil;
            self.failureBlock = nil;
        } else {
            
            [self operationErrorAndShow:[self requestErrorWithCode:HDBaseRequestErrorCodeEmptyData]];
            
            HDLog(@"request error URL: %@  responseDic: %@",operation.request.URL,self.responseDic);
        }
    } else {
        [self operationErrorAndShow:operation.error];
        
        HDLog(@"request error URL: %@  responseDic: %@",operation.request.URL,self.responseDic);
    }
}

- (void)operationErrorAndShow:(NSError *)error
{
    [self showTipsWithError:error];
    
    if (self.failureBlock) {
        self.failureBlock(self, error);
    }
    
    self.successBlock = nil;
    self.failureBlock = nil;
    
    self.httpOperation = nil;
}

- (NSError *)requestErrorWithCode:(HDBaseRequestErrorCode)code
{
    NSString *errorMessage = nil;
    
    switch (code) {
        case HDBaseRequestErrorCodeEmptyData:
        case HDBaseRequestErrorCodeParseFail:
        case HDBaseRequestErrorCodeNetLinkFail:
            errorMessage = @"网络异常，请稍后再试";
            break;
            
        default:
            errorMessage = @"";
            break;
    }
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey:errorMessage
                              };
    NSError *error = [NSError errorWithDomain:DataControllerErrorDomain
                                         code:code
                                     userInfo:userInfo];
    return error;
}

- (void)requestFailedWithAFNetworking:(AFHTTPRequestOperation *)operation
{
    HDLog(@"AFNetworking Request failed  URL: %@ \n Error code: %zd \n Description: %@", operation.request.URL, [operation.error code], [operation.error localizedDescription]);

    [self getResponseInfoWithAFNetworking:operation];
    
    NSError *error = [self requestErrorWithCode:HDBaseRequestErrorCodeNetLinkFail];
    
    [self operationErrorAndShow:error];
}

#pragma mark - showIndicator & tips

- (void)showIndicatorView
{
    if ([self.tipsHostViewController respondsToSelector:@selector(baseDataControllerShowIndicatorView)]
        && self.isShowDefaultIndicatorView) {
        [self.tipsHostViewController baseDataControllerShowIndicatorView];
    }
}

- (void)hideIndicatorView
{
    if ([self.tipsHostViewController respondsToSelector:@selector(baseDataControllerHideIndicatorView)]
        && self.isShowDefaultIndicatorView) {
        [self.tipsHostViewController baseDataControllerHideIndicatorView];
    }
}

- (void)showTipsWithError:(NSError *)error
{
    if ([self.tipsHostViewController respondsToSelector:@selector(baseDataControllerShowTipsWithError:)]) {
        [self.tipsHostViewController baseDataControllerShowTipsWithError:error];
    }
}

#pragma mark - Class Method

- (NSString *)basePath
{
    return BASE_PATH;
}

- (NSInteger)requestTimeout
{
    return 15;
}

- (NSDictionary *)requestHTTPHeaderField
{
    
    return @{
             @"charset":@"utf-8",
             @"Content-Type":@"application/json"
            };
}

#pragma mark - Helper

- (NSDate *)dateFromDayString:(NSString *)dayString
{
    static NSDateFormatter *formatter = nil;
    
    if (!formatter) {
        @synchronized(self) {
            formatter = [[NSDateFormatter alloc] init];
            [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
            [formatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss z"];
        }
    }
    
    return [formatter dateFromString:dayString];
}


@end
