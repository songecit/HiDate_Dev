//
//  HDBaseWebViewController.m
//  HiParty
//
//  Created by HiDate on 16/1/18.
//  Copyright © 2016年 830clock. All rights reserved.
//

#import "HDBaseWebViewController.h"
#import "H5AppLauncher.h"
#import "H5Update.h"
#import "UIViewController+blockPro.h"
#import "HDBaseNavigationController.h"
#import "HDBaseWebViewLoadingView.h"
#import "HDUploadVideoManager.h"
#import "HDUploadAliYImage.h"
#import "HDSystemConfigModel.h"
#import "HDSaveImageAlbumManager.h"
#import "HDShareContentHandle.h"
#import "HDReceivedRedPaperViewController.h"
#import "HDImitateNavgationBar.h"
#import "LocationManagerTool.h"
#import "HiDate-Swift.h"

typedef NS_ENUM(NSUInteger, HDBaseWebViewControllerWebLoadType) {
    HDBaseWebViewControllerWebLoadTypeLocal,            //本地页面加载
    HDBaseWebViewControllerWebLoadTypeRequest           //网络地址加载
};

#define SPECIFYPAGE_REDPAPERRECORD @"/redbag/record.html"   // @"/entry/app.html"


#if WHETHER_USER_WKWEBVIEW == 1

#import <WebKit/WebKit.h>
@interface HDBaseWebViewController () <H5AppLauncherJSAction, WKNavigationDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIView *loadingBlackView;
@property (weak, nonatomic) IBOutlet UIProgressView *loadingProgressView;
@property (weak, nonatomic) WKWebView *wkWebView;
@property (nonatomic, copy) NSString *localFileBasePath;

#else

#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
@interface HDBaseWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate, H5AppLauncherJSAction, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIView *loadingBlackView;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;

#endif

@property (nonatomic, strong) H5AppLauncher *launcher;
@property (nonatomic, assign) HDBaseWebViewControllerWebLoadType loadType;
@property (nonatomic, copy) NSString *localFilePath;
@property (nonatomic, copy) NSString *requestUrl;
@property (nonatomic, strong) HDBaseWebViewLoadingView *loadingView;
@property (nonatomic, strong) HDUploadVideoManager *uploadVideoManager;
@property (nonatomic, strong) HDSaveImageAlbumManager *saveImageAlbumManager;
@property (nonatomic, assign) BOOL enableNativeBack;
@property (nonatomic, strong) LocationManagerTool *locationTool;

@property (nonatomic, weak) HDImitateNavgationBar *imitateNavigationBar;

@end

@implementation HDBaseWebViewController

- (instancetype)initRequestUrlWithUrl:(NSString *)url
{
#if WHETHER_USER_WKWEBVIEW == 1
    self = [super initWithNibName:@"HDBaseWebViewController_WKWebView" bundle:nil];
#else
    self = [super initWithNibName:@"HDBaseWebViewController_UIWebView" bundle:nil];
#endif
    if (self) {
        self.loadType = HDBaseWebViewControllerWebLoadTypeRequest;
        self.requestUrl = url;
        
        self.webUrlString = url;
    }
    return self;
}

#if WHETHER_USER_WKWEBVIEW == 1
- (instancetype)initLocalUrlWithFilePathUrl:(NSString *)fileUrl
                                andBaseDirc:(NSString *)fileBasePath
{
    self = [super initWithNibName:@"HDBaseWebViewController_WKWebView" bundle:nil];
    if (self) {
        self.loadType = HDBaseWebViewControllerWebLoadTypeLocal;
        self.localFilePath = fileUrl;
        self.localFileBasePath = fileBasePath;
        
        self.webUrlString = fileUrl;
    }
    return self;
}

