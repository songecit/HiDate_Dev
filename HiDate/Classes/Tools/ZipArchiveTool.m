//
//  ZipArchiveTool.m
//  WeDate
//
//  Created by HiDate on 16/6/22.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "ZipArchiveTool.h"
#import <ZipZap/ZipZap.h>

@implementation ZipArchiveTool

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)aimDirection
{
    NSError * error;
    ZZArchive* archive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:path] error:&error];
    if (error) {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (ZZArchiveEntry* entry in archive.entries) {
        // Some archives don't have a separate entry for each directory
        // and just include the directory's name in the filename.
        // Make sure that directory exists before writing a file into it.
        
        NSArray * arr = [entry.fileName componentsSeparatedByString:@"/"];
        NSError * err;
        if (arr.count > 1) {
            NSInteger index = [entry.fileName length] - 1 - [[arr lastObject] length];
            NSString * aimPath = [entry.fileName substringToIndex:index];
            [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",aimDirection,aimPath] withIntermediateDirectories:YES attributes:nil error:&err];
            if (err) {
                return NO;
            }
        }
        
        NSData * data = [entry newDataWithError:&err];
        if (err) {
            return NO;
        }
        [data writeToFile:[NSString stringWithFormat:@"%@/%@",aimDirection,entry.fileName] atomically:YES];
    }
    return YES;
}

@end
