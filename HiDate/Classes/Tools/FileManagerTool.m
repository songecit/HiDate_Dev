//
//  FileManagerTool.m
//  KeepWineHybird
//
//  Created by qidangsong on 16/9/8.
//  Copyright © 2016年 QDS. All rights reserved.
//

#import "FileManagerTool.h"
#import "CommonCrypto/CommonDigest.h"
#import "H5WebPackPath.h"


@implementation FileManagerTool

+ (NSString *)deleteHeadAndTailStr:(NSString *)originString
{
    // 删除字符串首尾的 "/"
    NSString *str0 = originString;
    if ([originString hasPrefix:@"/"]) {
        str0 = [originString substringFromIndex:1];
    }
    NSString *str1 = str0;
    if ([str0 hasSuffix:@"/"]) {
        str1 = [str0 substringToIndex:(str0.length - 1)];
    }
    return str1;
}

+ (NSString *)directoryAbsolutePath:(NSString *)relatePath needCreate:(BOOL)needCreate
{
    // 删除相对路径首尾的 "/"
    relatePath = [self deleteHeadAndTailStr:relatePath];
    
    NSString *absolutePath = [H5WebPackPath fileBaseDirectory];
    if (relatePath && relatePath.length > 0) {
        absolutePath = [absolutePath stringByAppendingPathComponent:relatePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir;
        BOOL exist = [fileManager fileExistsAtPath:absolutePath isDirectory:&isDir];
        
        if (!exist) {
            if (needCreate) {
                NSError *error;
                [fileManager createDirectoryAtPath:absolutePath withIntermediateDirectories:YES attributes:nil error:&error];
                if (error) {
                    absolutePath = nil;
                    HDLog(@"%@", error.description);
                }
            } else {
                // 目录不存在，且不创建时，应该置为nil
                absolutePath = nil;
            }
        } else {
            if (!isDir) {
                HDLog(@"根据目录的相对路径得到绝对路径时：%@", NSLocalizedString(@"LocalFileNameStructConflictTips", @""));
                absolutePath = nil;
            }
        }
    }
    
    return absolutePath;
}

+ (NSString *)fileAbsolutePath:(NSString *)relatePath needCreate:(BOOL)needCreate
{
    // 删除相对路径首尾的 "/"
    relatePath = [self deleteHeadAndTailStr:relatePath];
    
    NSString *absolutePath = nil;
    if (relatePath && relatePath.length > 0) {
        absolutePath = [[H5WebPackPath fileBaseDirectory] stringByAppendingPathComponent:relatePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir;
        BOOL exist = [fileManager fileExistsAtPath:absolutePath isDirectory:&isDir];
        
        if (!exist) {
            if (needCreate) {
                NSArray * arr = [relatePath componentsSeparatedByString:@"/"];
                if (arr.count > 1) {
                    NSInteger index = [relatePath length] - 1 - [[arr lastObject] length];
                    NSString *aimPath = [relatePath substringToIndex:index];
                    NSError *error;
                    [fileManager createDirectoryAtPath:[[H5WebPackPath fileBaseDirectory] stringByAppendingPathComponent:aimPath] withIntermediateDirectories:YES attributes:nil error:&error];
                    if (error) {
                        absolutePath = nil;
                        HDLog(@"%@", error.description);
                    }
                }
            } else {
                // 目录不存在，且不创建时，应该置为nil
                absolutePath = nil;
            }
        } else {
            if (isDir) {
                HDLog(@"根据文件的相对路径得到绝对路径时：%@", NSLocalizedString(@"LocalFileNameStructConflictTips", @""));
                absolutePath = nil;
            }
        }
    }
    
    return absolutePath;
}

+ (BOOL)copyFileAtPath:(NSString *)localPath toPath:(NSString *)targetLocalPath
{
    /**
     *  copy说明
     *  区分copyDirectoryAtPath
     */
    BOOL copyResult = NO;
    
    if ((localPath && localPath.length > 0)
        && (targetLocalPath && targetLocalPath.length > 0)) {
        
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL empty = YES;
        if ([fileManager fileExistsAtPath:targetLocalPath]) {
            empty = [fileManager removeItemAtPath:targetLocalPath error:&error];
        }
        // copy不会覆盖
        if (empty) {
            copyResult = [fileManager copyItemAtPath:localPath toPath:targetLocalPath error:&error];
        }
    }
    
    return copyResult;
}

+ (BOOL)moveFileAtPath:(NSString *)localPath toPath:(NSString *)targetLocalPath
{
    BOOL result = NO;
    if ((localPath && localPath.length > 0)
        && (targetLocalPath && targetLocalPath.length > 0)) {
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL empty = YES;
        if ([fileManager fileExistsAtPath:targetLocalPath]) {
            empty = [fileManager removeItemAtPath:targetLocalPath error:&error];
        }
        
        if (empty) {
            result = [fileManager moveItemAtPath:localPath toPath:targetLocalPath error:&error];
        }
    }
    return result;
}

+ (BOOL)fileExistsAtLocalPath:(NSString *)localPath
{
    BOOL exist = NO;
    if (localPath && localPath.length > 0) {
        exist = [[NSFileManager defaultManager] fileExistsAtPath:localPath];
    }
    return exist;
}

+ (BOOL)removeFileAtPath:(NSString *)localPath
{
    /**
     *  1、若指定文件不存在，删除成功；
     *  2、若路径为空，删除失败。
     */
    BOOL result = YES;
    if (localPath && localPath.length > 0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir;
        BOOL exist = [fileManager fileExistsAtPath:localPath isDirectory:&isDir];
        if (exist) {
            if (isDir) {
                result = NO;
                HDLog(@"删除文件时：%@", NSLocalizedString(@"LocalFileNameStructConflictTips", @""));
            } else {
                NSError *error;
                result = [fileManager removeItemAtPath:localPath error:&error];
                if (error) {
                    HDLog(@"%@", error.description);
                }
            }
        }
    } else {
        result = NO;
    }
    return result;
}

+ (BOOL)writeToFileEndAtPath:(NSString *)localPath andContent:(NSString *)content
{
    BOOL result = NO;
    if ((localPath && localPath.length > 0)
        && (content && content.length > 0)) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir;
        BOOL exist = [fileManager fileExistsAtPath:localPath isDirectory:&isDir];
        BOOL enableFile = NO;
        if (!exist) {
            enableFile = [fileManager createFileAtPath:localPath contents:nil attributes:nil];
        } else {
            enableFile = YES;
            if (isDir) {
                HDLog(@"将内容写入（追加）文件时：%@", NSLocalizedString(@"LocalFileNameStructConflictTips", @""));
                enableFile = NO;
            }
        }
        if (enableFile) {
            NSFileHandle *writeFile = [NSFileHandle fileHandleForWritingAtPath:localPath];
            [writeFile seekToEndOfFile];
            NSData *bufferData = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSData *base64Decoded = [[NSData alloc] initWithBase64EncodedData:bufferData options:NSDataBase64DecodingIgnoreUnknownCharacters];
            [writeFile writeData:base64Decoded];
            result = YES;
        }
    }
    return result;
}

+ (NSDictionary *)readFileContentAtPath:(NSString *)localPath
{
    BOOL result = NO;           // 是否读取成功
    NSString *content = @"";    // 本地文件内容
    
    if (localPath && localPath.length > 0) {
        NSError *error;
        
        NSData *fileData = [NSData dataWithContentsOfFile:localPath options:NSDataReadingMappedIfSafe error:&error];
        NSData *base64Encoded = [fileData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSString *fileContent = [[NSString alloc] initWithData:base64Encoded encoding:NSUTF8StringEncoding];
        if (error) {
            result = NO;
        } else {
            result = YES;
            content = fileContent;
        }
    }
    
    NSDictionary *resultInfo = result ? @{@"result":[NSNumber numberWithBool:result],
                                          @"content":content} : @{@"result":[NSNumber numberWithBool:result]} ;
    return resultInfo;
}

+ (BOOL)copyDirctoryAtPath:(NSString *)localPath toPath:(NSString *)targetLocalPath
{
    /**
     *  copy说明
     *  区分copyFileAtPath
     */
    NSMutableDictionary *copyResultContain = [NSMutableDictionary dictionary];
    if ((localPath && localPath.length > 0)
        && (targetLocalPath && targetLocalPath.length > 0)) {
        
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:localPath error:&error];
        if (!error) {
            for (NSString *name in fileNames) {
                NSString *targetFilePath = [targetLocalPath stringByAppendingPathComponent:name];
                
                BOOL copyResult = NO;
                BOOL isDir;
                BOOL exist = [fileManager fileExistsAtPath:targetFilePath isDirectory:&isDir];
                
                if (exist && isDir) {
                    NSString *localFilePath = [localPath stringByAppendingPathComponent:name];
                    // 递归遍历目录，以拷贝文件
                    copyResult = [self copyDirctoryAtPath:localFilePath toPath:targetFilePath];
                } else {
                    BOOL empty = YES;
                    if (exist) {
                        empty = [fileManager removeItemAtPath:targetFilePath error:&error];
                    }
                    if (empty) {
                        NSString *localFilePath = [localPath stringByAppendingPathComponent:name];
                        // 指定文件名，则拷贝到具体的文件名。不指定文件名，以原文件名
                        copyResult = [fileManager copyItemAtPath:localFilePath toPath:targetFilePath error:&error];
                    }
                }
                
                [copyResultContain setValue:[NSNumber numberWithBool:copyResult] forKey:name];
            }
        }
    }
    
    BOOL result = NO;
    for (NSString *key in [copyResultContain allKeys]) {
        BOOL copyResult = [[copyResultContain objectForKey:key] boolValue];
        result = copyResult;
        if (!copyResult) {
            // 有一个copy出错，则目录copy操作出错
            result = copyResult;
            HDLog(@"复制目录时出错：%@", copyResultContain);
            break;
        }
    }
    
    HDLog(@"文件目录：%@\n 目标目录：%@\n目录复制结果：%@", localPath, targetLocalPath, copyResultContain);
    
    return result;
}

+ (BOOL)moveDirctoryAtPath:(NSString *)localPath toPath:(NSString *)targetLocalPath
{
    NSMutableDictionary *moveResultContain = [NSMutableDictionary dictionary];
    if ((localPath && localPath.length > 0)
        && (targetLocalPath && targetLocalPath.length > 0)) {
        
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:localPath error:&error];
        if (!error) {
            for (NSString *name in fileNames) {
                NSString *targetFilePath = [targetLocalPath stringByAppendingPathComponent:name];
                
                BOOL copyResult = NO;
                BOOL isDir;
                BOOL exist = [fileManager fileExistsAtPath:targetFilePath isDirectory:&isDir];
                
                if (exist && isDir) {
                    NSString *localFilePath = [localPath stringByAppendingPathComponent:name];
                    // 递归遍历目录，以移动文件
                    copyResult = [self moveDirctoryAtPath:localFilePath toPath:targetFilePath];
                } else {
                    BOOL empty = YES;
                    if (exist) {
                        empty = [fileManager removeItemAtPath:targetFilePath error:&error];
                    }
                    if (empty) {
                        NSString *localFilePath = [localPath stringByAppendingPathComponent:name];
                        copyResult = [fileManager moveItemAtPath:localFilePath toPath:targetFilePath error:&error];
                    }
                }
                
                [moveResultContain setValue:[NSNumber numberWithBool:copyResult] forKey:name];
            }
        }
    }
    
    BOOL result = NO;
    for (NSString *key in [moveResultContain allKeys]) {
        BOOL moveResult = [[moveResultContain objectForKey:key] boolValue];
        result = moveResult;
        if (!moveResult) {
            // 有一个move出错，则目录move操作出错
            HDLog(@"移动目录时出错：%@", moveResultContain);
            result = moveResult;
            break;
        }
    }
    
     HDLog(@"文件目录：%@\n 目标目录：%@\n目录移动结果：%@", localPath, targetLocalPath, moveResultContain);
    return result;
}

+ (BOOL)removeDirctoryAtPath:(NSString *)localPath
{
    /**
     *  1、若指定目录不存在，删除成功；
     *  2、若路径为空，删除失败。
     */
    BOOL result = YES;
    if (localPath && localPath.length > 0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir;
        BOOL exist = [fileManager fileExistsAtPath:localPath isDirectory:&isDir];
        if (exist) {
            if (!isDir) {
                result = NO;
                HDLog(@"删除目录时：%@", NSLocalizedString(@"LocalFileNameStructConflictTips", @""));
            } else {
                NSError *error;
                result = [fileManager removeItemAtPath:localPath error:&error];
                if (error) {
                    HDLog(@"%@", error.description);
                }
            }
        }
    } else {
        result = NO;
    }
    return result;
}

@end
