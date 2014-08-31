//
//  Decoder.h
//  FFmpegPlayTest
//
//  Created by Jack on 11/2/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoScreen.h"
#import "AQHandler.h"
#import "Controllable.h"
#import "Decoder.h"
#import "Video.h"
#import "FFMpegEngine.h"
#import "AVPacketQueue.h"
#import "PictureQueue.h"
#import "PlayerAudioBuffer.h"

// TODO: static AVPacket avPacketFlush;

enum {
    DecodeStateUnknown            = 0,
    DecodeStateInited             = 1 << 0,
    DecodeStateStopped            = 1 << 1,
    DecodeStateDecoding           = 1 << 2,
    DecodeStatePaused             = 1 << 3,
    DecodeStateInterrupted        = 1 << 4,
    DecodeStateSeekingForward     = 1 << 5,
    DecodestateSeekingBackward    = 1 << 6
};
typedef NSInteger DecodeState;

enum {
    DecodeMasterClockAudio,
    DecodeMasterClockVideo,
    DecodeMasterClockExternal
};
typedef NSInteger DecodeMasterClock;


enum {
    DecodeAudioModeFFmpeg,
    DecodeAudioModeNative
};
typedef NSInteger DecodeAudioMode;

//----------------------------------------------------------------
@class Decoder;
@protocol DecoderDelegate <NSObject>

@end

#define DecodeMaxAudioBufferSize ((AVCODEC_MAX_AUDIO_FRAME_SIZE * 3) / 2)
//----------------------------------------------------------------
@interface Decoder : NSObject
<VideoScreenSource, AudioQueueSource, Controllable>
{
@private
    /**
     TODO: declare threads objects to manage threads
     including: packet reading, decoding threads (for
     both video and audio).
     */
    BOOL videoOn;
    BOOL audioOn;
    DecodeState   decodeStatus;
    DecodeAudioMode decodeAudioMode;
    Video         *_video;
    NSThread*       demuxThread;
    NSThread*       decodeVideoThread;
    NSThread*       decodeAudioThread;
#pragma mark Connection to display and speaker
    // TODO: declare reference to AudioQueueHande and Dislay
    
    
    double startTime;
    
#pragma mark Video
    
    AVPacketQueue *_videoPktQueue;
    PictureQueue  *_videoPicQueue;
    
    // video pkt pts
    //NSTimeInterval  videoPktPts;
    
    // Context to scale and convert image format
    struct SwsContext *swsContext;
    
    
    // Pixel format for output frame
    int             glPixelFormat;
    int             ffPixelFormat;
    
    // For video clock
    double          videoClock;
    double          videoCurrentPts;
    int64_t         videoCurrentPtsTime; // In micro seconds
    
    /**
     These variables are used to determine when to display the next
     video picture (see Dranger's tutorial 05) since there is no such
     timer like Display Link or Screen timer.
     
     NOTE: Probably will be unused in this version
     */
    double          videoFrameTimer;  // in seconds
    double          videoFrameLastPts;
    double          videoFrameLastDelay;
    
#pragma mark Audio
    AVPacketQueue *_audioPktQueue;
    PlayerAudioBuffer   *_audioBuffer; // Buffer for decoded audio frame
    double          audioClock;
    
    // to hold reference to a pkt read from queue, use in audio decode process
    AVPacket        pktFromQueue;             // to contain packet read from queue
    AVPacket        pktTemp;
    int             audioHWBufferSpec;      // size of audio buffer, defined by sys
    
    uint8_t         audioBuffer[DecodeMaxAudioBufferSize];
    unsigned int    audioBufSize;
    unsigned int    audioBufIndex;
    
    // For Audio synchronization
    double          audioDiffCum;
    double          audioDiffAverageCoef;
    double          audioDiffThreshold;
    int             audioDiffAverageCount;
    
#pragma mark AV Synchronization Variables
    int             avSyncType;
    double          externalClock;
    int64_t         externalClockTime;
    
}


@property (nonatomic)  DecodeMasterClock clockMode;
- (id) initWithContentURL: (NSURL*) url;
@end

//----------------------------------------------------------------
@interface Decoder (VideoProperties)
@property (nonatomic) int mediaSourceType;

- (double) currentPlaybackTime;
- (float) currentPlaybackRate;
- (int) mediaTypes;
- (float) duration;
- (float) playableDuration;
- (CGSize) videoSize; //CGSizeZero if not known/applicable.
- (float) startTime; // return NaN indicates the natural start time
- (float) endTime; // return NaN indicates the natural end time
@end
