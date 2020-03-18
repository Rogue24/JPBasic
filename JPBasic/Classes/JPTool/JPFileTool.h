//
//  JPFileTool.h
//  Infinitee2.0
//
//  Created by guanning on 2017/6/9.
//  Copyright © 2017年 Infinitee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JPDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define JPDocumentFilePath(fileName) [JPDocumentPath stringByAppendingPathComponent:fileName]

#define JPCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
#define JPCacheFilePath(fileName) [JPCachePath stringByAppendingPathComponent:fileName]

#define JPTmpPath NSTemporaryDirectory()
#define JPTmpFilePath(fileName) [JPTmpPath stringByAppendingPathComponent:fileName]

CG_INLINE NSString * JPFileSizeString(long long fileSize) {
    NSString *sizeStr;
    if (fileSize > 1000 * 1000) { // MB
        CGFloat sizeF = fileSize / 1000.0 / 1000.0;
        sizeStr = [NSString stringWithFormat:@"%.1fMB", sizeF];
    } else if (fileSize > 1000) { // KB
        CGFloat sizeF = fileSize / 1000.0;
        sizeStr = [NSString stringWithFormat:@"%.1fKB", sizeF];
    } else if (fileSize > 0) { // B
        sizeStr = [NSString stringWithFormat:@"%lldB", fileSize];
    } else {
        sizeStr = @"0MB";
    }
    return sizeStr;
}

@interface JPFileTool : NSObject

/** 创建文件夹 */
+ (BOOL)createDirectoryAtPath:(NSString *)path;

/** 文件是否存在 */
+ (BOOL)fileExists:(NSString *)filePath;

/** 移动文件 */
+ (BOOL)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;

/** 删除文件 */
+ (BOOL)removeFile:(NSString *)filePath;

/** 手机剩余空间 */
+ (long long)freeDiskSpaceInBytes;

/** 手机总空间 */
+ (long long)totalDiskSpaceInBytes;

/** 文件大小 */
+ (unsigned long long)fileSize:(NSString *)filePath;

+ (void)enumeratorAtPath:(NSString *)path enumeratorBlock:(void(^)(NSString *fileName))enumeratorBlock;

+ (unsigned long long)calculateFolderSize:(NSString *)folderPath;
+ (void)calculateFolderSize:(NSString *)folderPath complete:(void(^)(unsigned long long totalSize))complete;

+ (void)clearFolder:(NSString *)folderPath;
+ (void)clearFolder:(NSString *)folderPath complete:(void(^)(void))complete;

+ (BOOL)archiveWithRootObject:(id)obj filePath:(NSString *)filePath;
+ (id)unarchivedObjectOfClass:(Class)cls filePath:(NSString *)filePath;
+ (id)unarchivedObjectOfClasses:(NSSet<Class> *)clses filePath:(NSString *)filePath;

/**
 * 注册字体
 */
+ (NSString *)registerFontWithFilePath:(NSString *)filePath;

/**
 * 解除字体
 */
+ (void)unRegisterFontWithFilePath:(NSString *)filePath;

@end
