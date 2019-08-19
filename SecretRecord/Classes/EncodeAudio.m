//
//  EncodeAudio.m
//  ChaoXingStudy
//
//  Created by DayDayUp on 2018/5/2.
//

#import "EncodeAudio.h"

#define PCM_FRAME_SIZE 640

@implementation EncodeAudio
//void memcopy(void * dest,const void * src, int local, int len)
//{
//    char * c_dest = dest;
//    const char * c_src = src;
//    for (int i = 0; i < len; i ++) {
//        c_dest[i] = c_src[i + local];
//    }
//}

//+ (NSData *)convertAmrToWavFile:(NSData *)amrData
//{
//    NSMutableData * wavData = [[NSMutableData alloc] init];
//
//    char * bytes = (char *)[amrData bytes];
//
//    void * decstate = Decoder_Interface_init();
//    short pcmFrame[PCM_FRAME_SIZE];
//
//    for (int i = 6; i < amrData.length; i += 32) {
//
//        // 不等于 '3c' == 60 代表坏帧
//        if (bytes[i] != 60) {
//            continue;
//        }
//        memset(pcmFrame, 0, sizeof(pcmFrame));
//        char tmpBytes[32] = {0};
//        memcopy(tmpBytes, bytes, i, 32);
//        Decoder_Interface_Decode(decstate, (unsigned char *)tmpBytes, pcmFrame, 0);
//        [wavData appendBytes:pcmFrame length:PCM_FRAME_SIZE];
//    }
//    Decoder_Interface_exit(decstate);
//
//
//    NSMutableData * headerData = [[NSMutableData alloc] init];
//
//    // riff 标识头
//    [headerData appendBytes:"RIFF" length:4];
//
//    // 总长度
//    NSInteger length = wavData.length + 44 - 8;
//    [headerData appendBytes:&length length:4];
//
//    // wavefmt 标识
//    [headerData appendBytes:"WAVEfmt " length:8];
//
//    // 过渡字节
//    length = 20;
//    [headerData appendBytes:&length length:4];
//
//    // 格式类型
//    length = 1;
//    [headerData appendBytes:&length length:2];
//
//    // 声道 1为单声道 2为双声道
//    length = 1;
//    [headerData appendBytes:&length length:2];
//
//    // 采样率
//    length = 8000;
//    [headerData appendBytes:&length length:4];
//
//    // 每秒播放字节数
//    length = 64000;
//    [headerData appendBytes:&length length:4];
//
//    // 数据块的调整数
//    length = 2;
//    [headerData appendBytes:&length length:2];
//
//    // 每样本的数据位数
//    length = 16;
//    [headerData appendBytes:&length length:2];
//
//    // 位置
//    length = 0;
//    [headerData appendBytes:&length length:4];
//
//    // 音频数据开始标识
//    [headerData appendBytes:"data" length:4];
//
//    // 音频数据长度
//    length = wavData.length;
//    [headerData appendBytes:&length length:4];
//
//    // 音频数据
//    [headerData appendData:wavData];
//
//    return headerData;
//
//}
//
//
//+ (NSData *)convertWavToAmrFile:(NSData *)wavData
//{
//    NSMutableData * amrData = [[NSMutableData alloc] initWithBytes:"#!AMR-WB/n" length:9];
//
//    // 取到PCM数据开始位置
//    NSInteger dataLocation = 0, dataLength = 0;
//    for (int i = 0; i < wavData.length; i++) {
//        NSString * str = [[NSString alloc] initWithData:[wavData subdataWithRange:NSMakeRange(i, 4)] encoding:NSUTF8StringEncoding];
//        if ([str isEqualToString:@"data"]) {
//            dataLocation = i + 8;
//            dataLength = wavData.length - dataLocation;
//            break;
//        }
//    }
//
//    void * encode = E_IF_init();
//    unsigned char amrFrame[64];
//    int count = (int)(dataLength / PCM_FRAME_SIZE);
//
//    for (int m = 0; m < count; m ++) {
//        int length = PCM_FRAME_SIZE;
//        memset(amrFrame, 0, sizeof(amrData));
//        length = E_IF_encode(encode, 8, [[wavData subdataWithRange:NSMakeRange(m * PCM_FRAME_SIZE, length)] bytes], amrFrame, 0);
//        [amrData appendBytes:amrFrame length:length];
//    }
//    E_IF_exit((void *)encode);
//
//    return amrData;
//}

//+ (NSData *)convertAmrToWav:(NSData *)amrData
//{
//    NSMutableData * wavData = [[NSMutableData alloc] init];
//
//    char * bytes = (char *)[amrData bytes];
//
//    void * decstate = Decoder_Interface_init();
//    short pcmFrame[PCM_FRAME_SIZE];
//
//    for (int i = 0; i < amrData.length; i += 32) {
//
//        // 不等于 '3c' == 60 代表坏帧
//        if (bytes[i] != 60) {
//            continue;
//        }
//        memset(pcmFrame, 0, sizeof(pcmFrame));
//        char tmpBytes[32] = {0};
//        memcopy(tmpBytes, bytes, i, 32);
//        Decoder_Interface_Decode(decstate, (unsigned char *)tmpBytes, pcmFrame, 0);
//        [wavData appendBytes:pcmFrame length:PCM_FRAME_SIZE];
//    }
//    Decoder_Interface_exit(decstate);
//    return wavData;
//}
//
//+ (NSData *)convertWavToAmr:(NSData *)wavData
//{
//    NSMutableData * amrData = [[NSMutableData alloc] init];
//
//    void * encode = Encoder_Interface_init(0);
//    unsigned char amrFrame[32];
//    int count = (int)(wavData.length / PCM_FRAME_SIZE);
//
//    for (int i = 0; i < count; i ++) {
//        int length = PCM_FRAME_SIZE;
//        memset(amrFrame, 0, sizeof(amrData));
//        length = Encoder_Interface_Encode(encode, MR122,[[wavData subdataWithRange:NSMakeRange(i * PCM_FRAME_SIZE, length)] bytes], amrFrame, 0);
//        [amrData appendBytes:amrFrame length:length];
//    }
//    Encoder_Interface_exit(encode);
//
//    return amrData;
//}


#define PCM_FRAME_SIZE_E 640
+ (NSData *)convertWavToAmr:(NSData *)wavData encode:(void *)encode
{
    NSMutableData * amrData = [[NSMutableData alloc] init];

    unsigned char amrFrame[64];
    int count = (int)(wavData.length / PCM_FRAME_SIZE);
    
    for (int i = 0; i < count; i ++) {
        int length = PCM_FRAME_SIZE;
        memset(amrFrame, 0, sizeof(amrData));
        length = E_IF_encode(encode, 8,[[wavData subdataWithRange:NSMakeRange(i * PCM_FRAME_SIZE, length)] bytes], amrFrame, 0);
        [amrData appendBytes:amrFrame length:length];
    }
    return amrData;
}
@end
