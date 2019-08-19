#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AVAudioPlayer+PCM.h"
#import "CommonRecordBall.h"
#import "dec_if.h"
#import "EncodeAudio.h"
#import "enc_if.h"
#import "if_rom.h"
#import "interf_dec.h"
#import "interf_enc.h"
#import "MCAudioInputQueue.h"
#import "NoteAudioFloatWindow.h"
#import "NoteMediaManager.h"
#import "RecordTool.h"
#import "wavreader.h"
#import "wavwriter.h"

FOUNDATION_EXPORT double SecretRecordVersionNumber;
FOUNDATION_EXPORT const unsigned char SecretRecordVersionString[];

