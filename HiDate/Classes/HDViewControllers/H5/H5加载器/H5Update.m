//
//  H5Update.m
//  HiDate
//
//  Created by qidangsong on 16/8/10.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "H5Update.h"
#import "ZipArchiveTool.h"
#import "AFURLSessionManager.h"
#import "AFHTTPSessionManager.h"
#import "H5WebPackPath.h"
#import "HiDate-Swift.h"
// APP内H5资源包的在bundle中的存放路径
#define H5APPBundlePath [[NSBundle mainBundle] pathForResource:@"hidate" ofType:@"zip"]

// Web更新包下载地址
#define WEBUPDATEREQUEST_PATH_DEV @"http://dt.9hou.me/hidatedev/hidate" // @"http://192.168.90.255/develop/hidate.zip"
#define WEBUPDATEREQUEST_PATH_TEST @"http://dt.9hou.me/hidatetest/hidate" // @"http://10.200.100.138/hi/hidate.zip" @"http://192.168.90.255/test/hidate.zip" //
#define WEBUPDATEREQUEST_PATH_ONLINE @"http://hidate.830clock.com.cn/hidate/hidate"
#define WEBUPDATEREQUEST_PATH PATH_ENVIRONMENT == 0 ? WEBUPDATEREQUEST_PATH_DEV : (PATH_ENVIRONMENT == 1 ? WEBUPDATEREQUEST_PATH_TEST : WEBUPDATEREQUEST_PATH_ONLINE)

// app.json下载地址
#define WEBUPDATEREQUEST_JSONPATH_DEV @"http://dt.9hou.me/hidatedev/config/app.json" //@"http://192.168.90.255/develop/config/app.json" //
#define WEBUPDATEREQUEST_JSONPATH_TEST @"http://dt.9hou.me/hidatetest/config/app.json" // @"http://192.168.90.255/test/config/app.json"// @"http://10.200.100.138/hi/app.json" //
#define WEBUPDATEREQUEST_JSONPATH_ONLINE @"http://hidate.830clock.com.cn/hidate/config/app.json"
#define WEBUPDATEREQUEST_JSONPATH PATH_ENVIRONMENT == 0 ? WEBUPDATEREQUEST_JSONPATH_DEV : (PATH_ENVIRONMENT == 1 ? WEBUPDATEREQUEST_JSONPATH_TEST : WEBUPDATEREQUEST_JSONPATH_ONLINE)


#define NON_UPDATE_VERSION_TAG @"-1"
#define WEB_ORIGINA_VERSION @"3.17.905"

typedef NS_ENUM(NSInteger, RequestResultType) {
    RequestResultTypeChanged = 1,   // 请求结果有新包
    RequestResultTypeNoChange = 2,  // 请求结果无新包
    RequestResultTypeFailed = 0     // 请求失败
};

@interface H5Update ()

@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, assign) NSInteger requestFailCount;
@property (nonatomic, strong) NSString *appVersionValue;
@property (nonatomic, strong) NSString *appjsonLastModify;

@property (nonatomic, strong) NSMutableString *exceptContent;

@end

@implementation H5Update

+ (instancetype)shareUpdate
{
    static H5Update *shareUpdate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        shareUpdate = [[super allocWithZone:NULL] init];
    });
    return shareUpdate;
}

- (AFURLSessionManager *)sessionManager
{
    if (!_sessionManager) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest =
        config.timeoutIntervalForResource = 600;
        config.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    }
    return _sessionManager;
}

+ (NSString *)getNewH5AppSanboxPath
{
    NSString *newH5AppPath = [H5Update newWebpackRelateDirectory];
    NSString *newH5AppSanboxPath = [[H5WebPackPath fileBaseDirectory] stringByAppendingPathComponent:newH5AppPath];
    return newH5AppSanboxPath;
}