- (void)insertWkWebView
{
    if (self.wkWebView) {
        [self.wkWebView removeFromSuperview];
        self.wkWebView = nil;
    }
    WKPreferences *pref = [[WKPreferences alloc] init];
    pref.javaScriptEnabled = YES;
    pref.javaScriptCanOpenWindowsAutomatically = YES;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences = pref;
    
    WKWebView *webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, HD_SCREEN_WIDTH, HD_SCREEN_HEIGHT - 64) configuration:config];
    webview.backgroundColor = HDColorListContentColor;
    webview.scrollView.backgroundColor = HDColorListContentColor;
    webview.navigationDelegate = self;
    [webview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.view insertSubview:webview belowSubview:self.loadingBlackView];
    self.wkWebView = webview;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"BaseWebviewVC_Title",nil);
    
    self.wkWebView.alpha = 0.0f;
    self.wkWebView.scrollView.bounces = NO;
    self.wkWebView.scrollView.showsVerticalScrollIndicator = NO;
    self.wkWebView.scrollView.showsHorizontalScrollIndicator = NO;
    
    [self insertWkWebView];
    
    [self loadLauncher];
    
    self.enableNativeBack = YES;
    [HDSystemConfigModel shareModel].extraData = nil;
    
    [self setupBackItemWithAction:@selector(clickBackButton)];
}

- (void)dealloc
{
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.loadingProgressView.alpha = 1.0f;
        CGFloat newProgress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        newProgress = MIN(MAX(newProgress, self.loadingProgressView.progress), 1.0f);
        [self.loadingProgressView setProgress:newProgress animated:YES];
        if (newProgress >= 1.0f) {
            self.loadingProgressView.alpha = 0.0f;
            self.loadingProgressView.progress = 0.0f;
        }
    }
}

#pragma mark - WKNavigationDelegate Method
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    if ([url.scheme isEqualToString:@"tel"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showCallTelAlertView:url];
        });
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    self.enableNativeBack = NO;
    
    [UIView animateWithDuration:1.f animations:^{
        self.wkWebView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.loadingBlackView.alpha = 0;
        self.loadingBlackView.hidden = YES;
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    HDLog(@"%@", error.description);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0)
{
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    
}

#pragma mark - Tel Alert
- (void)showCallTelAlertView:(NSURL *)url
{
    if (url.absoluteString.length > 4) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确定拨打电话：%@ 吗？", [url.absoluteString substringFromIndex:4]] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIApplication *app = [UIApplication sharedApplication];
            if ([app canOpenURL:url]) {
                [app openURL:url];
            }
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#else
- (instancetype)initLocalUrlWithFilePathUrl:(NSString *)fileUrl
{
    self = [super initWithNibName:@"HDBaseWebViewController_UIWebView" bundle:nil];
    if (self) {
        self.loadType = HDBaseWebViewControllerWebLoadTypeLocal;
        self.localFilePath = fileUrl;
        
        self.webUrlString = fileUrl;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"BaseWebviewVC_Title",nil);
    
    self.webview.alpha = 0.0f;
    self.webview.scalesPageToFit = YES;
    self.webview.scrollView.bounces = NO;
    
    [self initWebViewProgressView];
    [self loadLauncher];
    
    self.enableNativeBack = YES;
    [HDSystemConfigModel shareModel].extraData = nil;
    
    [self setupBackItemWithAction:@selector(clickBackButton)];
}

- (void)initWebViewProgressView
{
    self.progressProxy = [[NJKWebViewProgress alloc] init];
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;
    
    CGFloat progressViewHeight = 3.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0,
                                 navigationBarBounds.size.height - progressViewHeight,
                                 navigationBarBounds.size.width,
                                 progressViewHeight);
    self.progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.progressView.progressBarView.backgroundColor = HDColorMainColor;
    [self.navigationController.navigationBar addSubview:self.progressView];
    
    [self.progressProxy reset];
}

#pragma mark - NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress;
{
    HDLog(@"progress is %f",progress);
    
    [self.progressView setProgress:progress animated:YES];
    
    if (progress >= 1.0f) {
        if (!self.title
            || self.title.length == 0
            || [self.title isEqualToString:NSLocalizedString(@"BaseWebviewVC_Title",nil)]) {
            self.title = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
        }
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.enableNativeBack = NO;
    
    [UIView animateWithDuration:1.f animations:^{
        self.webview.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.loadingBlackView.alpha = 0;
        self.loadingBlackView.hidden = YES;
    }];
    
    //防止UIWebView内存泄露
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];//自己添加的，原文没有提到。
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的，原文没有提到。
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}
#endif

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ((self.requestUrl && [self.requestUrl containsString:SPECIFYPAGE_REDPAPERRECORD])
               || (self.localFilePath && [self.localFilePath containsString:SPECIFYPAGE_REDPAPERRECORD])) {

        [self.navigationController setNavigationBarHidden:YES animated:NO];
        if (!self.imitateNavigationBar) {
            HDImitateNavgationBar *bar = [[HDImitateNavgationBar alloc] initWithFrame:CGRectMake(0, 0, HD_SCREEN_WIDTH, 64)];
            bar.backgroundColor = HDColor_CE4242;
            [self.view addSubview:bar];
            bar.clickBackButtonBlock = ^{
                [self.navigationController popViewControllerAnimated:YES];
            };
            self.imitateNavigationBar = bar;
        }
    }
}

