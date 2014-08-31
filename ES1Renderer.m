//
//  ES1Renderer.m
//  FFmpegPlayTest
//
//  Created by Jack on 11/2/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import "ES1Renderer.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#define kGLShaderNameRGB @"rgb_render"
#define kGLShaderNameYUV @"yuv_render"

@implementation ES1Renderer 

- (id) init
{
    self = [super init];
    if (self) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            return nil;
        }
        
        NSLog(@"ES1Renderer created");
        
        glGenFramebuffersOES(1, &defaultFrameBuffer);
        glGenRenderbuffersOES(1, &colorRenderBuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFrameBuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderBuffer);
        
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,
                                     GL_COLOR_ATTACHMENT0_OES,
                                     GL_RENDERBUFFER_OES,
                                     colorRenderBuffer);
    }
    return self;
}

#pragma mark Utilities
- (NSString*) shaderNameOfPixelType: (int) pixelType
{
    
    /// [Jack] test direct render YUV
  return kGLShaderNameYUV;
//    return kGLShaderNameRGB;
    /// TODO: detect appropriate shader base on pixeltype
//    if ( /* it was rgb format*/) {
//        // return RGB
//    }
}


- (void) dealloc
{
    if (defaultFrameBuffer) {
        glDeleteFramebuffers(1, &defaultFrameBuffer);
        defaultFrameBuffer = 0;
    }
    
    if (colorRenderBuffer) {
        glDeleteRenderbuffers(1, &colorRenderBuffer);
        colorRenderBuffer = 0;
    }
    
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    context = nil;
    
    if (agVert){
        free(agVert);
    }
    
    if (agCoord) {
        free(agCoord);
    }
    [super dealloc];
}

//------------------------------------------------------------------------------
- (void) renderRGBPicture: (VideoPicture*) picture
{
    glPixelStorei(GL_UNPACK_ALIGNMENT, 2);
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, frameTextures[0]);
    // OpenGL loads textures lazily so accessing the buffer is deferred until
    // draw; notify the movie player that we're done with the texture after glDrawArrays.
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0,
                    mFrameW, mFrameH,
                    GL_RGB,
                    [_videoSource pixelFormat],
                    [picture pdata]);

}


//------------------------------------------------------------------------------
- (void) renderYUVPicture: (VideoPicture*) picture
{
    // Y data
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,frameTextures[0]);
    glTexSubImage2D(
                    GL_TEXTURE_2D,
                    0,
                    0,
                    0,
                    mFrameW,            // source width
                    mFrameH,            // source height
                    GL_LUMINANCE,
                    GL_UNSIGNED_BYTE,
                    [picture yData]);

    
    // U data
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, frameTextures[1]);
    glTexSubImage2D(
                    GL_TEXTURE_2D,
                    0,
                    0,
                    0,
                    mFrameW / 2,            // source width
                    mFrameH / 2,            // source height
                    GL_LUMINANCE,
                    GL_UNSIGNED_BYTE,
                    [picture uData]);
    
    // V data
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, frameTextures[2]);
    glTexSubImage2D(
                    GL_TEXTURE_2D,
                    0,
                    0,
                    0,
                    mFrameW / 2,            // source width
                    mFrameH / 2,            // source height
                    GL_LUMINANCE,
                    GL_UNSIGNED_BYTE,
                    [picture vData]);
    

}


//------------------------------------------------------------------------------
- (BOOL) setupTextureRGBWidth: (int) texW height: (int) texH
{
    
    /// Create texture
    if(frameTextures[0])
        glDeleteTextures(1, &frameTextures[0]);
    
    glEnable(GL_TEXTURE_2D);
    glGenTextures(1, &frameTextures[0]);
    glBindTexture(GL_TEXTURE_2D, frameTextures[0]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
    
    // Create texture space, the videop pictures will be rendered as subtexture
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, texW, texH, 0, GL_RGB,
                 GL_UNSIGNED_SHORT_5_6_5, NULL);
    return YES;

}

//------------------------------------------------------------------------------
- (BOOL) setupTextureYUVWidth: (int) texW height: (int) texH
{
    
    NSUInteger widths[3] = {texW, texW/2, texW/2};
    NSUInteger heights[3] = {texH, texH/2, texH/2};
    
    for (int i=0; i < 3; ++i) {
        if (frameTextures[i]) glDeleteTextures(1, &frameTextures[i]);
        glGenTextures(1, &frameTextures[i]);
        glBindTexture(GL_TEXTURE_2D, frameTextures[i]);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        // This is necessary for non-power-of-two textures
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_LUMINANCE,
                     widths[i],
                     heights[i],
                     0,
                     GL_LUMINANCE,
                     GL_UNSIGNED_BYTE,
                     NULL);
        
    }
    
    return TRUE;
}


