//
//  CommonRecordBall.h
//  ChaoXingStudy
//
//  Created by DayDayUp on 2019/6/11.
//

#import <UIKit/UIKit.h>
#import "RecordTool.h"
#import "NoteAudioFloatWindow.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommonRecordBall : UIView

- (void)startRecordCompletion:(void(^)(BOOL suc,NSMutableDictionary *attach,NSString *errorMsg))completion; /*开始录音*/

@property (nonatomic , copy) void(^interruptRecord)(NSInteger type,NSString *errorMsg); /*暂停录音回调,type暂停类型*/

@property (nonatomic , copy) void(^continueRecord)(BOOL suc,NSString *errorMsg); /*重新开始录音*/

@property (nonatomic , strong) NoteAudioFloatWindow *floatWindow; /*录音的悬浮框*/

- (void)endRecordCompletion:(void(^)(BOOL suc,NSMutableDictionary *attach,NSString *errorMsg))completion; /* 结束录音 */

@property (nonatomic , copy) void(^endRecord)(BOOL suc,NSMutableDictionary *attach,NSString *errorMsg); /*重新开始录音*/

@property (nonatomic , assign) BOOL changeCatoryByOwn; /*为了避免自己开启录音时，会暂停一次*/

- (NSString *)getAudioFilePathByFileName:(NSString *)fileName; /*根据文件名获取全路径*/

@end

NS_ASSUME_NONNULL_END
