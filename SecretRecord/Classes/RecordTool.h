//
//  RecordTool.h
//  ChaoXingStudy_inHouse
//
//  Created by DayDayUp on 2019/5/28.
//

#import <Foundation/Foundation.h>
#import "MCAudioInputQueue.h"
#import "AVAudioPlayer+PCM.h"
#import "EncodeAudio.h"
#import "NoteMediaManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecordTool : NSObject

- (void)startRecordWithCompletion:(void(^)(BOOL suc,NSMutableDictionary *attach,NSString *errorMsg))completion; /* 开始录音并回调占位的音频附件 */

- (void)holdRecordCompletion:(void(^)(BOOL suc,NSString *errorMsg))completion; /* 主动暂停录音 */

- (void)continueRecordCompletion:(void(^)(BOOL suc,NSString *errorMsg))completion; /* 重新开始暂停的录音 */

- (void)endRecordCompletion:(void(^)(BOOL suc,NSMutableDictionary *attach,NSString *errorMsg))completion; /* 结束录音 */

@property (nonatomic , copy) void(^interruptRecord)(NSInteger type,NSString *errorMsg); /*暂停录音回调,type暂停类型*/

@property (nonatomic , copy) void(^progressRecord)(NSInteger time); /*回调录音时长*/

@property (nonatomic , copy) void(^recordBackData)(NSData *data); /*回传实时录音的data*/

@property (nonatomic , assign) BOOL changeCatoryByOwn; /*为了避免自己开启录音时，会暂停一次*/

- (BOOL)canRecord;

- (NSInteger)recordStatus; /*获取录音状态  1,//初始状态 2, //录音状态 3,//录音结束 4,//暂停 5 //失败*/

- (void)resetRecord; /*重置录音状态*/

- (float)recordAveragePower; /* 取得第一个通道的音频，音频强度范围是-160到0*/

@end

NS_ASSUME_NONNULL_END