/** zip包的存放目录 */
+ (NSString *)h5AppZipDirectory
{
    NSString *zipDirectory = [[H5WebPackPath fileBaseDirectory] stringByAppendingPathComponent:@"H5AppZip"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:zipDirectory]) {
        [fileManager createDirectoryAtPath:zipDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return zipDirectory;
}

/** hidate.zip包的文件路径 */
+ (NSString *)h5AppZipFilePath
{
    return [[H5Update h5AppZipDirectory] stringByAppendingPathComponent:@"hidate.zip"];;
}

/** app.json 的文件路径 */
+ (NSString *)h5VersionJsonFilePath
{
    return [[H5WebPackPath fileBaseDirectory] stringByAppendingPathComponent:@"app.json"];
}

// 新解压的H5APP的相对存放路径
+ (NSString *)newWebpackRelateDirectory
{
    NSString *relateDirectory = [HDUserDefaultTool getH5AppUpdateVersion];
    
    if (!relateDirectory || relateDirectory.length < 1) {
        relateDirectory = WEB_ORIGINA_VERSION;
    }
    
    return relateDirectory;
}

// 已有的H5APP的存放路径
+ (NSString *)nowWebpackAbsoluteDirectory
{
    NSString *H5AppSanboxPath = [HDUserDefaultTool getH5AppSanboxPath];
    HDLog(@"%@", H5AppSanboxPath);
    if (H5AppSanboxPath && H5AppSanboxPath.length > 0) {
        return [[H5WebPackPath fileBaseDirectory] stringByAppendingPathComponent:H5AppSanboxPath];
    } else {
        return nil;
    }
}

// 检查更新
- (void)checkH5AppChange
{
    // TODO:QIDS 清除老版本的WebApp的文件缓存
    // 若首次安装，清空Document和tmp目录
//    NSString *version = [HDUserDefaultTool getH5AppUpdateVersion];
//    if (!version || version.length < 1) {
//        // 清空沙盒目录
//        NSError *err;
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSString *baseDirct = [H5Update baseDirectory];
//        NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:baseDirct error:&err];
//        for (NSString *fileName in fileNames) {
//            [fileManager removeItemAtPath:[baseDirct stringByAppendingPathComponent:fileName] error:&err];
//        }
//    }
    
    self.exceptContent = [NSMutableString string];
    
    // 生产环境，通过head请求比较是否要下载
//    if (PATH_ENVIRONMENT == PATH_ENVIRONMENT_DEV) {
//        self.appVersionValue = WEB_ORIGINA_VERSION;
//        [self getH5AppChangePackage];
//    } else {
    [self checkH5AppChangeWithVersion:^(BOOL checkResult) {
        if (checkResult) {
            // 判断新包版本是否更新
            [self needUpdateWithCompareVersion];
        } else {
            // 无变化，直接去解压
            [self downloadActionComplete:NO];
        }
    }];
//    }
}

// 发起head请求，检查文件是否修改
- (void)checkH5AppChangeWithVersion:(void(^)(BOOL checkResult))callBack;
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?v=%ld", WEBUPDATEREQUEST_JSONPATH, (long)[[NSDate date] timeIntervalSince1970]]]];
    request.timeoutInterval = 15.0f;
    NSString *frontGMTTime = [HDUserDefaultTool getH5AppjsonLastModify];
    if (frontGMTTime && frontGMTTime.length > 0) {
        [request setValue:frontGMTTime forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    // @weakify(self)
    [[self.sessionManager downloadTaskWithRequest:request
                                         progress:nil
                                      destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                          
                                          if (((NSHTTPURLResponse *)response).statusCode == 200) {
                                              // 将JSON文件保存到本地目录
                                              
                                              NSString *filePath = [H5Update h5VersionJsonFilePath];
                                              [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                                              return [NSURL fileURLWithPath:filePath];
                                              
                                          } else {
                                              return nil;
                                          }
                                      } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                          
                                          // @strongify(self)
                                          if (error) {
                                              callBack(NO);
                                          } else {
                                              NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                                              if (statusCode == 200) {
                                                  // 更新app.json的LastModify
                                                  NSDictionary *headers = ((NSHTTPURLResponse *)response).allHeaderFields;
                                                  self.appjsonLastModify = [CommonUtils checkString:headers[@"Last-Modified"]];
                                                  callBack(YES);
                                              } else {
                                                  callBack(NO);
                                              }
                                          }
                                      }] resume];
}

/**
 *  版本号的比较：
 *  app.json文件中的版本号不大于代码中的版本号 || 不大于保存在本地的版本号时，不需要更新包
 *  app.json文件中的版本号大于代码中的版本号 && 大于保存在本地的版本号时，需要更新包
 */
- (void)needUpdateWithCompareVersion
{
    NSData *fileContent = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[H5Update h5VersionJsonFilePath]]];
    if (fileContent) {
        NSDictionary *versionInfo = [NSJSONSerialization JSONObjectWithData:fileContent options:NSJSONReadingMutableContainers error:nil];
        NSString *version = versionInfo[@"version"];
        NSComparisonResult compareResult1 = [self compare:version andNowVersion:WEB_ORIGINA_VERSION];
        // [version compare:WEB_ORIGINA_VERSION];
        NSString *localVersion = [HDUserDefaultTool getH5AppUpdateVersion];
        NSComparisonResult compareResult2 = [self compare:version andNowVersion:localVersion];// [version compare:localVersion];
        
        if (compareResult1 == NSOrderedDescending && compareResult2 == NSOrderedDescending) {
            self.appVersionValue = [NSString stringWithString:version];
            // 下载包变化，去获取新包
            [self getH5AppChangePackage];
        } else {
            // 无变化，直接去解压
            [self downloadActionComplete:NO];
        }
    } else {
        [self downloadActionComplete:NO];
    }
}

