//
//  RendererFactory.m
//  FFmpegPlayTest
//
//  Created by Jack on 11/6/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import "RendererFactory.h"
#import "ES1Renderer.h"
#import "ES2Renderer.h"


@implementation RendererFactory


//------------------------------------------------------------------------------
+ (id<Renderer>) createRenderer
{
    id<Renderer> renderer = nil;
    renderer = [[ES2Renderer alloc] init];
    
    if (!renderer) {
        renderer = [[ES1Renderer alloc] init];
    }
    
    return renderer;
}

//------------------------------------------------------------------------------
+ (id<Renderer>) createRendererWithDelegate:(id<RendererDelegate>)delegate
{
    id<Renderer> renderer = [RendererFactory createRenderer];
    [renderer setDelegate:delegate];
    
    return renderer;
}

//------------------------------------------------------------------------------
+ (id<Renderer>) createRendererWithDelegate: (id<RendererDelegate>)delegate
                                  videoSource: (id<VideoScreenSource>) source
                                       screen: (id<VideoScreen>) screen
{
    id<Renderer> renderer = [RendererFactory createRendererWithDelegate:delegate];
    [renderer setVideoScreen:screen];
    [renderer setVideoSource:source];
    return renderer;
}

@end
