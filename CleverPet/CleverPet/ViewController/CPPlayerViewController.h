//
//  CPPlayerViewController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-03-08.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <AVKit/AVKit.h>

@interface CPPlayerViewController : UIViewController

- (void)playVideoWithUrl:(NSURL*)videoUrl;
- (void)dismissVideo;
- (AVPlayer*)player;

@end
