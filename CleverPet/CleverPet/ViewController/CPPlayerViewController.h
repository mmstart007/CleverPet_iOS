//
//  CPPlayerViewController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-08.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <AVKit/AVKit.h>
@import AVFoundation;

@interface PresentVideoPlayerViewController : UIViewController

@end

@interface CPPlayerViewController : AVPlayerViewController

- (instancetype)initWithContentUrl:(NSURL*)url;
- (void)presentInWindow;
- (AVPlayerItem*)playerItem;

@end