#pragma mark Renderer Protocol

@synthesize delegate = _delegate;
@synthesize videoScreen = _videoScreen;
@synthesize videoSource = _videoSource;


#ifndef next_powerof2
#define next_powerof2(x) \
x--;\
x |= x >> 1;\
x |= x >> 2;\
x |= x >> 4;\
x |= x >> 8;\
x |= x >> 16;\
x++;
#endif // !next_powerof2

- (void) render: (VideoPicture*) picture
{
    // TODO: need to check if render is correctly settup
    [EAGLContext setCurrentContext:context];
    
    glColor4f(0.3f, 0.2f, 0.5f, 1.0f);
    
    [self renderRGBPicture: (VideoPicture*) picture];
    
    glTexCoordPointer(2, GL_FLOAT, 0, agCoord);
    glDrawArrays(GL_TRIANGLES, 0, 6);
  
    if ([_delegate respondsToSelector:@selector(finishFrameByRenderer:)]) {
        [_delegate finishFrameByRenderer:self];
    }
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderBuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}
//---------------------------------------
//---------------------------------------

- (BOOL) prepareTexture
{
    
    if (!_videoSource || !_videoScreen) {
        return FALSE;
    }
    
    
    // Make videoScreen as output
    /// [Jack] This part should be separated from prepareTexture method because we dont need
    /// to re-bind output if only video source changes.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderBuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:[_videoScreen viewPort]];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return FALSE;
    }

    /// TODO: validate video source frame size and video screen frame size
    /// before any calculation (prevent devide-by-zero)
    
    /// TODO: take scaling mode into account for texture calculation
    
    int scalingMode = [_videoScreen scalingMode];
    int pixelType = [_videoSource pixelFormat];
    
    
    int texW, texH, frameW, frameH;
    texW = [_videoSource videoFrameSize].width;
    texH = [_videoSource videoFrameSize].height;
    frameW = texW;
    frameH = texH;

    // Adjust size for texture to be "Power Of Two"
    next_powerof2(texH);
    next_powerof2(texW);
    
    float videoAspect = (float) frameW / (float) frameH;
    float backHeight = backingHeight;
    float backWidth = backingWidth;
    float screenAspect = backWidth / backHeight;
    
    float minX=-1.f, minY=-1.f, maxX=1.f, maxY=1.f;
    float scale;
    
    //This calculate the scaling for AspectFit
    
    if(videoAspect >= screenAspect)
    {
        // Aspect ratio will retain width.
        scale = (float)backWidth / (float) frameW;
        maxY = ((float)frameH * scale) / (float) backHeight ;
        minY = -maxY;
    }
    else
    {
        // Retain height.
        scale = (float) backHeight / (float) frameW;
        maxX = ((float) frameW * scale) / (float) backWidth;
        minX = -maxX;
    }
    
    if(agVert) {
        free(agVert); agVert = 0L;
    }
    if(agCoord)  {
        free(agCoord); agCoord = 0L;
    }

    agVert = calloc(1, sizeof(float)*6);
    agCoord = calloc(1, sizeof(float)*6);
   
    agVert[0] = minX;
    agVert[1] = minY;
    
    agVert[2] = 0.0;
    agVert[3] = minY;
    
    agVert[4] = minX;
    agVert[5] = 0.0;
    
    float s = (float) frameW / (float) texW;
    float t = (float) frameH / (float) texH;
    
    agCoord[0] = s;
    agCoord[1] = 0.f;
    
    agCoord[2] = 0.f;
    agCoord[3] = 0.f;
    
    agCoord[4] = s;
    agCoord[5] = t;
    
    
    mFrameH = frameH;
    mFrameW = frameW;
    mTexH = texH;
    mTexW = texW;
    maxS = s;
    
    [self setupTextureRGBWidth:texW height:texH];

    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }

    return YES;
}
//------------------------------------------------------------------------------
- (BOOL) prepareTextureForVideoForSource: (id<VideoScreenSource>) videoSource
                                  screen: (id<VideoScreen>)viewScreen
{
    [self setVideoSource:videoSource];
    [self setVideoScreen:viewScreen];
    return [self prepareTexture];
}

@end
