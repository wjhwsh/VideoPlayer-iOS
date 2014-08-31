//
//  ES1Renderer.h
//  FFmpegPlayTest
//
//  Created by Jack on 11/2/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RendererProtocol.h"
#import "Matrix4x4.h"
#import "GLShader.h"

@interface ES1Renderer : NSObject <Renderer>
{
@private
    
    EAGLContext* context;
    GLint backingWidth;
    GLint backingHeight;
    
    GLuint defaultFrameBuffer;
    GLuint colorRenderBuffer;
    GLuint frameTextures[3];
    
    GLuint mTexW, mTexH, mFrameW, mFrameH;
    
    GLfloat maxS, maxT;
    GLfloat *agVert, *agCoord;
    GLuint agCount;

}
@end