- (UIImage *)redrawImageWithRect:(CGRect)rect
{
    UIImage * targetImage = [UIImage imageNamed:@"hongbaojilu_title"];
    // redraw the image to fit |yourView|'s size
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.f);
    [targetImage drawInRect:CGRectMake(0.f, 0.f, rect.size.width, rect.size.height)];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // TODO:qids 测试代码
    NSString *pathInfo = @"";
#if API_PATH_ENVIRONMENT==0     // debug build环境可配置为开发、测试、生产
    pathInfo = @"debug build";
#elif API_PATH_ENVIRONMENT==1   // Release Archive测试环境打包
    pathInfo = @"测试环境打包";
#elif API_PATH_ENVIRONMENT==2   // Release Archive生产环境打包
    pathInfo = @"生产环境打包";
#endif
    [CommonUtils showBannerTipsWithMessage:pathInfo andType:BannerTipsTypeSuccess];
    
    
    if (self.fromType == ViewControllerFromTypeNaviPop) {
        if (self.launcher && self.launcher.onResumeHandler) {
            self.launcher.onResumeHandler();
        }
    }
    
#if WHETHER_USER_WKWEBVIEW == 1
    if (!self.wkWebView.URL) {
        // 重新加载当前的view
        [self insertWkWebView];
        [self loadLauncher];
        HDLog(@"%@", self.wkWebView.URL);
    }
#endif
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
#if WHETHER_USER_WKWEBVIEW == 1
#else
    [self.progressView removeFromSuperview];
#endif
}

- (void)loadLauncher
{
    self.launcher = [[H5AppLauncher alloc] init];
    if (self.loadType == HDBaseWebViewControllerWebLoadTypeLocal) {
        
#if WHETHER_USER_WKWEBVIEW == 1
        [self.launcher launchLocalH5AppWithWebView:self.wkWebView
                         webViewHostViewController:self
                                         localPath:self.localFilePath
                                     localBasePath:self.localFileBasePath
                                   webViewDelegate:self.wkWebView.navigationDelegate];
#else
        [self.launcher launchLocalH5AppWithWebView:self.webview
                         webViewHostViewController:self
                                         localPath:self.localFilePath
                                   webViewDelegate:self.progressProxy];
#endif
    } else if (self.loadType == HDBaseWebViewControllerWebLoadTypeRequest) {
#if WHETHER_USER_WKWEBVIEW == 1
        [self.launcher launchOnlineH5AppWithWebView:self.wkWebView
                          webViewHostViewController:self
                                         requestUrl:self.requestUrl
                                    webViewDelegate:self.wkWebView.navigationDelegate];
#else
        [self.launcher launchOnlineH5AppWithWebView:self.webview
                          webViewHostViewController:self
                                         requestUrl:self.requestUrl
                                    webViewDelegate:self.progressProxy];
#endif
    }
}

- (HDBaseWebViewLoadingView *)loadingView
{
    if (_loadingView == nil) {
        _loadingView = [[[NSBundle mainBundle] loadNibNamed:@"HDBaseWebViewLoadingView" owner:nil options:nil] lastObject];
        _loadingView.loadingType = HDBaseWebViewLoadingViewTypeNormal;
    }
    
    return _loadingView;
}

- (void)responseLoadH5WithIsManifestSuccess:(BOOL)isManifestSuccess withIsNeedUpdata:(BOOL)isNeedUpdate withFileLoadProgress:(CGFloat)fileLoadProgress
{
    if (isManifestSuccess) {
        if (isNeedUpdate) {
            self.loadingView.loadingType = HDBaseWebViewLoadingViewTypeVerbose;
            self.loadingView.progress = fileLoadProgress;
        } else {
            [self.loadingView hideLoadingView];
        }
    } else {
        
    }
}

