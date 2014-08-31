//
//  MoviePlayerViewController.h
//  FFmpegPlayTest
//
//  Created by Jack on 11/5/12.
//  Copyright (c) 2012 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MoviePlayerController;
@interface MoviePlayerViewController : NSObject {
@private
    id _internal;
}

- (id) initWithContentURL: (NSURL *) contentURL;

@property(nonatomic, readonly) MoviePlayerController* moviePlayer;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation; // Default is YES.
@end


// -----------------------------------------------------------------------------
// UIViewController Additions
// Additions to present a fullscreen movie player as a modal view controller using the standard movie player transition.

@interface UIViewController (MoviePlayerViewController)

- (void)presentMoviePlayerViewControllerAnimated:(MoviePlayerViewController *)moviePlayerViewController;
- (void)dismissMoviePlayerViewControllerAnimated;

@end