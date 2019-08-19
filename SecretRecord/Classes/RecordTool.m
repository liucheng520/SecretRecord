//
//  RecordTool.m
//  ChaoXingStudy_inHouse
//
//  Created by DayDayUp on 2019/5/28.
//

#import "RecordTool.h"

@interface RecordTool()<MCAudioInputQueueDelegate>

@property (nonatomic, strong) MCAudioInputQueue *audioRecorder;

@property (nonatomic , assign) AudioStreamBasicDescription format;

@property (nonatomic , strong) NSString *audioPath;

@property (nonatomic , strong) NSString *amrPath;

@property (nonatomic , strong) NSString *audioName;

@property (nonatomic , strong) NSString *amrName;

@property (nonatomic , assign) NSInteger recordTime;

@property (nonatomic , assign) long long createTime;

@property (nonatomic , strong) NSTimer *timer;

@property void *encode;

@end

static const NSTimeInterval bufferDuration = 0.2;

@implementation RecordTool

- (instancetype)init
{
    if (self = [super init]) {
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self selector:@selector(handleNotification:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        
        [notificationCenter addObserver:self selector:@selector(changeNotification:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
        
        //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
        _format.mFormatID = kAudioFormatLinearPCM;
        _format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        _format.mBitsPerChannel = 16;//线性采样位数  8、16、24、32
        _format.mChannelsPerFrame = 1;
        _format.mFramesPerPacket = 1;
        _format.mBytesPerPacket = _format.mBytesPerFrame = (_format.mBitsPerChannel / 8) * _format.mChannelsPerFrame;
        _format.mSampleRate = 16000;
    }
    return self;
}

#pragma mark - 开始录音
- (void)startRecordWithCompletion:(void (^)(BOOL, NSMutableDictionary *, NSString *))completion
{
    if ([self canRecord]) {
        if (self.audioRecorder && self.audioRecorder.isRunning) return;
        
        _encode = E_IF_init();
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
        self.createTime = [[NSDate date] timeIntervalSince1970];
        
        //音频文件名
        NSString *audioName = [timeStr stringByAppendingString:@".wav"];
        _audioName = audioName;
        _amrName = [timeStr stringByAppendingString:@".amr"];
        //doc目录
        
        NSString *private_document = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"private_document/"];
        
        //拼接音频URL
        self.audioPath = [private_document stringByAppendingPathComponent:audioName];
        self.amrPath =  [private_document stringByAppendingPathComponent:[timeStr stringByAppendingString:@".amr"]];
        
        //重置录音时间
        self.recordTime = 0;
        
        //setting 录音时的设置
        NSError *error = nil;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        BOOL activ = [audioSession setActive:YES error:nil];
        
        if (activ) {
            
            self.audioRecorder = [MCAudioInputQueue inputQueueWithFormat:_format bufferDuration:bufferDuration delegate:self];
            self.audioRecorder.meteringEnabled = YES;
            BOOL startRecord = [self.audioRecorder start];
            self.changeCatoryByOwn = YES;
            
            if (startRecord) {
                
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
                [self.timer fire];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:self.amrPath forKey:@"localPath"];
                [dict setValue:@"amr" forKey:@"type"];
                [dict setValue:_amrName forKey:@"fileTitle"];
                [dict setValue:@(self.createTime) forKey:@"createTime"];
                
                if (completion) {
                    completion(YES,dict,nil);
                }
            }else{
                
                if (completion) {
                    completion(NO,nil,@"录音准备失败");
                }
            }
        }else{
            if (completion) {
                completion(NO,nil,error.description);
            }
        }
    }else{
        if (completion) {
            completion(NO,nil,nil);
        }
    }
}

- (void)holdRecordCompletion:(void (^)(BOOL, NSString *))completion
{
    [self.timer invalidate];
    if (self.audioRecorder && self.audioRecorder.isRunning) {
        BOOL suc = [self.audioRecorder pause];
        if (completion) {
            completion(suc,nil);
        }
    }else{
        if (completion) {
            completion(NO,nil);
        }
    }
}

- (void)continueRecordCompletion:(void (^)(BOOL, NSString *))completion
{
    if ([self canRecord]) {
        //录音的准备
        NSError *error;
        BOOL isactiv = [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
        NSError *nsError;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&nsError];
        
        if (isactiv && !nsError) {
            
            BOOL recod = [self.audioRecorder start];
            if (recod) {
               
                self.changeCatoryByOwn = YES;
                if (self.recordTime > 0) {
                    //重新开始的时候，矫正一下时间
                    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.amrPath] options:nil];
                    CMTime audioDuration = audioAsset.duration;
                    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
                    self.recordTime = (NSInteger)floor(audioDurationSeconds);
                }
                
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
                [self.timer fire];

                if (completion) {
                    completion(YES,nil);
                }
                
            }else{
                
                if (completion) {
                    completion(NO,nil);
                }
            }
        }else{
            
            if (completion) {
                completion(NO,nil);
            }
        }
    }else{
        if (completion) {
            completion(NO,nil);
        }
    }
}

