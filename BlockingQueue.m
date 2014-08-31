//
//  BlockingQueue.m
//  FFmpegPlayTest
//
//  Created by Jack on 11/13/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import "BlockingQueue.h"



@implementation BlockingQueue

- (int) size
{
    return [self count];
}
- (int) capacity
{
    return arrayCapacity;
}
- (id) get
{
    return  [self firstObject];
}

- (void) put: (id) object{}
- (void) flush{}
@end
