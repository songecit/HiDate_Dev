//
//  HDLikeLaunchViewController.m
//  HiDate
//
//  Created by qidangsong on 16/8/12.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "HDLikeLaunchViewController.h"
#import "H5Update.h"
#import "HDBaseWebViewController.h"
#import "HDBaseNavigationController.h"
#import "AppDelegate.h"
#import "HDBaseDataControllerUserCodeAction.h"
#import "HiDate-Swift.h"

@interface HDLikeLaunchViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *launchImage;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *progressInfoView;

@property (assign, nonatomic) CGFloat competeMaxProgress;

@end

@implementation HDLikeLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.progressView.progress = 0;
    self.progressView.progressTintColor = HDColor_EAC180;
    self.progressView.trackTintColor = HDColor_464754;
    self.progressInfoView.hidden = YES;
    
    [self setLikeLaunchImage];
    
    
    // 当覆盖安装时，置为首次启动模式
    NSString *nowVersion = [HDVersionTool getCurrentBundleShortVersion];
    NSString *localVersion = [HDUserDefaultTool getNativeAppVersion];
    if (![nowVersion isEqualToString:localVersion]) {
        [HDUserDefaultTool updateNativeAppVersion:nowVersion];
        [H5Update resetH5UpdateToFirstRunModel];
    }
    
    // 打印异常日志
    HDLog(@"%@", [self readH5UpdateErrorString]);
    
    [self attemptUpdateWebApp];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLikeLaunchImage
{
    CGFloat screenHeight = HD_SCREEN_HEIGHT;
    NSString *imageName = @"";
    if (screenHeight == 480) {
        imageName = @"LikeLaunchImage_640x960";
    } else if (screenHeight == 568) {
        imageName = @"LikeLaunchImage_640x1136";
    } else if (screenHeight == 667) {
        imageName = @"LikeLaunchImage_750x1334";
    } else if (screenHeight == 736) {
        imageName = @"LikeLaunchImage_1242x2208";
    } else {
        imageName = @"LikeLaunchImage_750x1334";
    }
    self.launchImage.image = [UIImage imageNamed:imageName];
}

- (void)attemptUpdateWebApp
{
    // 检查是否需要更新
    self.competeMaxProgress = 0.0f;
    H5Update *update = [H5Update shareUpdate];
    
    NSString *packageTime = [HDUserDefaultTool getH5AppTime];
    if ([packageTime isEqualToString:@"-1"]) {
        update.launchType = APPLaunchTypeFirstRun;
    } else {
        update.launchType = APPLaunchTypeStart;
    }
    
    update.loadProgressBlock = ^(int64_t completedCount, int64_t totalCount, BOOL didDownload) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDownloadProgress:completedCount andTotal:totalCount didDownload:didDownload];
        });
    };
    
    update.loadCompleteBlock = ^(NSString *launchH5Path, NSString *exceptContent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkUpdateCompleted:launchH5Path andExceptContent:exceptContent];
        });
    };
    
    [update checkH5AppChange];
}

- (void)updateDownloadProgress:(int64_t)completedCount andTotal:(int64_t)totalCount didDownload:(BOOL)didDownload
{
    self.progressInfoView.hidden = NO;
    
    // 最大值为1
    double completed = MIN((double)completedCount / (double)totalCount, 1.0);
    
    if (!didDownload) {
        // 正在下载中，为下载成功后的处理预留2%的进度
        completed *= 0.98;
    } else {
        // 下载结束
    }
    
    // 解决进度条跳动的问题，当前进度小于已加载进度时，显示最大进度
    self.competeMaxProgress = MAX(self.competeMaxProgress, completed);
    completed = self.competeMaxProgress;
    
    self.progressView.progress = completed;
    double completedX100 = completed * 100;
    self.progressLabel.text = [NSString stringWithFormat:@"正在更新%.0f%@", completedX100, @"%"];
}

// 检查更新结束后的本地校验
- (void)checkUpdateCompleted:(NSString *)launchH5Path andExceptContent:(NSString *)exceptContent
{
    // 版本损坏的的修复机制
    NSString *h5EntryPath = [launchH5Path stringByAppendingString:@"/entry/app.html"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:h5EntryPath]) {
        
        // 检查APP版本更新
        id<HDBaseDataControllerUserCodeAction> delegate = (id<HDBaseDataControllerUserCodeAction>)[UIApplication sharedApplication].delegate;
        if ([delegate respondsToSelector:@selector(baseDataControllerVersionUpdate)]) {
            [delegate baseDataControllerVersionUpdate];
        }
        
        [self storeVersionJSToFile:launchH5Path];
        
#if WHETHER_USER_WKWEBVIEW == 1
        HDBaseWebViewController *controller = [[HDBaseWebViewController alloc] initLocalUrlWithFilePathUrl:h5EntryPath andBaseDirc:launchH5Path];
#else
        HDBaseWebViewController *controller = [[HDBaseWebViewController alloc] initLocalUrlWithFilePathUrl:h5EntryPath];
#endif
        HDBaseNavigationController *mainViewController = [[HDBaseNavigationController alloc] initWithRootViewController:controller];
        self.view.window.rootViewController = mainViewController;
        
    } else {
       
        // 异常日志的记录
        NSString *errorString = [NSString stringWithFormat:@"时间：%@， 路径：(%@) 不存在，原因可能为：%@\n", [NSDate date].description,  launchH5Path, exceptContent];
        [self writeH5UpdateErrorString:errorString];
        
        // 在访问路径不存在（顺损坏）时,置为首次启动的模式
        // TODO:qids 重新下载的日志记录在本地文件
        [H5Update resetH5UpdateToFirstRunModel];
        [self attemptUpdateWebApp];
    }
}

- (void)writeH5UpdateErrorString:(NSString *)errorString
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"H5UpdateError.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    NSFileHandle *writeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [writeFile seekToEndOfFile];
    NSData *bufferData = [errorString dataUsingEncoding:NSUTF8StringEncoding];
    [writeFile writeData:bufferData];
}

- (NSString *)readH5UpdateErrorString
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"H5UpdateError.txt"];
    NSString *errorString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return errorString;
}

// 将version写入inject.js文件 window.APP_VERSION = "这里是APP版本";
- (void)storeVersionJSToFile:(NSString *)filePath
{
    NSString *versionJS = [NSString stringWithFormat:@"window.APP_VERSION = \"%@\";", [HDVersionTool getCurrentBundleShortVersion]];
    NSString *createPath = [filePath stringByAppendingString:@"/js/inject.js"];
    NSData *data = [versionJS dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:createPath contents:data attributes:nil];//创建文件
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
