//
//  Video.h
//  FFmpegPlayTest
//
//  Created by Jack on 11/12/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFmpeg.h"

typedef NSInteger VIdeoStatus;

@interface Video : NSObject
{
@private
    NSString*           _fileUrl;
    AVFormatContext*    _formatContext;
    
    // Video Stream Variables
    NSInteger       _videoStreamIndex;
    AVStream*       _videoStream;
    AVCodecContext* _videoCodecCtx;
    
    //Audio Stream Variables    
    NSInteger       _audioStreamIndex;
    AVStream*       _audioStream;
    AVCodecContext* _audioCodecCtx;
    
}

@property (nonatomic, readonly) NSInteger status;
@property (nonatomic,readonly) NSInteger videoStreamIndex;
@property (nonatomic,readonly) NSInteger audioStreamIndex;

- (id) initWithUrl: (NSURL *)url
  interuptCallback: (AVIOInterruptCB) callback;
//- (id) initWithUrl: (NSURL*) url;
- (BOOL) openVideoWithCallback: (AVIOInterruptCB) interuptCallback;
- (void) close;

- ( AVFormatContext * const) formatContext;
- ( AVCodecContext  * const) audioCodecContext;
- ( AVCodecContext  * const) videoCodecContext;
- ( AVStream  * const) audioStream;
- ( AVStream  * const) videoStream;

@end
