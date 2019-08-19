//
//  MCAudioInputQueue
//  MCAudioQueue
//
//  Created by Chengyin on 15-4-6.
//  Copyright (c) 2015年 Chengyin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class MCAudioInputQueue;
@protocol MCAudioInputQueueDelegate <NSObject>
@required
- (void)inputQueue:(MCAudioInputQueue *)inputQueue inputData:(NSData *)data numberOfPackets:(UInt32)numberOfPackets;
- (void)inputQueue:(MCAudioInputQueue *)inputQueue errorOccur:(NSError *)error;
@end

typedef NS_ENUM(NSInteger,RecordStatus) {
    RecordStatusOrignal = 1,//初始状态
    RecordStatusRecording, //录音状态
    RecordStatusEnd,//录音结束
    RecordStatusHold,//暂停
    RecordStatusFail //失败
};

@interface MCAudioInputQueue : NSObject

@property (nonatomic,weak,readonly) id<MCAudioInputQueueDelegate> delegate;
@property (nonatomic,assign,readonly) BOOL available;
@property (nonatomic,assign,readonly) BOOL isRunning;
@property (nonatomic,assign,readonly) AudioStreamBasicDescription format;
@property (nonatomic,assign,readonly) NSTimeInterval bufferDuration;
@property (nonatomic,assign,readonly) UInt32 bufferSize;
@property (nonatomic,assign) BOOL meteringEnabled;
@property (nonatomic,assign) RecordStatus status;

/**
 *  create input queue
 *
 *  @param format         audio format
 *  @param bufferDuration duration per buffer block
 *  @param delegate       delegate
 *
 *  @return input queue instance
 */
+ (instancetype)inputQueueWithFormat:(AudioStreamBasicDescription)format bufferDuration:(NSTimeInterval)bufferDuration delegate:(id<MCAudioInputQueueDelegate>)delegate;

- (BOOL)start;
- (BOOL)pause;
- (BOOL)stop;
- (BOOL)reset;

- (void)updateMeters; /* call to refresh meter values */
- (float)peakPowerForChannel:(NSUInteger)channelNumber; /* returns peak power in decibels for a given channel */
- (float)averagePowerForChannel:(NSUInteger)channelNumber; /* returns average power in decibels for a given channel */

- (BOOL)setProperty:(AudioQueuePropertyID)propertyID dataSize:(UInt32)dataSize data:(const void *)data error:(NSError **)outError;
- (BOOL)getProperty:(AudioQueuePropertyID)propertyID dataSize:(UInt32 *)dataSize data:(void *)data error:(NSError **)outError;
- (BOOL)getPropertySize:(AudioQueuePropertyID)propertyID dataSize:(UInt32 *)dataSize error:(NSError **)outError;
- (BOOL)setParameter:(AudioQueueParameterID)parameterId value:(AudioQueueParameterValue)value error:(NSError **)outError;
- (BOOL)getParameter:(AudioQueueParameterID)parameterId value:(AudioQueueParameterValue *)value error:(NSError **)outError;
@end
