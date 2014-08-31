//
//  BlockingQueue.h
//  FFmpegPlayTest
//
//  Created by Jack on 11/13/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHDataStructures.h"

@interface BlockingQueue : CHCircularBuffer
- (int) size;
- (int) capacity;
- (id) get;
- (void) put:(id)object;
- (void) flush;
@end