// 版本号的比较，升 / 同 / 降
- (NSComparisonResult)compare:(NSString *)newVersion andNowVersion:(NSString *)nowVersion
{
    NSArray *newVersionList = [newVersion componentsSeparatedByString:@"."];
    NSArray *nowVersionList = [nowVersion componentsSeparatedByString:@"."];
    
    NSComparisonResult result = NSOrderedSame;
    
    for (int i = 0 ; i < newVersionList.count ; i ++) {
        
        NSInteger newNum = [newVersionList[i] integerValue];
        NSInteger nowNum = -1;
        if (nowVersionList.count > i) {
            nowNum = [nowVersionList[i] integerValue];
        }
        
        if (newNum > nowNum) {
            result = NSOrderedDescending;
            break;
        } else if (newNum == nowNum) {
            result = NSOrderedSame;
        } else {
            result = NSOrderedAscending;
            break;
        }
    }
    
    return result;
}

// 获取
- (void)getH5AppChangePackage
{
    self.requestFailCount += 1;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:WEBUPDATEREQUEST_PATH]];
    request.timeoutInterval = 15;
    // 设置Http request header
    NSString *GMTTime = [HDUserDefaultTool getH5AppTime];
    if (![GMTTime isEqualToString:NON_UPDATE_VERSION_TAG]) {
        [request setValue:GMTTime forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    //  失败后的重试机制（1次）：是否请求成功，
    __block RequestResultType resultType = RequestResultTypeFailed;
    NSProgress *progress = [NSProgress progressWithTotalUnitCount:10000.0];
    
    @weakify(self)
    [[self.sessionManager downloadTaskWithRequest:request
                                         progress:&progress
                                      destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                          
                                          if (((NSHTTPURLResponse *)response).statusCode == 200) {
                                              // 删除沙盒中的zip文件
                                              BOOL isExist = [H5Update clearSanboxPathZipFile];
                                              if (isExist) {
                                                  // 100%
                                                  if (self.loadProgressBlock) {
                                                      self.loadProgressBlock(100, 100, YES);
                                                  }
                                                  return [NSURL fileURLWithPath:[H5Update h5AppZipFilePath]];
                                              } else {
                                                  return nil;
                                              }
                                          } else {
                                              return nil;
                                          }
                                      } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                          
                                          @strongify(self)
                                          NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                                          
                                          if (statusCode == 304) {
                                              resultType = RequestResultTypeNoChange;
                                          } else if ([filePath.absoluteString hasSuffix:[H5Update h5AppZipFilePath]] && statusCode == 200) {
                                              
                                              // 100%
                                              if (self.loadProgressBlock) {
                                                  self.loadProgressBlock(100, 100, YES);
                                              }
                                              
                                              resultType = RequestResultTypeChanged;
                                              self.requestFailCount = 0;
                                              // 将最后更新时间保存在本地
                                              NSDictionary *headers = ((NSHTTPURLResponse *)response).allHeaderFields;
                                              [HDUserDefaultTool updateH5AppTime:headers[@"Last-Modified"]];
                                              
                                              // 更新版本号
                                              [HDUserDefaultTool updateH5AppjsonLastModify:self.appjsonLastModify];

                                              [HDUserDefaultTool updateH5AppUpdateVersion:self.appVersionValue];
                                              
                                          } else {
                                              resultType = RequestResultTypeFailed;
                                          }
                                          
                                          // 不管是否下载，都去检查本地是否有Zip包
                                          if (resultType == RequestResultTypeChanged) {
                                              [self downloadActionComplete:YES];
                                          } else if (resultType == RequestResultTypeNoChange) {
                                              [self downloadActionComplete:NO];
                                          }  else if (resultType == RequestResultTypeFailed) {
                                              // 重试机制，由重试3次变为重试1次  == 1
                                              if (self.requestFailCount == 1) {
                                                  self.requestFailCount = 0;
                                                  [self downloadActionComplete:NO];
                                              } else {
                                                  // 失败重试
                                                  [self getH5AppChangePackage];
                                              }
                                          }
                                      }] resume];
    
    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.loadProgressBlock) {
        self.loadProgressBlock(((NSProgress *)object).completedUnitCount, ((NSProgress *)object).totalUnitCount, NO);
    }
}

