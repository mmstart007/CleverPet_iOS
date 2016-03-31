#import "CPPlayerViewController.h"

@interface PresentVideoPlayerViewController : UIViewController

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
    [self.presentingWindow setRootViewController:[[PresentVideoPlayerViewController alloc] init]];
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

#pragma mark - VideoPlayerViewController

@interface CPPlayerViewController ()

@property (strong, nonatomic) UIWindow *presentingWindow;

@end

@implementation CPPlayerViewController

- (instancetype)initWithContentUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.player = [[AVPlayer alloc] initWithURL:url];
    }
    return self;
}

- (void)presentInWindow {
    [self presentInWindowInternal];
    [self.player play];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self dismissInWindowInternal];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
}

- (AVPlayerItem*)playerItem
{
    return [self.player currentItem];
}

@end

#pragma mark - PresentVideoPlayerViewController

@implementation PresentVideoPlayerViewController

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dismissMoviePlayerViewControllerAnimated {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
