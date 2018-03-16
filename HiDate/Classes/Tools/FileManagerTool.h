//
//  FileManagerTool.h
//  KeepWineHybird
//
//  Created by qidangsong on 16/9/8.
//  Copyright © 2016年 QDS. All rights reserved.
//  文件管理

#import <Foundation/Foundation.h>

@interface FileManagerTool : NSObject

/**
 *  得到目录的绝对路径
 *
 *  @param  relatePath   目录相对路径
 *  @param  needCreate   目录不存在时，是否需要创建目录
 *  @return absolutePath 转换后的绝对路径，当相对路径不存在并设置不创建时为nil
 */
+ (NSString *)directoryAbsolutePath:(NSString *)relatePath needCreate:(BOOL)needCreate;

/**
 *  得到文件的绝对路径
 *
 *  @param  relatePath   文件相对路径
 *  @param  needCreate   文件不存在时，是否需要创建目录
 *  @return absolutePath 转换后的绝对路径，当相对路径不存在并设置不创建时为nil
 */
+ (NSString *)fileAbsolutePath:(NSString *)relatePath needCreate:(BOOL)needCreate;

/**
 *  检查文件是否存在
 *
 *  @param  relatePath   文件本地地址
 *  @return 文件是否存在
 */
+ (BOOL)fileExistsAtLocalPath:(NSString *)localPath;

/**
 *  复制文件(强制覆盖目标文件)
 *
 *  @param  localPath   文件本地地址
 *  @param  targetLocalPath    目标文件本地地址
 *  @return 文件是否存在
 */
+ (BOOL)copyFileAtPath:(NSString *)localPath toPath:(NSString *)targetLocalPath;

/**
 *  移动文件(强制覆盖目标文件)
 *
 *  @param  localPath   文件本地地址
 *  @param  targetLocalPath    目标文件本地地址
 *  @return 是否成功
 */
+ (BOOL)moveFileAtPath:(NSString *)localPath toPath:(NSString *)targetLocalPath;

/**
 *  删除文件
 *
 *  @param  localPath   文件本地地址
 *  @return 是否成功
 */
+ (BOOL)removeFileAtPath:(NSString *)localPath;

/**
 *  写文本文件（追加方式，UTF编码写入，如果文件不存在，自动创建，如果文件地址中的目录不存在，自动创建）
 *
 *  @param  localPath   文件本地地址
 *  @param  content     写入的内容（字符串）
 *  @return 是否成功
 */
+ (BOOL)writeToFileEndAtPath:(NSString *)localPath andContent:(NSString *)content;

/**
 *  读取文本文件（UTF8编码读取）
 *
 *  @param  localPath   文件本地地址
 *  @return {"result":"是否成功", "content":"读取的文本"}
 */
+ (NSDictionary *)readFileContentAtPath:(NSString *)localPath;

/**
 *  复制目录（强制合并）-- 将目录localPath中的内容复制到目录targetLocalPath中
 *
 *  @param  localPath    目录本地地址
 *  @param  targetLocalPath 目标目录地址
 *  @return 是否成功
 */
+ (BOOL)copyDirctoryAtPath:(NSString *)localPath toPath:(NSString *)targetLocalPath;


/**
 *  移动目录（强制合并）-- 将目录localPath中的内容移动到目录targetLocalPath中
 *
 *  @param  localPath    目录本地地址
 *  @param  targetLocalPath 目标目录地址
 *  @return 是否成功
 */
+ (BOOL)moveDirctoryAtPath:(NSString *)localPath toPath:(NSString *)targetLocalPath;

/**
 *  删除目录
 *
 *  @param  localPath   文件本地地址
 *  @return 是否成功
 */
+ (BOOL)removeDirctoryAtPath:(NSString *)localPath;

@end
