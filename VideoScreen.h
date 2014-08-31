//
//  PEAGLView.h
//  FFmpegPlayTest
//
//  Created by Jack on 11/1/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Controllable.h"
#import "TimingProtocols.h"
#import "PictureQueue.h"
//enum {
//    kScreenStateON,
//    kVideoScreenStateOFF,
//    kVideoScreenStateLinked,
//    kVideoScreenStateUnlinked
//};
enum {
    kScreenStateUnknown,   //= 0,
    kScreenStateStopped,   //= 1 << 0,
    kScreenStateRunning,   //= 1 << 2,
    kScreenStatePaused     //= 1 << 3
};
typedef NSInteger VideoScreenState;

@class VideoScreen;
@protocol VideoScreenDelegate <NSObject>
- (void) screenWillShow: (VideoScreen*) screen;
- (void) screenDidShow:(VideoScreen*) screen;
@end


@class VideoScreen;
//---------------------------------------------------------------------
/**
 This protocol define interface a class should comply to feed video to 
 VideoScreen object
 */
@protocol VideoScreenSource <NSObject>
@required
- (CGSize) videoFrameSize;
- (int) pixelFormat;
- (VideoPicture*) getPictureForScreen: (VideoScreen*) screen
                            screenClock: (NSTimeInterval) scrPts;
- (void) finishFrameForScreen: (VideoScreen*) screen;
@optional
@end
#pragma mark -
//---------------------------------------------------------------------
@protocol VideoScreen <NSObject>
@required
- (id<EAGLDrawable>) viewPort;
- (NSInteger) scalingMode;
@end

#pragma mark - VideoScreen 
/**
 Video public interface
 */
@interface VideoScreen : UIView <Controllable, VideoScreen, Clock>
@property (nonatomic)           NSInteger frameInterval;      // default 1
@property (nonatomic, readonly) VideoScreenState state;
@property (nonatomic, readonly) BOOL supportDisplayLink;
@property (nonatomic, assign)     id<VideoScreenSource> source;
@property (nonatomic)   NSInteger scalingMode;
@property (nonatomic, assign) id<VideoScreenDelegate> delegate;

- (id) initWithSource: (id<VideoScreenSource>) source
             delegate: (id<VideoScreenDelegate>) delegate;
- (id) initWithSource: (id<VideoScreenSource>) source
             delegate: (id<VideoScreenDelegate>) delegate
          scalingMode: (NSInteger) scalingMode;

@end
