//
//  H5AppLauncher.m
//  H5Launcher
//
//  Created by HiDate on 16/1/8.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "H5AppLauncher.h"

#import "HDSystemConfigModel.h"
#import "HDBaseDataControllerUserCodeAction.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

#import <AliyunOSSiOS/OSSUtil.h>

#import "UUIDTool.h"
#import "FileManagerTool.h"
#import "ZipArchiveTool.h"
#import "FileDownloadTool.h"

#import "HiDate-Swift.h"

#if WHETHER_USER_WKWEBVIEW == 1
#import "WKWebViewJavascriptBridge.h"
@interface H5AppLauncher ()
@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
#else
#import "WebViewJavascriptBridge.h"
@interface H5AppLauncher ()
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;
#endif

@property (nonatomic, copy) void (^backBtnHandler) (void);
@property (nonatomic, copy) void (^onResumeHandler) (void);
@property (nonatomic, copy) void (^onPushMsgHandler) (NSArray *pushMsgList);
@property (nonatomic, copy) void (^onJumpHandler) (NSString *type);
@property (nonatomic, copy) void (^onRightBtnCallbackHandler) (NSInteger tag);

@end

@implementation H5AppLauncher

- (void)dealloc
{
    NSLog(@"H5AppLauncher has dealloc");
}



#if WHETHER_USER_WKWEBVIEW == 1
- (void)launchLocalH5AppWithWebView:(WKWebView *)webView
          webViewHostViewController:(id<H5AppLauncherJSAction>)hostViewController
                          localPath:(NSString *)localpath
                      localBasePath:(NSString *)localbasepath
                    webViewDelegate:(NSObject<WKNavigationDelegate>*)webViewDelegate
{
    if (localpath && localpath.length > 0) {
        [self initBridgeWithWebView:webView
          webViewHostViewController:hostViewController
                    webViewDelegate:webViewDelegate];
        
        NSURL *demoURL;
        if ([localpath hasPrefix:@"file:///"]) {
            demoURL = [NSURL URLWithString:localpath];
        } else {
            demoURL = [NSURL fileURLWithPath:localpath];
        }
        
        NSURL *baseURL;
        if ([localbasepath hasPrefix:@"file:///"]) {
            baseURL = [NSURL URLWithString:localbasepath];
        } else {
            baseURL = [NSURL fileURLWithPath:localbasepath];
        }
        
        // iOS8.0和iOS9.0及以上加载本地Html的方法不一样
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.49) {
            [webView loadFileURL:demoURL allowingReadAccessToURL:baseURL];
        } else {
            NSURLRequest *request = [NSURLRequest requestWithURL:demoURL];
            [webView loadRequest:request];
        }
    }
}

- (void)launchOnlineH5AppWithWebView:(WKWebView *)webView
           webViewHostViewController:(id<H5AppLauncherJSAction>)hostViewController
                          requestUrl:(NSString *)requestUrl
                     webViewDelegate:(NSObject<WKNavigationDelegate>*)webViewDelegate
{
    if (requestUrl && requestUrl.length > 0) {
        [self initBridgeWithWebView:webView
          webViewHostViewController:hostViewController
                    webViewDelegate:webViewDelegate];
        
        NSURL *url = [NSURL URLWithString:requestUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    }
}

#else
- (void)launchLocalH5AppWithWebView:(UIWebView *)webView
          webViewHostViewController:(id<H5AppLauncherJSAction>)hostViewController
                          localPath:(NSString *)localpath
                    webViewDelegate:(id<UIWebViewDelegate>)delegate
{
    if (localpath && localpath.length > 0) {
        [self initBridgeWithWebView:webView
          webViewHostViewController:hostViewController
                    webViewDelegate:delegate];
        
        NSURL *demoURL = [NSURL fileURLWithPath:localpath];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:demoURL];
        // [NSURLRequest requestWithURL:demoURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
        // [self clearWebViewCache];
        
        [webView loadRequest:request];
    }
}

