//
//  NoteMediaTool.h
//  ChaoXingStudy
//
//  Created by apple on 2017/3/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NoteMediaManager : NSObject

//获取mediacache文件夹（用于存储笔记话题的音视频文件）下的音视频文件大小
+ (long long)getNoteMediaCacheSize;

//删除mediacache文件夹 下的音视频文件
+ (BOOL)clearNoteMediaCache;

+ (long long) fileSizeAtPath2:(NSString*) filePath;

//videoURL:本地视频路径   time：用来控制视频播放的时间点图片截取
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
+ (UIImage *)ct_imageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
+ (NSString *)videoRealPath:(NSString *)origalPath;

@end
