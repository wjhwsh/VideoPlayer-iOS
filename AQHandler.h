//
//  AQHandler.h
//  FFmpegPlayTest
//
//  Created by Jack on 11/2/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Controllable.h"
#import "TimingProtocols.h"

enum {
    kAQStateUnknown,   //= 0,
    kAQStateStopped,   //= 1 << 0,
    kAQStateRunning,   //= 1 << 1,
    kAQStatePaused     //= 1 << 2,
};

typedef NSInteger AQState;


static const int kNumberBuffers = 3;
typedef struct  {
    AudioStreamBasicDescription   mDataFormat;
    AudioQueueRef                 mQueue;
    AudioQueueBufferRef           mBuffers[kNumberBuffers];
    //  AudioFileID                   mAudioFile;
    UInt32                        bufferByteSize;
    UInt32                        mNumPacketsToRead;
    SInt64                        mCurrentPacket;
    AudioStreamPacketDescription  *mPacketDescs;
    AQState                     mStatus;
} AQPlayerState;


//----------------------------------------------------------------
@protocol AudioQueueSource <NSObject>

@required
- (BOOL) fillAudioStreamDescription: (AudioStreamBasicDescription*) pASBD;
- (UInt32) maxAudioPacketSize;
- (void) renderAudioBuffer:(AudioQueueBufferRef) aqBuffer
                    forPts:(NSTimeInterval) pts;

@optional

- (int) sampleRate;
@end
//----------------------------------------------------------------

@protocol AQHandlerDelegate <NSObject>

@end

//----------------------------------------------------------------
@interface AQHandler : NSObject <Controllable, Clock>
//@property (nonatomic, readonly) AQPlayerState* pAQdata;
- (AQPlayerState*) audioQueueData;
@property (nonatomic, assign) id<AudioQueueSource> source;
@property (nonatomic, assign) id<AQHandlerDelegate> delegate;
- (id) initWithSource: (id<AudioQueueSource>) source;
@end
