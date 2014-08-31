//
//  MoviePlayerViewController.m
//  FFmpegPlayTest
//
//  Created by Jack on 11/5/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import "MoviePlayerViewController.h"
#import "MoviePlayerController.h"

@implementation MoviePlayerViewController

@synthesize moviePlayer=_moviePlayer;

- (id) initWithContentURL:(NSURL *)contentURL
{
    self = [super init];
    if (self) {
        _moviePlayer = [[MoviePlayerController alloc] initWithContentURL:contentURL];
    }
    return self;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // TODO: Implementaiton
    return YES;
}

@end

@implementation UIViewController (MoviePlayerViewController)

- (void) presentMoviePlayerViewControllerAnimated:(MoviePlayerViewController *)moviePlayerViewController
{
    
}

- (void) dismissMoviePlayerViewControllerAnimated
{
    
}

@end