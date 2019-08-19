//
//  NoteAudioFloatWindow.h
//  ChaoXingStudy
//
//  Created by apple on 2017/4/25.
//
//

#import <UIKit/UIKit.h>

@protocol FloatingWindowTouchDelegate <NSObject>
//悬浮窗点击事件
- (void)assistiveTocuhs;

- (void)ballClick;

@end

@interface NoteAudioFloatWindow : UIView

@property (nonatomic , assign) CGFloat limitDownHeight;

@property(nonatomic ,assign)BOOL isCannotTouch;

@property(nonatomic ,weak) id<FloatingWindowTouchDelegate> floatDelegate;

- (id)initWithFrame:(CGRect)frame imageName:(NSString*)name;

- (void)show;

- (void)close;

- (void)updateRecordTime:(NSString *)timestring;

- (void)setAudioHold;

- (void)startAnimation;

@end
