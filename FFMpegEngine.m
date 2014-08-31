//
//  FFMpegEngine.m
//  FFmpegPlayTest
//
//  Created by Jack on 11/14/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import <libkern/OSAtomic.h>
#import <dispatch/dispatch.h>

#import "FFMpegEngine.h"
#import "FFmpeg.h"

@interface FFMpegEngine ()
{
    BOOL _initialized;
}
@end
@implementation FFMpegEngine

static FFMpegEngine* volatile _sharedInstance = nil;

+ (FFMpegEngine*) shareInstance
{
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
 
    static dispatch_once_t __once = 0;
    dispatch_once(&__once, ^{ _sharedInstance = [[FFMpegEngine alloc] init]; });

    #else
    
    if (!_shareInstance) {
            FFMpegEngine *_obj = [[FFMpegEngine alloc] init];
            if(OSAtomicCompareAndSwapPtrBarrier(nil, _obj, (void* volatile*)&_sharedInstance) == false)
         [obj release];
    }
    #endif

    return _sharedInstance;
}

#pragma mark - Class Level Methods
+ (UInt32) bitsForSampleFormat: (int) sampleFormat
{
    switch (sampleFormat) {
        case AV_SAMPLE_FMT_U8:
        case AV_SAMPLE_FMT_U8P:
            return 8;
            break;
        case AV_SAMPLE_FMT_S16:
        case AV_SAMPLE_FMT_S16P:
            return 16;
            break;
        case AV_SAMPLE_FMT_S32:
        case AV_SAMPLE_FMT_S32P:
            return 32;
            break;
        case AV_SAMPLE_FMT_FLT:
        case AV_SAMPLE_FMT_FLTP:
            return sizeof(float);
            break;
        case AV_SAMPLE_FMT_DBL:
        case AV_SAMPLE_FMT_DBLP:
            return sizeof(double);
        default:
            break;
    }
    
    return 0;
};



- (id) init
{
    self = [super init];
    if (self) {
        _initialized = NO;
    }
    return self;
}

- (void) initFFmpegEngine
{
    if (!_initialized) {
        av_register_all();
        avcodec_register_all();
        _initialized = YES;
    }
}

- (BOOL) isInitialized
{
    return _initialized;
}
@end
