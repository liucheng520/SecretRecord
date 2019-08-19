//
//  NoteMediaTool.m
//  ChaoXingStudy
//
//  Created by apple on 2017/3/17.
//
//

#import "NoteMediaManager.h"
#import <sys/stat.h>
#import <AVFoundation/AVFoundation.h>

@implementation NoteMediaManager

+ (long long)getNoteMediaCacheSize
{
    NSString *private_document_media = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"private_document/mediaCache"];
    return [self folderSizeAtPath2:private_document_media];
}

// 方法2：循环调用fileSizeAtPath2
+ (long long) folderSizeAtPath2:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        BOOL isDir = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:fileAbsolutePath isDirectory:&isDir];
        if(!isDir)//不是文件夹
        {
            folderSize += [self fileSizeAtPath2:fileAbsolutePath];
        }
    }
    return folderSize;
}

// 方法1：使用unix c函数来实现获取文件大小
+ (long long) fileSizeAtPath2:(NSString*) filePath{
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        return st.st_size;
    }
    return 0;
}

+ (BOOL)clearNoteMediaCache
{
    NSString *private_document_media = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"private_document/mediaCache"];
    
    NSEnumerator *childFilesEnumerator = [[[NSFileManager defaultManager] subpathsAtPath:private_document_media] objectEnumerator];
    NSString* fileName;
    BOOL deleteState = YES;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [private_document_media stringByAppendingPathComponent:fileName];
        BOOL isDir = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:fileAbsolutePath isDirectory:&isDir];
        if(!isDir)//不是文件夹
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:fileAbsolutePath error:&error];
            if (error) {
                deleteState = NO;
            }
        }
    }
    return deleteState;
}

+ (CGFloat)getCacheSizeAtPath:(NSString *)path
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    CGFloat mediaSize = 0.0;
    
    NSError *error;
    NSArray *contentArr = [fileManger contentsOfDirectoryAtPath:path error:&error];
    
    if (!error) {
        
        if (contentArr.count == 0) return mediaSize;//当一个文件夹没文件的时候
        
        for (int i = 0;i < contentArr.count;i++) {
            
            NSString *fullPath = [path stringByAppendingPathComponent:contentArr[i]];
            
            BOOL isFile = NO; // isDir判断是否为文件夹
            
            if ( !([fileManger fileExistsAtPath:fullPath isDirectory:&isFile] && isFile) )
                
            {
                NSDictionary *fileAttributeDic=[fileManger attributesOfItemAtPath:fullPath error:nil];
                mediaSize += fileAttributeDic.fileSize;
                
            }else{
                [self getCacheSizeAtPath:fullPath];
            }
        }
    }
    return mediaSize;
}

+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    CGImageRelease(thumbnailImageRef);
    return thumbnailImage;
}


/**
 *  从图片中按指定的位置大小截取图片的一部分
 *
 *  @param image UIImage image 原始的图片
 *  @param rect  CGRect rect 要截取的区域
 *
 *  @return UIImage
 */
+ (UIImage *)ct_imageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time{
    
    UIImage *logo = [self thumbnailImageForVideo:videoURL atTime:time];
    
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    
    CGFloat x = 0;
    CGFloat y = (logo.size.height - logo.size.width) * 0.5;
    CGRect dianRect = CGRectMake(x, y, logo.size.width, logo.size.width);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [logo CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(newImageRef);
    return newImage;
}

+ (NSString *)videoRealPath:(NSString *)origalPath
{
    NSArray *temp = [origalPath componentsSeparatedByString:@"-_-"];
    return temp.lastObject;
}

@end