- (void)clickBackButton
{
    // 若为http，自动返回上一级页面
    if ([HDBaseWebViewController isHttpRequestUrl:self.webUrlString])
    {
#if WHETHER_USER_WKWEBVIEW == 1
        if ([self.wkWebView canGoBack])
        {
            [self.wkWebView goBack];
        }
#else
        if ([self.webview canGoBack])
        {
            [self.webview goBack];
        }
#endif
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        if (self.enableNativeBack)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            self.launcher.backBtnHandler();
        }
    }
}

- (void)pushMsg:(NSArray *)msgList
{
    self.launcher.onPushMsgHandler(msgList);
}

- (void)jumpHandler:(NSString *)type
{
    self.launcher.onJumpHandler(type);
}

#pragma mark - H5AppLauncherJSAction

- (void)jsActionSetTitleBarWithTitle:(NSString *)title andIsHideBar:(NSString *)isHideBar
{

    if ((self.requestUrl && [self.requestUrl containsString:SPECIFYPAGE_REDPAPERRECORD])
        || (self.localFilePath && [self.localFilePath containsString:SPECIFYPAGE_REDPAPERRECORD])) {
        
        // 特殊处理，需要隐藏导航条
        if (self.imitateNavigationBar) {
            [self.imitateNavigationBar updateTitle:title];
        }
    } else {
        self.title = title;
    }
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        self.title = title;
    //    });

}

- (void)jsActionClosePageWithPageFrom:(NSString *)pageFrom
                             andExtra:(id)extra
{
    if (self.popBackBlock) {
        self.popBackBlock(pageFrom, extra);
    }
    [HDSystemConfigModel shareModel].extraData = extra;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)jsActionOpenPageWithPage:(NSString *)pageTo isCloseBefore:(BOOL)isCloseBefore
{
    [HDBaseWebViewController openNewWebViewWithPage:pageTo isCloseBefore:isCloseBefore andController:self];
}

