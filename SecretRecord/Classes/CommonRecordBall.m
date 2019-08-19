//
//  CommonRecordBall.m
//  ChaoXingStudy
//
//  Created by DayDayUp on 2019/6/11.
//

#import "CommonRecordBall.h"

@interface CommonRecordBall()<FloatingWindowTouchDelegate>

@property (nonatomic , strong) RecordTool *recordTool;

@end

@implementation CommonRecordBall

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    _recordTool = [[RecordTool alloc] init];
    
    __weak typeof(self) weakSelf = self;
    _recordTool.progressRecord = ^(NSInteger time) {
        //时间转换
        NSInteger hour,min,second;
        NSString *timeString = nil;
        if (time >= 3600) {
            hour = time / 3600;
            min = (time % 3600) / 60;
            second = time % 60;
            timeString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hour,(long)min,(long)second];
        }else{
            hour = 0;
            min = time/ 60;
            second = time - min * 60;
            timeString = [NSString stringWithFormat:@"%02ld:%02ld",(long)min,(long)second];
        }
        
        [weakSelf.floatWindow updateRecordTime:timeString]; //刷新floatball上面的time
    };
    
    _recordTool.interruptRecord = ^(NSInteger type, NSString * _Nonnull errorMsg) {
        if (weakSelf.interruptRecord) {
            weakSelf.interruptRecord(type, errorMsg);
        }
        [weakSelf.floatWindow setAudioHold];
    };
    
    //floatWindows
    _floatWindow = [[NoteAudioFloatWindow alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 76 - 5, 100, 76, 76) imageName:@"note_audio_float"];
    _floatWindow.floatDelegate = self;
    _floatWindow.hidden = YES;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:_floatWindow];
}

- (void)startRecordCompletion:(void(^)(BOOL suc,NSMutableDictionary *attach,NSString *errorMsg))completion
{
    __weak typeof(self) weakSelf = self;
    [_recordTool startRecordWithCompletion:^(BOOL suc, NSMutableDictionary * _Nonnull attach, NSString * _Nonnull errorMsg) {
        if (suc) {
            [weakSelf showTheRecordBall];
            if (completion) {
                completion(suc,attach,errorMsg);
            }
        }else{
            if (completion) {
                completion(NO,nil,errorMsg);
            }
        }
    }];
}

//显示球
- (void)showTheRecordBall
{
    if (_recordTool.recordStatus == RecordStatusRecording || _recordTool.recordStatus == RecordStatusHold) {
        [_floatWindow show];
    }else{
        [_floatWindow close];
    }
}

//隐藏球
- (void)hiddenTheRecordBall
{
    [_floatWindow close];
}

- (void)setChangeCatoryByOwn:(BOOL)changeCatoryByOwn
{
    _changeCatoryByOwn = changeCatoryByOwn;
    _recordTool.changeCatoryByOwn = _changeCatoryByOwn;
}

//悬浮窗点击事件
- (void)ballClick
{
    if (_recordTool.recordStatus == RecordStatusHold) {
        __weak typeof(self) weakSelf = self;
        [_recordTool continueRecordCompletion:^(BOOL suc, NSString * _Nonnull errorMsg) {
            if (weakSelf.continueRecord) {
                weakSelf.continueRecord(suc, errorMsg);
            }
        }];
        [_floatWindow show];
    }else{
        [_floatWindow close];
        [_recordTool endRecordCompletion:_endRecord];
    }
}

- (void)endRecordCompletion:(void (^)(BOOL, NSMutableDictionary * _Nonnull, NSString * _Nonnull))completion
{
    [_recordTool endRecordCompletion:completion];
}

- (void)assistiveTocuhs
{
    _floatWindow.isCannotTouch = YES;
}

- (NSString *)getAudioFilePathByFileName:(NSString *)fileName
{
    if (fileName.length == 0) return nil;
    
    NSString *private_document = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"private_document/mediaCache/"];
    //拼接音频URL
    return [private_document stringByAppendingPathComponent:fileName];
}

@end
