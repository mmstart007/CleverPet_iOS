//
//  CPPlayerViewController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-08.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <AVKit/AVKit.h>
@import AVFoundation;

@protocol CPPlayerViewControllerDelegate <NSObject>
- (void)videoPlayerWillDisappear;
@end

@interface CPPlayerViewController : AVPlayerViewController

@property (weak, nonatomic) id<CPPlayerViewControllerDelegate> cpDelegate;

- (instancetype)initWithContentUrl:(NSURL*)url;
- (void)presentInWindow;
- (AVPlayerItem*)playerItem;

@end