- (void)endRecordCompletion:(void (^)(BOOL, NSMutableDictionary *, NSString *))completion
{
    CGFloat recordTime = self.recordTime;
    if (recordTime < 1) {
        recordTime = 1;
    }
    NSMutableDictionary *newAttachment = [NSMutableDictionary dictionary];
    [newAttachment setValue:self.audioName forKey:@"fileTitle"];
    [newAttachment setValue:@(recordTime) forKey:@"voiceLength"];
    [newAttachment setValue:@(self.createTime) forKey:@"createTime"];
    [newAttachment setValue:@"wav" forKey:@"type"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.amrPath]) {
        
        //结束录音
        [self.audioRecorder stop];
        [_timer invalidate];
        _timer = nil;
        
        AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.amrPath] options:nil];
        CMTime audioDuration = audioAsset.duration;
        float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
        if (audioDurationSeconds <= 1.0) {
            audioDurationSeconds = 1.0;
        }
        
        float hSeconds = ceilf(audioDurationSeconds);
        [newAttachment setValue:@(hSeconds) forKey:@"voiceLength"];
        
        [newAttachment setValue:@"amr" forKey:@"type"];
        [newAttachment setValue:self.amrName forKey:@"fileTitle"];
        [newAttachment setValue:@([NoteMediaManager fileSizeAtPath2:self.amrPath]) forKey:@"fileLength"];
        [newAttachment setValue:self.amrPath forKey:@"localPath"];
        [self resetRecord];
        if (completion) {
            completion(YES,newAttachment,nil);
        }
    }else{
        if (self.audioRecorder.status == RecordStatusRecording) {
            [self.audioRecorder pause];
            [_timer invalidate];
        }

        NSString *errorMsg = @"录音结束失败";
        if(self.recordTime <= 1){
            errorMsg = @"录音时间过短！";
        }
        if (completion) {
            completion(NO,nil,errorMsg);
        }
    }
}

- (void)timeChange
{
    self.recordTime++;
    if (self.progressRecord) {
        self.progressRecord(self.recordTime);
    }
}

- (BOOL)canRecord
{
    __block BOOL bCanRecord = NO;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            }
            else {
                bCanRecord = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"无法录音"
                                                message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许学习通访问你的手机麦克风"
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedStringFromTable(@"key Ok1", @"Localization", @"确定")
                                      otherButtonTitles:nil] show];
                });
            }
        }];
    }
    
    return bCanRecord;
}

#pragma mark - inputqueue delegate
- (void)inputQueue:(MCAudioInputQueue *)inputQueue inputData:(NSData *)data numberOfPackets:(UInt32)numberOfPackets
{
    if (data){
        
        //回传录音data
        if (self.recordBackData) {
            self.recordBackData(data);
        }
        
        //1.0 存储pcm data，用于播放，此处保留也是为了避免转amr失败的情况
        NSFileManager *manger = [NSFileManager defaultManager];
        if(![manger fileExistsAtPath:self.audioPath]) //如果不存在
        {
            [data writeToFile:self.audioPath atomically:YES];
        }else{
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.audioPath];
            [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
            [fileHandle writeData:data];
        }
        
        //将pcm data 转换为 amr data ，这里主要用于上传
        NSData *pcmData = [EncodeAudio convertWavToAmr:data encode:_encode];
        
        if(![manger fileExistsAtPath:self.amrPath]) //如果不存在
        {
            NSMutableData * amrData = [[NSMutableData alloc] initWithBytes:"#!AMR-WB\n" length:9];
            [amrData writeToFile:self.amrPath atomically:YES];
        }
        
        NSFileHandle *pcmHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.amrPath];
        [pcmHandle seekToEndOfFile];  //将节点跳到文件的末尾
        [pcmHandle writeData:pcmData];
    }
    
    [inputQueue updateMeters];
}

- (void)inputQueue:(MCAudioInputQueue *)inputQueue errorOccur:(NSError *)error
{
    [self holdRecordCompletion:^(BOOL suc, NSString * _Nonnull errorMsg) {
        
    }];
    
    if (self.interruptRecord) {
        self.interruptRecord(1, error.description);
    }
}

// 接收录制中断事件通知，并处理相关事件
- (void)handleNotification:(NSNotification *)notification
{
    if(self.audioRecorder.status == RecordStatusRecording){
        [self holdRecordCompletion:^(BOOL suc, NSString * _Nonnull errorMsg) {
            
        }];
        if (self.interruptRecord) {
            self.interruptRecord(2, @"录音被中断");
        }
    }
}

- (void)changeNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = (NSDictionary *)notification.userInfo;
    if ([[userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue] == 3) {
        if(self.audioRecorder.status == RecordStatusRecording && !self.changeCatoryByOwn){
            [self holdRecordCompletion:^(BOOL suc, NSString * _Nonnull errorMsg) {
                
            }];
            if (self.interruptRecord) {
                self.interruptRecord(3, @"录音被中断");
            }
        }
    }
    self.changeCatoryByOwn = NO;
}

- (NSInteger)recordStatus
{
    if (self.audioRecorder) {
        return self.audioRecorder.status;
    }else{
        return RecordStatusOrignal;
    }
}

- (void)resetRecord
{
    self.createTime = 0;
    self.recordTime = 0;
    self.audioPath = nil;
    self.amrPath = nil;
    self.audioName = nil;
    self.amrName = nil;
    [_timer invalidate];
    _timer = nil;
    if (self.audioRecorder.status == RecordStatusRecording || self.audioRecorder.status == RecordStatusHold) {
        [self.audioRecorder stop];
    }
}

- (void)dealloc
{
    if(_encode){
        E_IF_exit((void *)_encode);
        _encode = nil;
    }
    if (_timer) {
        [_timer invalidate];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //将category设置为默认方式，否则会影响应用内网页第三方的播放
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
        [audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    });
}

- (float)recordAveragePower
{
    [self.audioRecorder updateMeters];
    //取得第一个通道的音频，音频强度范围是-120到0
    return [self.audioRecorder averagePowerForChannel:0];
}

@end