- (void)launchOnlineH5AppWithWebView:(UIWebView *)webView
           webViewHostViewController:(id<H5AppLauncherJSAction>)hostViewController
                          requestUrl:(NSString *)requestUrl
                     webViewDelegate:(id<UIWebViewDelegate>)delegate
{
    if (requestUrl && requestUrl.length > 0) {
        [self initBridgeWithWebView:webView
          webViewHostViewController:hostViewController
                    webViewDelegate:delegate];
        
        NSURL *url = [NSURL URLWithString:requestUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    }
}

#endif

+ (NSString *)jsonWithObject:(id)object
{
    if (!object) {
        return nil;
    }
    
    NSString *jsonString = nil;
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return jsonString;
}

#if WHETHER_USER_WKWEBVIEW == 1
- (void)initBridgeWithWebView:(WKWebView *)webView
    webViewHostViewController:(id<H5AppLauncherJSAction>)hostViewController
              webViewDelegate:(NSObject<WKNavigationDelegate>*)webViewDelegate

{
    self.bridge= [WKWebViewJavascriptBridge bridgeForWebView:webView];
    [self.bridge setWebViewDelegate:webViewDelegate];
#else
    - (void)initBridgeWithWebView:(UIWebView *)webView
webViewHostViewController:(id<H5AppLauncherJSAction>)hostViewController
webViewDelegate:(id<UIWebViewDelegate>)delegate
    {
        self.bridge= [WebViewJavascriptBridge bridgeForWebView:webView];
        [self.bridge setWebViewDelegate:delegate];
#endif
        
        // self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:webViewDelegate handler:^(id data, WVJBResponseCallback responseCallback) { }];
        
        
        __weak typeof(id<H5AppLauncherJSAction>) weakHostViewController = hostViewController;
        __weak typeof(self) weakSelf = self;
        self.backBtnHandler = ^(void){
            [weakSelf.bridge callHandler:@"back_btn_handler"];
        };
        
        self.onResumeHandler = ^(void){
            id extra = [HDSystemConfigModel shareModel].extraData;
            NSDictionary *extraData = [CommonUtils checkDictionary:extra];
            if (extraData) {
                NSString *jsonString = [H5AppLauncher jsonWithObject:extraData];
                [weakSelf.bridge callHandler:@"onResumeHandler" data:jsonString];
                [HDSystemConfigModel shareModel].extraData = nil;
            } else {
                [weakSelf.bridge callHandler:@"onResumeHandler"];
            }
        };
        
        // OnPushMsgHandler 推送消息的handler
        self.onPushMsgHandler = ^(NSArray *pushMsgList) {
            NSString *jsonString = [H5AppLauncher jsonWithObject:pushMsgList];
            [weakSelf.bridge callHandler:@"onPushMsgHandler" data:jsonString];
        };
        
        // 收到APNS的跳转
        self.onJumpHandler = ^(NSString *type) {
            NSString *jsonString = [H5AppLauncher jsonWithObject:@{@"type":type}];
            [weakSelf.bridge callHandler:@"onJumpHandler" data:jsonString];
        };
        
        self.onRightBtnCallbackHandler = ^(NSInteger tag) {
            NSString *jsonString = [H5AppLauncher jsonWithObject:@{@"id":[NSNumber numberWithInteger:tag]}];
            [weakSelf.bridge callHandler:@"onRightBtnCallbackHandler" data:jsonString];
        };
        
        [self.bridge registerHandler:@"SET_TITLE" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataDic = (NSDictionary *)data;
            NSString *title = [dataDic objectForKey:@"title"];
            NSString *isHideBar = [dataDic objectForKey:@"isHideBar"];
            
            if (weakHostViewController && [weakHostViewController respondsToSelector:@selector(jsActionSetTitleBarWithTitle:andIsHideBar:)]) {
                [weakHostViewController jsActionSetTitleBarWithTitle:title andIsHideBar:isHideBar];
            }
            // NSLog(@"js send argument SET_TITLE %@",data);
        }];
        
        [self.bridge registerHandler:@"CLOSE_PAGE" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            if (weakHostViewController && [weakHostViewController respondsToSelector:@selector(jsActionClosePageWithPageFrom:andExtra:)]) {
                [weakHostViewController jsActionClosePageWithPageFrom:nil andExtra:data];
            }
            
            // NSLog(@"js send argument CLOSE_PAGE %@",data);
        }];
        
        [self.bridge registerHandler:@"OPEN_PAGE" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataDic = (NSDictionary *)data;
            NSString *pageTo = [dataDic objectForKey:@"pageTo"];
            BOOL isCloseBefore = [[dataDic objectForKey:@"isCloseBefore"] boolValue];
            if (weakHostViewController && [weakHostViewController respondsToSelector:@selector(jsActionOpenPageWithPage:isCloseBefore:)]) {
                [weakHostViewController jsActionOpenPageWithPage:pageTo isCloseBefore:isCloseBefore];
            }
        }];
        
        [self.bridge registerHandler:@"UPLOAD_VIDEO" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataDic = (NSDictionary *)data;
            // {type:type,accessToken:accessToken,userId:4}
            if (weakHostViewController && [weakHostViewController respondsToSelector:@selector(jsActionUploadVideoWithExtra:andCallBack:)]) {
                [weakHostViewController jsActionUploadVideoWithExtra:dataDic andCallBack:^(NSDictionary *videoInfo) {
                    
                    if (responseCallback) {
                        NSString *jsonString = [H5AppLauncher jsonWithObject:videoInfo];
                        responseCallback(jsonString);
                    }
                }];
            }
            // NSLog(@"js send argument GET_PICTURES %@",data);
        }];
        
        // 链接融云 RONG_ACCESS
        [self.bridge registerHandler:@"LOGIN_INFO" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataDic = [CommonUtils checkDictionary:data];
            if (dataDic) {
                NSString *accessToken = [dataDic objectForKey:@"accessToken"];
                if (accessToken && accessToken.length > 0) {
                    // 申请融云token（申请成功融云自动连接）
                    [[HDRongCloudTool sharedInstance] requestToken:accessToken];
                    
                    // 在连接融云时，若有跳转需求时，跳转到指定的页面
                    NSString *type;
                    NSString *apnsType = [HDSystemConfigModel shareModel].apnsType;
                    NSString *loaclNSType = [HDSystemConfigModel shareModel].localNSType;
                    
                    /**
                     * 2种情况：
                     * 1、本地通知；
                     * 2、推送通知；
                     * 2者取一，或者2者都无
                     */
                    if (apnsType) {
                        type = apnsType;
                    } else if (loaclNSType) {
                        type = loaclNSType;
                    }
                    
                    if (type) {
                        self.onJumpHandler(type);
                    }
                }
            }
        }];
        
        // 需要版本升级 UPDATE_APP
        [self.bridge registerHandler:@"UPDATE_APP" handler:^(id data, WVJBResponseCallback responseCallback) {
            if (weakHostViewController && [weakHostViewController respondsToSelector:@selector(jsActionRequestUpdateWithType:andCallBack:)]) {
                [weakHostViewController jsActionRequestUpdateWithType:[CommonUtils checkString:[(NSDictionary *)data objectForKey:@"type"]] andCallBack:^(NSDictionary *updateResult) {
                    
                    if (responseCallback) {
                        NSString *jsonString = [H5AppLauncher jsonWithObject:updateResult];
                        responseCallback(jsonString);
                    }
                }];
            }
        }];
        
        // 将字符串复制到粘贴板
        [self.bridge registerHandler:@"CLIPBOARD_HANDLER" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            BOOL copyResult = NO;
            NSDictionary *dataDic = [CommonUtils checkDictionary:data];
            if (dataDic) {
                NSString *copyString = [CommonUtils checkString:[dataDic objectForKey:@"copyText"]];
                if (copyString.length > 0) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = copyString;
                    copyResult = YES;
                }
            }
            
            NSDictionary *resultInfo = @{@"resultStatus":[NSNumber numberWithBool:copyResult]};
            NSString *jsonString = [H5AppLauncher jsonWithObject:resultInfo];
            if (responseCallback) {
                responseCallback(jsonString);
            }
        }];
        
        // 根据路径将图片保存到本地相册
        // {url:***}   {resultStatus:false\true}
        [self.bridge registerHandler:@"SAVE_PHOTO" handler:^(id data, WVJBResponseCallback responseCallback) {
            // 下载图片并保存在本地
            NSDictionary *dataDic = [CommonUtils checkDictionary:data];
            if (weakHostViewController && [weakHostViewController respondsToSelector:@selector(jsActionSavedPhotosAlbumWithUrl:andCallBack:)]) {
                [weakHostViewController jsActionSavedPhotosAlbumWithUrl:dataDic andCallBack:^(NSDictionary *saveResultInfo) {
                    
                    if (responseCallback) {
                        NSString *jsonString = [H5AppLauncher jsonWithObject:saveResultInfo];
                        responseCallback(jsonString);
                    }
                }];
            }
        }];
        
        [self.bridge registerHandler:@"SHARE_GROUP" handler:^(id data, WVJBResponseCallback responseCallback) {
            // 分享并回调结果
            NSDictionary *dataDic = [CommonUtils checkDictionary:data];
            if (weakHostViewController && [weakHostViewController respondsToSelector:@selector(jsActionShareGroupWithInfo:andCallBack:)]) {
                
                [weakHostViewController jsActionShareGroupWithInfo:dataDic andCallBack:^(NSDictionary *shareResult) {
                    // 根据后端需要设置回调
                    if (responseCallback) {
                        NSString *jsonString = [H5AppLauncher jsonWithObject:shareResult];
                        responseCallback(jsonString);
                    } else {
                        if ([[shareResult objectForKey:@"result"] boolValue]) {
                            [CommonUtils showBannerTipsWithMessage:@"分享成功" andType:BannerTipsTypeSuccess];
                        } else {
                            [CommonUtils showBannerTipsWithMessage:@"分享失败" andType:BannerTipsTypeError];
                        }
                    }
                }];
            }
        }];
        
        [self.bridge registerHandler:@"SHARE_SINGLE" handler:^(id data, WVJBResponseCallback responseCallback) {
            // 分享并回调结果
            NSDictionary *dataDic = [CommonUtils checkDictionary:data];
            if (weakHostViewController && [weakHostViewController respondsToSelector:@selector(jsActionShareSingleWithInfo:andCallBack:)]) {
                
                [weakHostViewController jsActionShareSingleWithInfo:dataDic andCallBack:^(NSDictionary *shareResult) {
                    // 根据后端需要设置回调
                    if (responseCallback) {
                        NSString *jsonString = [H5AppLauncher jsonWithObject:shareResult];
                        responseCallback(jsonString);
                    } else {
                        if ([[shareResult objectForKey:@"result"] boolValue]) {
                            [CommonUtils showBannerTipsWithMessage:@"分享成功" andType:BannerTipsTypeSuccess];
                        } else {
                            [CommonUtils showBannerTipsWithMessage:@"分享失败" andType:BannerTipsTypeError];
                        }
                    }
                }];
            }
        }];
        
        
        [self.bridge registerHandler:@"SET_NAV_RIGHT_BAR_ITEM" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSDictionary *itemInfo = [CommonUtils checkDictionary:data];
            if (weakHostViewController && [weakHostViewController respondsToSelector:@selector(jsActionCreateNavBarItems:)]) {
                
                [weakHostViewController jsActionCreateNavBarItems:itemInfo];
            }
        }];
        
        [self.bridge registerHandler:@"REGISTER_PUSH_MESSAGE_HANDLE_RULES" handler:^(id data, WVJBResponseCallback responseCallback) {
            // 将Data信息保存在UserDefault
            // RCMsgHandleRules
            NSArray *handleRules = [data objectForKey:@"RCMsgHandleRules"];
            [HDUserDefaultTool updateRCMessageHandleRule:handleRules];
        }];
        
        [self.bridge registerHandler:@"QUERY_PHOTO_AUTHORIZE" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            // 检查照片和拍照的授权
            BOOL hasAuthor = NO;
            PHAuthorizationStatus phAuthor = [PHPhotoLibrary authorizationStatus];
            if (phAuthor == PHAuthorizationStatusDenied || phAuthor == PHAuthorizationStatusRestricted) {
                [HDSendLocalNotificationTool sendSystemAutotizeAlertWithTitle:NSLocalizedString(@"AuthorizeAlertWithPhotosTitle", @"") body:NSLocalizedString(@"AuthorizeAlertWithPhotosBody", @"")];
            } else {
                AVAuthorizationStatus avAuthor = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (avAuthor == AVAuthorizationStatusDenied || avAuthor == AVAuthorizationStatusRestricted) {
                    [HDSendLocalNotificationTool sendSystemAutotizeAlertWithTitle:NSLocalizedString(@"AuthorizeAlertWithCameraTitle", @"") body:NSLocalizedString(@"AuthorizeAlertWithCameraBody", @"")];
                } else {
                    hasAuthor = YES;
                }
            }
            
            // 根据后端需要设置回调
            if (responseCallback) {
                NSString *jsonString = [H5AppLauncher jsonWithObject:@{@"result":[NSNumber numberWithBool:hasAuthor]}];
                responseCallback(jsonString);
            }
        }];
        
        [self.bridge registerHandler:@"GRADIENT_NAVIGATION_BAR" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            if (weakHostViewController && [weakHostViewController respondsToSelector:@selector(jsActionSetGradientNavigationBar:)]) {
                
                [weakHostViewController jsActionSetGradientNavigationBar:[CommonUtils checkDictionary:data]];
            }
        }];
        
        [self.bridge registerHandler:@"REVEIVED_REDPAPER_PAGE" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            if (weakHostViewController && [weakHostViewController respondsToSelector:@selector(jsActionOpenReceivedRedPaperPage:)]) {
                [weakHostViewController jsActionOpenReceivedRedPaperPage:[CommonUtils checkDictionary:data]];
            }
        }];
        
        
        [self.bridge registerHandler:@"GEOLOCATION_GET_CURRENT_POSITION" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            if (weakHostViewController && [weakHostViewController respondsToSelector:@selector(jsActionLocationWithInfo:andCallBack:)]) {
                [weakHostViewController jsActionLocationWithInfo:[CommonUtils checkDictionary:data] andCallBack:^(NSDictionary *locationResult) {
                    if (responseCallback) {
                        NSString *jsonString = [H5AppLauncher jsonWithObject:locationResult];
                        responseCallback(jsonString);
                    }
                }];
            }
        }];
        
        
        // TODO:qids 存酒改造的handler迁移
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // 1.GET_UUID:获取无线网卡mac地址,接收参数:无,回调方法参数：mac地址（去横杠,去冒号）
        [self.bridge registerHandler:@"GET_UUID" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            if (responseCallback) {
                responseCallback(@{@"uuid":[UUIDTool uuidForDevice]});
            }
        }];
        
        // 2.DOWNLOAD_FILE:下载文件(强制覆盖目标文件)，接收参数：文件url、本地存储地址（相对于资源根路径，）,回调方法参数：是否成功
        [self.bridge registerHandler:@"DOWNLOAD_FILE" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataInfo = [CommonUtils checkDictionary:data];
            NSString *fileUrl = [CommonUtils checkString:dataInfo[@"fileUrl"]];
            NSString *localPath = [FileManagerTool fileAbsolutePath:[CommonUtils checkString:dataInfo[@"localPath"]] needCreate:YES];
            
            if (fileUrl && localPath) {
                [[FileDownloadTool shareTool] downloadFileWithUrl:fileUrl andLocalPath:localPath andCallBack:^(BOOL checkResult) {
                    if (responseCallback) {
                        responseCallback(@{@"result": [NSNumber numberWithBool:checkResult]});
                    }
                }];
            } else {
                // 下载失败
                if (responseCallback) {
                    responseCallback(@{@"result": @NO});
                }
            }
        }];
        
        // 3.COPY_FILE:复制文件(强制覆盖目标文件)，接收参数：源文件本地地址（以下所有本地路径均为相对于资源根路径的相对路径）、目标文件本地地址,回调方法参数：是否成功
        [self.bridge registerHandler:@"COPY_FILE" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataInfo = [CommonUtils checkDictionary:data];
            NSString *localPath = [FileManagerTool fileAbsolutePath:[CommonUtils checkString:dataInfo[@"localPath"]] needCreate:NO];
            NSString *targetLocalPath = [FileManagerTool fileAbsolutePath:[CommonUtils checkString:dataInfo[@"targetLocalPath"]] needCreate:YES];
            
            BOOL result = [FileManagerTool copyFileAtPath:localPath toPath:targetLocalPath];
            if (responseCallback) {
                responseCallback(@{@"result":[NSNumber numberWithBool:result]});
            }
        }];
        
        // 4.MOVE_FILE:移动文件(强制覆盖目标文件，兼容用以重命名文件),接收参数：源文件本地地址（以下所有本地路径均为相对于资源根路径的相对路径）、目标文件本地地址,回调方法参数：是否成功
        [self.bridge registerHandler:@"MOVE_FILE" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataInfo = [CommonUtils checkDictionary:data];
            NSString *localPath = [FileManagerTool fileAbsolutePath:[CommonUtils checkString:dataInfo[@"localPath"]] needCreate:NO];
            NSString *targetLocalPath = [FileManagerTool fileAbsolutePath:[CommonUtils checkString:dataInfo[@"targetLocalPath"]] needCreate:YES];
            
            BOOL result = [FileManagerTool moveFileAtPath:localPath toPath:targetLocalPath];
            if (responseCallback) {
                responseCallback(@{@"result":[NSNumber numberWithBool:result]});
            }
        }];
        
        // 5.IS_FILE_EXIST:检查文件是否存在,接收参数：文件本地地址,回调方法参数：是否存在
        [self.bridge registerHandler:@"IS_FILE_EXIST" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            if (responseCallback) {
                
                NSDictionary *dataInfo = [CommonUtils checkDictionary:data];
                NSString *localPath = [FileManagerTool fileAbsolutePath:[CommonUtils checkString:dataInfo[@"localPath"]] needCreate:NO];
                BOOL result = [FileManagerTool fileExistsAtLocalPath:localPath];
                responseCallback(@{@"result": [NSNumber numberWithBool:result]});
            }
        }];
        
        // 6.DELETE_FILE:删除文件,接收参数：文件本地地址,回调方法参数：是否成功
        [self.bridge registerHandler:@"DELETE_FILE" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataInfo = [CommonUtils checkDictionary:data];
            NSString *localPath = [FileManagerTool fileAbsolutePath:[CommonUtils checkString:dataInfo[@"localPath"]] needCreate:NO];
            
            BOOL result = [FileManagerTool removeFileAtPath:localPath];
            if (responseCallback) {
                responseCallback(@{@"result":[NSNumber numberWithBool:result]});
            }
        }];
        
        // 7.WRITE_TEXT_TO_FILE:写文本文件（追加方式，UTF编码写入，如果文件不存在，自动创建，如果文件地址中的目录不存在，自动创建）,接收参数：文件本地地址、写入的内容（字符串）,回调方法参数：是否成功
        [self.bridge registerHandler:@"WRITE_TEXT_TO_FILE" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataInfo = [CommonUtils checkDictionary:data];
            NSString *localPath = [FileManagerTool fileAbsolutePath:[CommonUtils checkString:dataInfo[@"localPath"]] needCreate:YES];
            NSString *content = [CommonUtils checkString:dataInfo[@"content"]];
            
            BOOL result = [FileManagerTool writeToFileEndAtPath:localPath andContent:content];
            if (responseCallback) {
                responseCallback(@{@"result":[NSNumber numberWithBool:result]});
            }
        }];
        
        // 8.READ_TEXT_FILE:读取文本文件（UTF8编码读取）,接收参数：文件本地地址,回调方法参数：是否成功、读取的文本
        [self.bridge registerHandler:@"READ_TEXT_FILE" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            if (responseCallback) {
                NSDictionary *dataInfo = [CommonUtils checkDictionary:data];
                NSString *localPath = [FileManagerTool fileAbsolutePath:[CommonUtils checkString:dataInfo[@"localPath"]] needCreate:NO];
                
                NSDictionary *resultInfo = [FileManagerTool readFileContentAtPath:localPath];
                responseCallback(resultInfo);
            }
        }];
        
        // 9.UNZIP_FILE:解压ZIP文件,接收参数：zip文件本地地址、目标目录（相对于资源根路径）,回调方法参数：是否成功
        [self.bridge registerHandler:@"UNZIP_FILE" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataInfo = [CommonUtils checkDictionary:data];
            NSString *localPath = [FileManagerTool fileAbsolutePath:[CommonUtils checkString:dataInfo[@"localPath"]] needCreate:NO];
            NSString *targetLocalPath = [FileManagerTool directoryAbsolutePath:[CommonUtils checkString:dataInfo[@"targetLocalPath"]] needCreate:YES];
            
            BOOL result = NO;
            if (localPath && targetLocalPath) {
                result = [ZipArchiveTool unzipFileAtPath:localPath toDestination:targetLocalPath];
            }
            if (responseCallback) {
                responseCallback(@{@"result": [NSNumber numberWithBool:result]});
            }
        }];
        
        // 10.GET_FILE_MD5:获取文件MD5,接收参数：文件本地地址,回调方法参数：MD5字符串，如果获取失败，返回空字符串
        [self.bridge registerHandler:@"GET_FILE_MD5" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            if (responseCallback) {
                NSDictionary *dataInfo = [CommonUtils checkDictionary:data];
                NSString *localPath = [FileManagerTool fileAbsolutePath:[CommonUtils checkString:dataInfo[@"localPath"]] needCreate:NO];
                
                NSString *md5String = nil;
                if (localPath) {
                    // TODO:qids 第三方库的方法：需要 导入第三方库AliyunOSSiOS
                    md5String = [OSSUtil fileMD5String:localPath];
                }
                
                NSDictionary *resultInfo;
                if (md5String && md5String.length > 0) {
                    resultInfo = @{@"result":@YES,
                                   @"md5String": md5String};
                } else {
                    resultInfo = @{@"result":@NO};
                }
                
                responseCallback(resultInfo);
            }
        }];
        
        // 11.COPY_DIR:复制目录（强制合并），接收参数：目录本地地址、目标目录地址（最终目录，而不是复制到这个目录下），回调方法参数：是否成功
        [self.bridge registerHandler:@"COPY_DIR" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataInfo = [CommonUtils checkDictionary:data];
            NSString *localPath = [FileManagerTool directoryAbsolutePath:[CommonUtils checkString:dataInfo[@"localPath"]] needCreate:NO];
            NSString *targetLocalPath = [FileManagerTool directoryAbsolutePath:[CommonUtils checkString:dataInfo[@"targetLocalPath"]] needCreate:YES];
            
            BOOL result = [FileManagerTool copyDirctoryAtPath:localPath toPath:targetLocalPath];
            if (responseCallback) {
                responseCallback(@{@"result":[NSNumber numberWithBool:result]});
            }
        }];
        
        // 12.MOVE_DIR:移动目录（强制合并），接收参数：目录本地地址、目标目录地址（最终目录，而不是移动到这个目录下，为了兼容重命名），回调方法参数：是否成功
        [self.bridge registerHandler:@"MOVE_DIR" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataInfo = [CommonUtils checkDictionary:data];
            NSString *localPath = [FileManagerTool directoryAbsolutePath:[CommonUtils checkString:dataInfo[@"localPath"]] needCreate:NO];
            NSString *targetLocalPath = [FileManagerTool directoryAbsolutePath:[CommonUtils checkString:dataInfo[@"targetLocalPath"]] needCreate:YES];
            
            BOOL result = [FileManagerTool moveDirctoryAtPath:localPath toPath:targetLocalPath];
            if (responseCallback) {
                responseCallback(@{@"result":[NSNumber numberWithBool:result]});
            }
        }];
        
        // 13.DELETE_DIR:删除目录（不管是否非空），接收参数：目录本地地址，回调方法参数：是否成功
        [self.bridge registerHandler:@"DELETE_DIR" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSDictionary *dataInfo = [CommonUtils checkDictionary:data];
            NSString *localPath = [FileManagerTool directoryAbsolutePath:[CommonUtils checkString:dataInfo[@"localPath"]] needCreate:NO];
            
            BOOL result = [FileManagerTool removeDirctoryAtPath:localPath];
            if (responseCallback) {
                responseCallback(@{@"result":[NSNumber numberWithBool:result]});
            }
        }];
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    }
    
    @end