// 检查沙盒路径下是否有zip文件，若有，删除
+ (BOOL)clearSanboxPathZipFile
{
    NSString *zipPath = [H5Update h5AppZipDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError * err = nil;
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:zipPath error:&err];
    if (err) {
        return NO;
    }
    for (NSString *fileName in fileNames) {
        [fileManager removeItemAtPath:[zipPath stringByAppendingPathComponent:fileName] error:&err];
        if (err) {
            return NO;
        }
    }
    return YES;
}

/**
 *  检查完成
 *
 *  @param isDownload下载结果：YES下载成功；NO下载失败或无更新包
 *
 *  @return void
 */
- (void)downloadActionComplete:(BOOL)isDownload
{
    if (isDownload) {
        // 有新的更新包
        if (self. launchType == APPLaunchTypeFirstRun
            || self.launchType == APPLaunchTypeStart) {
            // 启动或者首次启动，检查是否有Zip包，解压等
            // 当解压时报时，二者处理逻辑不同：启动是，load上次的包；首次启动时，解压bundle中的包
            [self unzipH5AppAtSanboxToSanbox];
        }
    } else {
        // 无更新包或下载失败
        if (self.launchType == APPLaunchTypeFirstRun) {
            // 首次启动，将bundle中的Zip解压
            [self unzipH5AppAtBundleToSanbox];
        } else if (self.launchType == APPLaunchTypeStart) {
            // 启动时，检查是否有Zip包
            [self unzipH5AppAtSanboxToSanbox];
        }
    }
}

- (void)unzipH5AppAtBundleToSanbox
{
    // 更新版本号
    NSString *newWebpackRelateDirectory = [H5Update newWebpackRelateDirectory];
    NSString *newWebpackAbsoluDirectory  = [[H5WebPackPath fileBaseDirectory] stringByAppendingPathComponent:newWebpackRelateDirectory];
    NSString *loadPath = @"";
    if ([ZipArchiveTool unzipFileAtPath:H5APPBundlePath toDestination:newWebpackAbsoluDirectory]) {
        [HDUserDefaultTool updateH5AppSanboxPath:newWebpackRelateDirectory];
        loadPath = newWebpackAbsoluDirectory;
    } else {
        // 解压失败，低概率事件，无异常处理
    }
    
    if (self.loadCompleteBlock) {
        self.loadCompleteBlock(loadPath, self.exceptContent);
    }
}

