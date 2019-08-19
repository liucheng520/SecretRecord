//
//  EncodeAudio.h
//  ChaoXingStudy
//
//  Created by DayDayUp on 2018/5/2.
//

#import <Foundation/Foundation.h>
//#include "interf_dec.h"
//#include "interf_enc.h"
#include "enc_if.h"

#define AMR_MAGIC_NUMBER "#!AMR\n"

@interface EncodeAudio : NSObject

/**
 *  amr转wav文件
 *
 *  @param amrData amr数据
 *
 *  @return wav数据
 */
+ (NSData *)convertAmrToWavFile:(NSData *)amrData;

/**
 *  wav转amr文件
 *
 *  @param wavData wav数据
 *
 *  @return amr数据
 */
+ (NSData *)convertWavToAmrFile:(NSData *)wavData;

/**
 *  amr转wav
 *
 *  @param amrData amr数据
 *
 *  @return wav数据
 */
+ (NSData *)convertAmrToWav:(NSData *)amrData;

/**
 *  wav转amr
 *
 *  @param wavData wav数据
 *
 *  @return amr数据
 */
+ (NSData *)convertWavToAmr:(NSData *)wavData;

+ (NSData *)convertWavToAmr:(NSData *)wavData encode:(void *)encode;

@end