+ (void)openNewWebViewWithPage:(NSString *)pageTo isCloseBefore:(BOOL)isCloseBefore andController:(UIViewController *)controller
{
    BOOL isHttp = [HDBaseWebViewController isHttpRequestUrl:pageTo];
    HDBaseWebViewController *webViewController = nil;
#if WHETHER_USER_WKWEBVIEW == 1
    if (isHttp)
    {
        webViewController = [[HDBaseWebViewController alloc] initRequestUrlWithUrl:pageTo];
    }
    else
    {
        // 加载本地html并传参
        pageTo = [pageTo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        webViewController = [[HDBaseWebViewController alloc] initLocalUrlWithFilePathUrl:pageTo andBaseDirc:[H5Update getNewH5AppSanboxPath]];
    }
#else
    if (isHttp)
    {
        
    }
    else
    {
        // 加载本地html并传参
        pageTo = [pageTo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    webViewController = [[HDBaseWebViewController alloc] initRequestUrlWithUrl:pageTo];
#endif
    
    if (isCloseBefore)
    {
        // 退出登录时，融云也要退出
        [[HDRongCloudTool sharedInstance] logout];
        // 退出登录时，保存的apnsType或者localNSType清空
        [HDSystemConfigModel shareModel].apnsType = nil;
        [HDSystemConfigModel shareModel].localNSType = nil;
        
        // TODO:qids 权宜之计
        // 若有强制更新时，window.rootViewController重新赋值时，会把强制更新的弹框移除。因此，加判断，无强制更新时，执行以下代码
        if (![HDSystemConfigModel shareModel].isNeedForceUpdate)
        {
            HDBaseNavigationController *mainViewController = [[HDBaseNavigationController alloc] initWithRootViewController:webViewController];
            controller.view.window.rootViewController = mainViewController;
        }
    }
    else
    {
        [controller.navigationController pushViewController:webViewController animated:YES];
    }
}


+ (BOOL)isHttpRequestUrl:(NSString *)urlString
{
    BOOL isHttp = NO;
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *scheme = url.scheme;
    
    if ([scheme hasPrefix:@"http"]
        || [scheme hasPrefix:@"HTTP"])
    {
        isHttp = YES;
    }
    
    return isHttp;
}

- (void)jsActionUploadVideoWithExtra:(NSDictionary *)extra
                         andCallBack:(void(^)(NSDictionary *videoInfo))callBack
{
    // 选择视频并上传
    self.uploadVideoManager = [[HDUploadVideoManager alloc] init];
    self.uploadVideoManager.extra = extra;
    self.uploadVideoManager.resultCallBack = callBack;
    self.uploadVideoManager.targetController = self;
    [self.uploadVideoManager jumpToChooseVideoController];
}

- (void)jsActionSavedPhotosAlbumWithUrl:(NSDictionary *)imageInfo
                            andCallBack:(void(^)(NSDictionary *saveResultInfo))callBack
{
    self.saveImageAlbumManager = [[HDSaveImageAlbumManager alloc] init];
    self.saveImageAlbumManager.resultCallBack = callBack;
    self.saveImageAlbumManager.targetController = self;
    [self.saveImageAlbumManager tryWriteAlbumWithImageInfo:imageInfo];
}

- (void)jsActionRequestUpdateWithType:(NSString *)type
                          andCallBack:(void(^)(NSDictionary *updateResult))callBack
{
    //type  =1 运行时   =2 检查更新
    if ([type isEqualToString:@"2"]) {
        [HDSystemConfigModel shareModel].resultCallBack = callBack;
    } else {
        // 增加nil，单例模式，为H5手动检查更新而设置
        [HDSystemConfigModel shareModel].resultCallBack = nil;
    }
    
    [[HDSystemConfigModel shareModel] requestVersion];
}

// 分享
- (void)jsActionShareGroupWithInfo:(NSDictionary *)info
                       andCallBack:(void(^)(NSDictionary *shareResult))callBack
{
    NSDictionary *shareData = @{@"title" : [CommonUtils checkString:info[@"title"]],
                                @"content" : [CommonUtils checkString:info[@"content"]],
                                @"url" : [CommonUtils checkString:info[@"url"]],
                                @"imageUrl" : [CommonUtils checkString:info[@"imageUrl"]]};
    
    // 1,微信  2,朋友圈 3,qq 4,微博 5,ALL
    NSMutableArray *channelArray = [NSMutableArray array];
    NSInteger channel = [info[@"channel"] integerValue];
    for (int i = 0; i < 10; i ++) {
        int pow_2_i = pow(2, i);
        if (pow_2_i > channel) {
            break;
        } else {
            if ((pow_2_i & channel) == pow_2_i) {
                [channelArray addObject:[NSNumber numberWithInt:pow_2_i]];
            }
        }
    }
    
    [HDShareViewController showShareViewWithAnimated:YES shareChannelOptions:channelArray shareButtonClick:^(NSInteger shareBtnIndex) {
        [HDShareContentHandle shareContentWithData:shareData withShareType:shareBtnIndex withCompleteBlock:^(BOOL isSuccess) {
            if (isSuccess) {
                // [self.hudViewNV showSuccess:@"分享成功"];
                callBack(@{@"result":@YES});
            } else {
                // [self.hudViewNV showSuccess:@"分享失败"];
                callBack(@{@"result":@NO});
            }}];
    }];
}

// 分享
- (void)jsActionShareSingleWithInfo:(NSDictionary *)info
                        andCallBack:(void(^)(NSDictionary *shareResult))callBack
{
    NSDictionary *shareData = @{@"title" : [CommonUtils checkString:info[@"title"]],
                                @"content" : [CommonUtils checkString:info[@"content"]],
                                @"url" : [CommonUtils checkString:info[@"url"]],
                                @"imageUrl" : [CommonUtils checkString:info[@"imageUrl"]]};
    
    HDShareContentHandleType shareType = 0;
    // 1,微信  2,朋友圈 4,qq 8,微博
    NSInteger channel = [info[@"channel"] integerValue];
    
    if (channel == 1) {
        shareType = HDShareContentHandleTypeWeChat;
    } else if (channel == 2) {
        shareType = HDShareContentHandleTypePengYouQuan;
    } else if (channel == 4) {
        shareType = HDShareContentHandleTypeQQ;
    } else if (channel == 8) {
        shareType = HDShareContentHandleTypeSinaWeiBo;
    }
    
    // 保证channel是有效值
    if (shareType != 0) {
        [HDShareContentHandle shareContentWithData:shareData withShareType:shareType withCompleteBlock:^(BOOL isSuccess) {
            if (isSuccess) {
                // [self.hudViewNV showSuccess:@"分享成功"];
                callBack(@{@"result":@YES});
            } else {
                // [self.hudViewNV showSuccess:@"分享失败"];
                callBack(@{@"result":@NO});
            }
        }];
    }
}

- (void)jsActionCreateNavBarItems:(NSDictionary *)barItemsInfo
{
    // 创建导航条右上角的2个操作按钮
    NSArray *barItemList = [barItemsInfo objectForKey:@"barItemList"];
    NSMutableArray *barButtonItemList = nil;
    
    if (barItemList.count > 0) {
        barButtonItemList = [NSMutableArray array];
        [barButtonItemList addObject:[self createNavSpaceItem:10]];
        for (NSDictionary *info in barItemList) {
            UIBarButtonItem *item = [self createBarItemWithText:info[@"label"] andImage:info[@"icon"] andTag:[info[@"id"] integerValue] andAction:@selector(clickRightBarItem:)];
            [barButtonItemList addObject:item];
        }
    }
    
    self.navigationItem.rightBarButtonItems = barButtonItemList;
}

- (void)jsActionSetGradientNavigationBar:(NSDictionary *)gradientInfo
{
    // 设置导航条的渐变背景
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:[self imageWithRect:self.navigationController.navigationBar.frame
                                                                                                    andPoint0:CGPointMake(0, 0)
                                                                                                    andPoint1:CGPointMake(1, 0)
                                                                                                    andColor0:UIColorRGBA(224, 82, 92, 1)
                                                                                                    andColor1:UIColorRGBA(188, 54, 54, 1)]];
    // [UIImage imageNamed:@"hongbaojilu_title"]];
}


// 这边用的imageWithBgColor方法
-(UIImage *)imageWithRect:(CGRect)rect andPoint0:(CGPoint)inputPoint0 andPoint1:(CGPoint)inputPoint1 andColor0:(UIColor *)inputColor0 andColor1:(UIColor *)inputColor1
{
    rect = CGRectMake(0, 0, rect.size.width, 64);
    CIFilter *ciFilter = [CIFilter filterWithName:@"CILinearGradient"];
    CIVector *vector0 = [CIVector vectorWithX:rect.size.width * inputPoint0.x Y:rect.size.height * (1 - inputPoint0.y)];
    CIVector *vector1 = [CIVector vectorWithX:rect.size.width * inputPoint1.x Y:rect.size.height * (1 - inputPoint1.y)];
    [ciFilter setValue:vector0 forKey:@"inputPoint0"];
    [ciFilter setValue:vector1 forKey:@"inputPoint1"];
    [ciFilter setValue:[CIColor colorWithCGColor:inputColor0.CGColor] forKey:@"inputColor0"];
    [ciFilter setValue:[CIColor colorWithCGColor:inputColor1.CGColor] forKey:@"inputColor1"];
    
    CIImage *ciImage = ciFilter.outputImage;
    CIContext *con = [CIContext contextWithOptions:nil];
    CGImageRef resultCGImage = [con createCGImage:ciImage
                                         fromRect:rect];
    UIImage *resultUIImage = [UIImage imageWithCGImage:resultCGImage];
    return resultUIImage;
}

- (void)jsActionOpenReceivedRedPaperPage:(NSDictionary *)redPaperInfo
{
    NSArray *controllers = self.navigationController.viewControllers;
    if (![[controllers lastObject] isMemberOfClass:[HDReceivedRedPaperViewController class]]) {
        
        UIImage *shotImage = [UIImage screenshot];
        HDReceivedRedPaperViewController *controller = [[HDReceivedRedPaperViewController alloc] initWithNibName:@"HDReceivedRedPaperViewController" bundle:nil];
        controller.infoData = redPaperInfo;
        controller.shotImage = shotImage;
        [self.navigationController pushViewController:controller animated:NO];
    }
}


- (IBAction)clickRightBarItem:(id)sender
{
    if (self.launcher && self.launcher.onRightBtnCallbackHandler) {
        self.launcher.onRightBtnCallbackHandler(((UIButton *)sender).tag);
    }
}

- (void)jsActionLocationWithInfo:(NSDictionary *)info
                     andCallBack:(void(^)(NSDictionary *locationResult))callBack
{
    // 定位
    self.locationTool = [[LocationManagerTool alloc] init];
    self.locationTool.resultCallBack = callBack;
    [self.locationTool tryLocationWithAccuracy:[[info objectForKey:@"enableHighAccuracy"] boolValue] andTimeout:[[info objectForKey:@"timeout"] integerValue]];
}

@end
