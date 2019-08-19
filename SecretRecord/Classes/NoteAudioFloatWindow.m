//
//  NoteAudioFloatWindow.m
//  ChaoXingStudy
//
//  Created by apple on 2017/4/25.
//
//

#import "NoteAudioFloatWindow.h"

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface NoteAudioFloatWindow ()<UIWebViewDelegate>

@property (nonatomic , strong) UIImageView *imageView;

@property (nonatomic , strong) UIImageView *iconImageView;

@property (nonatomic ,strong)UILabel *timeLable;

@property (nonatomic ,copy)NSString *imageNameString;

@end

@implementation NoteAudioFloatWindow

- (id)initWithFrame:(CGRect)frame imageName:(NSString *)name
{
    if(self = [super initWithFrame:frame])
    {
        CGRect newFrame = CGRectMake(100, 100, 76, 76);
        self.backgroundColor = [UIColor clearColor];

        _imageView = [[UIImageView alloc]initWithFrame:(CGRect){0, 0,newFrame.size.width, newFrame.size.height}];
        _imageView.image = [UIImage imageNamed:@"n_audio_bg"];
        _imageView.alpha = 1.0;
        self.imageNameString = name;
        [self addSubview:_imageView];
        
        _iconImageView = [[UIImageView alloc]initWithFrame:(CGRect){0, 0,newFrame.size.width, newFrame.size.height}];
        _iconImageView.image = [UIImage imageNamed:@"n_audio_icon_0"];
        _iconImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_iconImageView];
        
        UILabel *timelable = [[UILabel alloc ] initWithFrame:CGRectMake(0, 0, 60, 10)];
        timelable.center = CGPointMake(newFrame.size.width /2, newFrame.size.height / 2 + 15);
        timelable.font = [UIFont systemFontOfSize:12];
        timelable.textColor = [UIColor whiteColor];
        timelable.textAlignment = NSTextAlignmentCenter;
        
        self.timeLable = timelable;
        [self addSubview:timelable];
        
        //添加移动的手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        pan.delaysTouchesBegan = YES;
        [self addGestureRecognizer:pan];
        //添加点击的手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        [self addGestureRecognizer:tap];
        self.hidden = YES;
        
        self.limitDownHeight = kScreenHeight;
        //全局监听键盘的弹出和收起
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)keyboardWillShow:(NSNotification *)note
{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    self.limitDownHeight = kScreenHeight - keyboardBounds.size.height - 38 - 45;
    
    if (self.center.y > kScreenHeight - keyboardBounds.size.height - 38 - 45) {
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        
        self.center = CGPointMake(self.center.x, kScreenHeight - keyboardBounds.size.height - 38 - 45);
        
        // commit animations
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    self.limitDownHeight = kScreenHeight;
}

- (void)startAnimation
{
    if (self.iconImageView.isAnimating) {
        return;
    }
    
     self.iconImageView.image = [UIImage imageNamed:@"n_audio_icon_0"];
    
    //左右imageview添加动画
    NSMutableArray *iconImgs = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 13; i++) {
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"n_audio_icon_%ld",(long)i]];
        CGImageRef cgimg = image.CGImage;
        if (cgimg) {
            [iconImgs addObject:(__bridge UIImage *)cgimg];
        }
    }
    
    //创建CAKeyframeAnimation
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    animation.duration = 0.13 * iconImgs.count;
    
    animation.values = iconImgs;
    animation.repeatCount =INT_MAX;
    animation.removedOnCompletion = NO;
    [self.iconImageView.layer addAnimation:animation forKey:nil];

}

- (void)endAnimation
{
     [self.self.iconImageView.layer removeAllAnimations];
}

- (void)setAudioHold
{
    [self endAnimation];
    self.timeLable.text = NSLocalizedStringFromTable(@"key Click Continue", @"Localization", @"点击继续");
    self.iconImageView.image = [UIImage imageNamed:@"note_audio_hold_s"];
}

#pragma mark--- 开始和结束

- (void)show
{
    [self startAnimation];
    self.hidden = NO;
}

- (void)close {
    [self endAnimation];
    self.hidden = YES;
}

- (void)updateRecordTime:(NSString *)timestring
{
    [self.timeLable setText:timestring];
}

#pragma mark -触摸事件监听
-(void)locationChange:(UIPanGestureRecognizer*)p
{
    if (self.isCannotTouch) {
        return;
    }
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
 
    CGPoint panPoint = [p locationInView:window];
    if (panPoint.y > self.limitDownHeight) {
        panPoint.y = self.limitDownHeight;
    }
    if (panPoint.y < 38) {
        panPoint.y = 38;
    }
    if(p.state == UIGestureRecognizerStateBegan)
    {
        
    }
    else if (p.state == UIGestureRecognizerStateEnded)
    {
        
    }
    if(p.state == UIGestureRecognizerStateChanged)
    {
        self.center = CGPointMake(panPoint.x, panPoint.y);
    }
    else if(p.state == UIGestureRecognizerStateEnded) //当结束移动之后，自动偏移frame
    {
        if(panPoint.x <= kScreenWidth/2)
        {
            if(panPoint.y <= 40+HEIGHT/2 && panPoint.x >= 20+WIDTH/2)
            {
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(panPoint.x, HEIGHT/2+25);
                }];
            }
            else if(panPoint.y >= kScreenHeight-HEIGHT/2-40 && panPoint.x >= 20+WIDTH/2)
            {
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(panPoint.x, kScreenHeight-HEIGHT/2-25);
                }];
            }
            else if (panPoint.x < WIDTH/2+15 && panPoint.y > kScreenHeight-HEIGHT/2)
            {
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(WIDTH/2+25, kScreenHeight-HEIGHT/2-25);
                }];
            }
            else
            {
                CGFloat pointy = panPoint.y < HEIGHT/2 ? HEIGHT/2 :panPoint.y;
                if (pointy <= HEIGHT/2 + 25) {
                    pointy+=25;
                }
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(WIDTH/2+5, pointy);
                }];
            }
        }
        else if(panPoint.x > kScreenWidth/2)
        {
            if(panPoint.y <= 40+HEIGHT/2 && panPoint.x < kScreenWidth-WIDTH/2-20)
            {
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(panPoint.x, HEIGHT/2 + 25);
                }];
            }
            else if(panPoint.y >= kScreenHeight-40-HEIGHT/2 && panPoint.x < kScreenWidth-WIDTH/2-20)
            {
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(panPoint.x, kScreenHeight-HEIGHT/2 - 25);
                }];
            }
            else if (panPoint.x > kScreenWidth-WIDTH/2 - 15 && panPoint.y < HEIGHT/2)
            {
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(kScreenWidth-WIDTH/2 - 25, HEIGHT/2 + 25);
                }];
            }
            else{
                CGFloat pointy = panPoint.y > kScreenHeight-HEIGHT/2 ? kScreenHeight-HEIGHT/2 :panPoint.y;
                if (pointy <= HEIGHT/2 + 25) {
                    pointy+=25;
                }
                [UIView animateWithDuration:0.15f animations:^{
                    self.center = CGPointMake(kScreenWidth-WIDTH/2 - 5, pointy);
                }];
            }
        }
    }
}

- (void)click:(UITapGestureRecognizer*)t
{
    if (self.isCannotTouch) {
        return;
    }
    if ([self.floatDelegate respondsToSelector:@selector(ballClick)]) {
        [self.floatDelegate ballClick];
    }
}

@end
