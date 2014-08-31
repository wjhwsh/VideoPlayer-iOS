//
//  PictureQueue.m
//  FFmpegPlayTest
//
//  Created by Jack on 11/13/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import "PictureQueue.h"



//#########################################################################

#pragma mark - PictureQueue
@implementation PictureQueue
@synthesize size=_size;
//@synthesize capacity=_capacity;
//------------------------------------------------------------------------
- (id) init
{
    self = [super init];
    if (self) {
        _condition = [[NSCondition alloc] init];
        _size = 0;
        _readIndex=0;
        _writeIndex=0;
        _capacity=kVideoPictureQueueSize;
        
//        _capacity = capacity;
//        _pictures = malloc(_capacity* sizeof(VideoPicture));
//        memset(_pictures, 0, _capacity* sizeof(VideoPicture));
    }
    return self;
}
//------------------------------------------------------------------------
- (VideoPicture*) popPictureWithBlockingMode: (BOOL) blocked
{
    NSLog(@"Popping pic");
    VideoPicture* pict = nil;
    [_condition lock];
    for (;;) {
        
        /// TODO: Add decode's status aware code in here
        /// to escape if decode stop (or quit).
        
        if (_size > 0) {
            pict = pictures[_readIndex];
            if (++_readIndex == kVideoPictureQueueSize) {
                _readIndex = 0;
            }
            _size--;
            NSLog(@"Picture popped, size: %d, rIdx: %d, wIdx: %d", _size, _readIndex, _writeIndex);
            [_condition signal];
            break;
        }else if (!blocked){
            NSLog(@"Return as unblocked pop");
            break;
        }else {
            NSLog(@"Wait to pop...");
            [_condition wait];
        }
    }
    [_condition unlock];
    return  pict;
}
//------------------------------------------------------------------------
- (const VideoPicture* const) pictureToReadWithBlock:(BOOL)blocked
{
    NSLog(@"Getting readable pic");
    VideoPicture* retPict = nil;
    [_condition lock];
    for (;;) {
        if (_size > 0) {
            retPict = pictures[_readIndex];
            NSLog(@"Got a readable pic at idx %d", _readIndex);
            break;
        }else if(blocked){
            NSLog(@"Wait for a readable pic avaiable");
            [_condition wait];
        }else{
            retPict = nil;
            NSLog(@"No readable pict");
            break;
        }
    }
    [_condition unlock];
    return retPict;

}
//------------------------------------------------------------------------
- (BOOL) pushPicture: (VideoPicture*) inPicture
        blockingMode: (BOOL) block
{
    NSLog(@"Pushing pic");
    BOOL ret = YES;
    [_condition lock];
    for (;;) {
        /// TODO: Add decode's status aware code in here
        /// to escape if decode stop (or quit).
        
        if (_size < kVideoPictureQueueSize) {
            pictures[_writeIndex] = inPicture;
            if(++_writeIndex == kVideoPictureQueueSize) {
                _writeIndex = 0;
            }
            _size++;
            NSLog(@"Picture pushed, size: %d, rIdx: %d, wIdx: %d", _size, _readIndex, _writeIndex);
            ret = YES;
            [_condition signal];
            break;
        }else if (!block){
            NSLog(@"Return as unblocked push");
            ret = NO;
            break;
        }else{
            NSLog(@"Wait to push...");
            [_condition wait];
        }
    }
    [_condition unlock];
    return ret;
}
//------------------------------------------------------------------------
// TODO: need implement for the case that no reuseable pict available
// in unblocking mode
- (VideoPicture* const ) pictureToWriteWithBlock:(BOOL)blocked
{
    NSLog(@"Getting pic to write");
    VideoPicture* retPict = nil;
    [_condition lock];
    for (;;) {
        if (_size < kVideoPictureQueueSize) {
            retPict = pictures[_writeIndex];
            NSLog(@"Got a writable pic at idx %d", _writeIndex);
            break;
        }else{
            NSLog(@"Wait for a writable pic avaiable");
            [_condition wait];
        }
    }
    [_condition unlock];
    return retPict;
}
//------------------------------------------------------------------------
- (void) flush
{
    [_condition lock];
    _size = 0;
    _readIndex = 0;
    _writeIndex = 0;
    [_condition unlock];
    
    for (int i = 0; i < kVideoPictureQueueSize; i++) {
        pictures[i] = nil;
    }
}

@end
