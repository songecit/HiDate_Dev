//
//  H5AppLauncher.h
//  H5Launcher
//
//  Created by HiDate on 16/1/8.
//  Copyright © 2016年 HiDate. All rights reserved.
//
/** 启动器 **/


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if WHETHER_USER_WKWEBVIEW == 1
#import <WebKit/WebKit.h>
#endif

// 拍摄只有一种情况，即进入视频选择页面，之后可选拍摄
typedef NS_ENUM(NSInteger, JSUploadVideoType) {
    JSUploadVideoTypeMultiSelect = 1, //多选
    JSUploadVideoTypeSingleSelect ,   //相册多选
    JSUploadVideoTypeCamera           //直接打开相机
};

@protocol H5AppLauncherJSAction <NSObject>

@optional

/**
 *  设置标题栏的标题以及是否隐藏标题栏
 *
 *  @param title     标题文字
 *  @param isHideBar 是否隐藏
 */
- (void)jsActionSetTitleBarWithTitle:(NSString *)title
                        andIsHideBar:(NSString *)isHideBar;

/**
 *  关闭当前页面
 *
 *  @param pageFrom 来自哪个页面
 *  @param extra    额外参数
 */
- (void)jsActionClosePageWithPageFrom:(NSString *)pageFrom
                             andExtra:(id)extra;

/**
 *  跳到新页面
 *
 *  @param pageTo   跳到新页面的URL
 */
- (void)jsActionOpenPageWithPage:(NSString *)pageTo isCloseBefore:(BOOL)isCloseBefore;

/**
 *  调用选择相册控件获取照片
 *
 *  @param getPicsType 选择照片类型 为枚举
 *  @param callBack    回调 回调为字符串数组 为图片本地路径的字符串数组
 */
- (void)jsActionUploadVideoWithExtra:(NSDictionary *)extra
                         andCallBack:(void(^)(NSDictionary *videoInfo))callBack;


/**
 *  根据图片的url保存图片到相册
 *
 *  @param imageUrl 图片的url
 *  @param callBack    回调 回调为字符串数组 为图片本地路径的字符串数组
 */
- (void)jsActionSavedPhotosAlbumWithUrl:(NSDictionary *)imageInfo
                            andCallBack:(void(^)(NSDictionary *saveResultInfo))callBack;


/**
 *  根据type请求APP的更新
 *
 *  @param type 请求更新的类型   =1 运行时   =2 检查更新
 *  @param callBack    回调 回调为键值对，当无更新时回调
 */
- (void)jsActionRequestUpdateWithType:(NSString *)type
                          andCallBack:(void(^)(NSDictionary *updateResult))callBack;

/**
 *  根据info确定分享摸式（组合分享）
 *
 *  @param info 分享内容和分享模式
 *  @param callBack 回调 回调为键值对，当无更新时回调
 */
- (void)jsActionShareGroupWithInfo:(NSDictionary *)info
                       andCallBack:(void(^)(NSDictionary *shareResult))callBack;

/**
 *  根据info确定分享摸式（单个分享）
 *
 *  @param info 分享内容和分享模式
 *  @param callBack 回调 回调为键值对，当无更新时回调
 */
- (void)jsActionShareSingleWithInfo:(NSDictionary *)info
                        andCallBack:(void(^)(NSDictionary *shareResult))callBack;


/**
 *  创建Nav Bar上的操作按钮，点击时间后回调
 *
 *  @param barItemsInfo baritem list信息
 *  @param callBack 回调为当前出发的baritem
 */
- (void)jsActionCreateNavBarItems:(NSDictionary *)barItemsInfo;

/**
 *  创建渐变的导航条
 *
 *  @param gradientInfo 渐变信息
 */
- (void)jsActionSetGradientNavigationBar:(NSDictionary *)gradientInfo;


/**
 *  打开领取成功页面
 *
 *  @param redPaperInfo 红包和用户信息
 */
- (void)jsActionOpenReceivedRedPaperPage:(NSDictionary *)redPaperInfo;



/**
 获取定位信息

 @param info     定位的入参
 @param callBack 定位结果回调
 */
- (void)jsActionLocationWithInfo:(NSDictionary *)info
                     andCallBack:(void(^)(NSDictionary *locationResult))callBack;

@end


@interface H5AppLauncher : NSObject

@property (nonatomic, copy, readonly) void (^backBtnHandler) (void);
@property (nonatomic, copy, readonly) void (^onResumeHandler) (void);
@property (nonatomic, copy, readonly) void (^onPushMsgHandler) (NSArray *pushMsgList);
@property (nonatomic, copy, readonly) void (^onJumpHandler) (NSString *type);
@property (nonatomic, copy, readonly) void (^onRightBtnCallbackHandler) (NSInteger tag);

#if WHETHER_USER_WKWEBVIEW == 1
- (void)launchLocalH5AppWithWebView:(WKWebView *)webView
          webViewHostViewController:(id<H5AppLauncherJSAction>)hostViewController
                          localPath:(NSString *)localpath
                      localBasePath:(NSString *)localbasepath
                    webViewDelegate:(NSObject<WKNavigationDelegate>*)webViewDelegate;

- (void)launchOnlineH5AppWithWebView:(WKWebView *)webView
           webViewHostViewController:(id<H5AppLauncherJSAction>)hostViewController
                          requestUrl:(NSString *)requestUrl
                     webViewDelegate:(NSObject<WKNavigationDelegate>*)webViewDelegate;
#else
- (void)launchLocalH5AppWithWebView:(UIWebView *)webView
          webViewHostViewController:(id<H5AppLauncherJSAction>)hostViewController
                          localPath:(NSString *)localpath
                    webViewDelegate:(id<UIWebViewDelegate>)delegate;

- (void)launchOnlineH5AppWithWebView:(UIWebView *)webView
           webViewHostViewController:(id<H5AppLauncherJSAction>)hostViewController
                          requestUrl:(NSString *)requestUrl
                     webViewDelegate:(id<UIWebViewDelegate>)delegate;
#endif

@end
