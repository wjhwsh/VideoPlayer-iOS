//
//  RendererProtocol.h
//  FFmpegPlayTest
//
//  Created by Jack on 11/5/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGLDrawable.h>
#import "VideoScreen.h"
enum {
    kRendererRotate0,
    kRendererRotate90,
    kRendererRotate180,
    kRendererRotate270,
    kRendererRotateDefault = kRendererRotate0
};
typedef NSInteger RendererRotate;

enum {
    kRendererScaleModeNon,
    kRendererScaleModeScale,
    kRendererScaleModeAspectFit,
    kRendererScaleModeAspectFill,
    kRendererScaleModeDefault = kRendererScaleModeAspectFit
};
typedef NSInteger RendererScaleMode;

//-----------------------------------------------------------------------------
@protocol Renderer;
#pragma mark - RendererDelegate
@protocol RendererDelegate <NSObject>
@required
- (void) finishFrameByRenderer: (id<Renderer>) renderer;
@optional
@end

//-----------------------------------------------------------------------------
#pragma mark - Renderer Protocol
@protocol Renderer <NSObject>
@required
@property (nonatomic, assign) id<RendererDelegate> delegate;
@property (nonatomic, assign) id<VideoScreen> videoScreen;
@property (nonatomic, assign) id<VideoScreenSource> videoSource;
- (void) render: (VideoPicture*) picture;
- (BOOL) prepareTexture;
- (BOOL) prepareTextureForVideoForSource: (id<VideoScreenSource>) videoSource
                                  screen: (id<VideoScreen>) viewScreen;

@optional
// ....
@end