// 启动是，解压沙盒中的压缩包
- (void)unzipH5AppAtSanboxToSanbox
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    NSString *newWebpackRelateDirectory = [H5Update newWebpackRelateDirectory];
    NSString *newWebpackAbsoluDirectory = [[H5WebPackPath fileBaseDirectory] stringByAppendingPathComponent:newWebpackRelateDirectory];
    NSString *nowH5AppPath = [H5Update nowWebpackAbsoluteDirectory];
    NSString *h5AppZipPath = [H5Update h5AppZipFilePath];
    NSString *loadPath = @"";
    
    // 若解压路径下无Zip文件，解压失败
    if ([fileManager fileExistsAtPath:h5AppZipPath]) {
        if ([ZipArchiveTool unzipFileAtPath:h5AppZipPath toDestination:newWebpackAbsoluDirectory]) {
            // 删除老路径，更新H5APP的存放路径
            [HDUserDefaultTool updateH5AppSanboxPath:newWebpackRelateDirectory];

            // 调整：不管环境，当新旧目录一致时，不执行清空目录操作 （废弃：新目录和现有目录一致时，不执行清空老目录操作）
            if (![newWebpackAbsoluDirectory isEqualToString:nowH5AppPath]) {
                [fileManager removeItemAtPath:nowH5AppPath error:nil];
            }
            
            [fileManager removeItemAtPath:h5AppZipPath error:nil];
            loadPath = newWebpackAbsoluDirectory;
        } else {
            // 解压失败，删除整个tmp路径
            if (![newWebpackAbsoluDirectory isEqualToString:nowH5AppPath]) {
                [fileManager removeItemAtPath:newWebpackAbsoluDirectory error:&err];
                
                [self.exceptContent appendString:@"下载的Zip文件解压失败！！！"];
            }
            loadPath = nowH5AppPath;
        }
    } else {
        loadPath = nowH5AppPath;
    }
    
    if (self.loadCompleteBlock) {
        self.loadCompleteBlock(loadPath, self.exceptContent);
    }
}

// 下载出错，重置为首次启动模式
+ (void)resetH5UpdateToFirstRunModel
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *nowH5AppPath = [H5Update nowWebpackAbsoluteDirectory];
    // 清空现有的H5App目录
    [fileManager removeItemAtPath:nowH5AppPath error:nil];
    
    // app.json的last modify置空
    [HDUserDefaultTool updateH5AppjsonLastModify:@""];
    // h5的版本号置为代码中的初始值
    [HDUserDefaultTool updateH5AppUpdateVersion:WEB_ORIGINA_VERSION];
    // h5 app的last modify置空
    [HDUserDefaultTool updateH5AppTime:NON_UPDATE_VERSION_TAG];
    // h5 app的保存在本地的相对路径置空
    [HDUserDefaultTool updateH5AppSanboxPath:@""];
}

#pragma mark -- 代码片段，留存备用
/**
 *  比较2个时间是否接近
 *  @param newGMTTime 最新获取到的GMT格式的时间
 *  @param otherGMTTime 之前保存的GMT格式的时间
 *  @return BOOL时间是否接近，5分钟内为接近YES，否则为NO
 */
- (double)isCloseTimeWithGMTTime:(NSString *)newGMTTime otherGMTTime:(NSString *)otherGMTTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
    formatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss z";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
    NSDate *newDate = [formatter dateFromString:newGMTTime];
    double newTimeInterval = [newDate timeIntervalSince1970];
    
    NSDate *otherDate = [formatter dateFromString:otherGMTTime];
    double otherTimeInterval = [otherDate timeIntervalSince1970];
    
    if (newTimeInterval - otherTimeInterval > 300) {
        return NO;
    }
    
    return YES;
}

// 将Long型时间转为GMT时间，保留
+ (NSString *)converLongDateToGMTTime:(NSString *)longDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE,dd MMM yyyy HH:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[longDate doubleValue]]];
    dateString = [dateString stringByAppendingString:@" GMT"];
    return dateString;
}

@end
