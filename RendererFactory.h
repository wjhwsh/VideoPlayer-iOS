//
//  RendererFactory.h
//  FFmpegPlayTest
//
//  Created by Jack on 11/6/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RendererProtocol.h"
#import <QuartzCore/CAEAGLLayer.h>
#import <OpenGLES/EAGLDrawable.h>
#import "VideoScreen.h"

@interface RendererFactory : NSObject
+ (id<Renderer>) createRenderer;

+ (id<Renderer>) createRendererWithDelegate: (id<RendererDelegate>) delegate;

+ (id<Renderer>) createRendererWithDelegate: (id<RendererDelegate>)delegate
                                  videoSource: (id<VideoScreenSource>) source
                                       screen: (id<VideoScreen>) screen;
@end
