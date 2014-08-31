//
//  AVPacketQueue.m
//  FFmpegPlayTest
//
//  Created by Jack on 11/12/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//


#import "AVPacketQueue.h"
//-----------------------------------------------------------------
@implementation AVPacketQueue
@synthesize count=_count;
@synthesize dataSize=_dataSize;

- (id) initWithSize:(NSInteger)size
{
    self = [super init];
    if (self) {
        // Init condition
        _condition = [[NSCondition alloc] init];
        _firstPacket = nil;
        _lastPacket = nil;
        
        _count = 0;
        _dataSize = 0;
        _queueSize = size;
    }
    return self;
}

//-----------------------------------------------------------------

- (void) dealloc
{
    [self flush];
    [super dealloc];
}

//-----------------------------------------------------------------
- (int) popPacket: (AVPacket*) outPacket
          blocked: (BOOL) blocked
{
    NSLog(@"Poping packet...");
    AVPacketList *pktList;
    int ret = 0;
    
    [_condition lock];
   
    for(;;) {
        // TODO: Handle quit signal
        /*
         if(global_video_state->quit) {
            ret = -1;
            break;
         }
         //*/
        
        pktList = _firstPacket;
        if (pktList) {
            _firstPacket = pktList->next;
            
            if (!_firstPacket)
                _lastPacket = NULL;
            
            _count--;
            _dataSize -= pktList->pkt.size;
            *outPacket = pktList->pkt;
            av_free(pktList);
            ret = 1;
            [_condition signal];
            break;
        } else if (!blocked) {
            NSLog(@"No pkt popped");
            ret = 0;
            break;
        } else {
            NSLog(@"Waiting to pop packet...");
            [_condition wait];
        }
    }
    [_condition unlock];
    //SDL_UnlockMutex(q->mutex);
    return ret;
}

//-----------------------------------------------------------------
/*
 blocked variable is unused since writing in queue doesnt wait for
 space in queue. See TOTO in header file.
 */
- (int) pushPacket: (AVPacket*) inPacket
          blocked: (BOOL) blocked
{
    NSLog(@"Pushing packet...");

//*
    AVPacketList *pktList;
    // TODO: Handle quit signal and flush pkt
    /*
     if(global_video_state->quit) {
     ret = -1;
     break;
     }
     
    if(pkt != &flush_pkt && av_dup_packet(pkt) < 0) {
       return -1;
    }
    //*/

    int ret = 0;
    [_condition lock];
    for(;;){
        if(_dataSize > _queueSize){
            if (blocked) {
                NSLog(@"Waiting to push packet...");
                [_condition wait];
            }else{
                NSLog(@"No pkt pushed.");
                break;
            }
        
        }else{
            if(av_dup_packet(inPacket) < 0) {
                NSLog(@"Invalid packet");
                ret = -1;
                break;
            }
            
            pktList = av_malloc(sizeof(AVPacketList));
            if (!pktList) {
                NSLog(@"Unable to allocate mem for pkt");
                ret = -1;
                break;
            }
            
            pktList->pkt = *inPacket;
            pktList->next = NULL;
            
            //SDL_LockMutex(q->mutex);
            
            if (!_lastPacket)
                _firstPacket = pktList;
            else
                _lastPacket->next = pktList;
            
            _lastPacket = pktList;
            _count++;
            _dataSize += pktList->pkt.size;
            NSLog(@"Packet is pushed");
            [_condition signal];
            break;
        }
    }
    [_condition unlock];
    
    return ret;
}


//-----------------------------------------------------------------
- (void) flush
{
    AVPacketList *pkt, *pkt1;
    
    //SDL_LockMutex(q->mutex);
    [_condition lock];
    for(pkt = _firstPacket; pkt != NULL; pkt = pkt1) {
        pkt1 = pkt->next;
        av_free_packet(&pkt->pkt);
        av_freep(&pkt);
    }
    _lastPacket = NULL;
    _firstPacket = NULL;
    _count = 0;
    _dataSize = 0;
    
    //SDL_UnlockMutex(q->mutex);
    [_condition unlock];
   
}
@end
