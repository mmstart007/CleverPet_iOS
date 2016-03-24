//
//  CPPlayerViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-08.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPPlayerViewController.h"
@import AVFoundation;

@interface CPVideoPlayerController : AVPlayerViewController

@property (strong, nonatomic) UIWindow *presentingWindow;

- (void)presentInWindow;
- (void)dismissWindow;

@end

@interface CPPlayerViewController ()

@property (nonatomic, strong) CPVideoPlayerController *playerController;

@end

@interface CPPresentVideoViewController : UIViewController

@end

@interface UIViewController (VideoPlayerWindow)

- (void)presentInWindowInternal;
- (void)dismissInWindowInternal;

@property (strong, nonatomic) UIWindow *presentingWindow;

@end

@implementation UIViewController (VideoPlayerWindow)

@dynamic presentingWindow;

- (void)presentInWindowInternal {
    self.presentingWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.presentingWindow setRootViewController:[[CPPresentVideoViewController alloc] init]];
    [self.presentingWindow setTintColor:[UIApplication sharedApplication].delegate.window.tintColor];
    [self.presentingWindow setWindowLevel:([UIApplication sharedApplication].windows.lastObject.windowLevel + 1)];
    [self.presentingWindow makeKeyAndVisible];
    
    [self setModalPresentationStyle:UIModalPresentationFullScreen];
    [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.presentingWindow.rootViewController presentViewController:self animated:YES completion:nil];
}

- (void)dismissInWindowInternal {
    [self.presentingWindow setRootViewController:nil];
    [self.presentingWindow setHidden:YES];
    self.presentingWindow = nil;
}

@end

@implementation CPPlayerViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.playerController = [[CPVideoPlayerController alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
}

- (void)playVideoWithUrl:(NSURL *)videoUrl
{
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoUrl];
    if (self.playerController.player) {
        [self.playerController.player replaceCurrentItemWithPlayerItem:item];
    } else {
        self.playerController.player = [AVPlayer playerWithPlayerItem:item];
    }
    
    [self.playerController presentInWindow];
    [self.playerController.player play];
}

- (void)dismissVideo
{
    [self.playerController dismissWindow];
}

- (AVPlayer*)player
{
    return self.playerController.player;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@implementation CPVideoPlayerController

- (void)presentInWindow {
    [self presentInWindowInternal];
}

- (void)dismissWindow
{
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self dismissInWindowInternal];
}

@end

@implementation CPPresentVideoViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft;
}

- (void)dismissMoviePlayerViewControllerAnimated {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
