//
//  CPConfigViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-01.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPConfigViewController.h"
#import "CPSplashImageUtils.h"
#import "CPConfigManager.h"

NSTimeInterval const kCPConfigViewControllerMinimumTimeVisible = 2; // 2 seconds

@interface CPConfigViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) NSDate *loadedDate;
@property (nonatomic, strong) NSTimer *dismissTimer;
@property (weak, nonatomic) IBOutlet UIView *fade;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;

@end

@implementation CPConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor appBackgroundColor];
    self.spinner.color = [UIColor appTealColor];
    self.loadedDate = [NSDate date];
    self.messageLabel.font = [UIFont cpLightFontWithSize:15 italic:NO];
    self.messageLabel.textColor = [UIColor appTitleTextColor];
    self.backgroundImage.image = [CPSplashImageUtils getSplashImage];
    self.fade.layer.cornerRadius = 10.f;
    
    self.retryButton.backgroundColor = [UIColor appLightTealColor];
    [self.retryButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
    self.retryButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:0];
    self.retryButton.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.dismissTimer invalidate];
}

- (void)setAnimating:(BOOL)isAnimating
{
    if (isAnimating) {
        [self.spinner startAnimating];
    } else {
        [self.spinner stopAnimating];
    }
    self.messageLabel.hidden = !isAnimating;
    self.fade.hidden = !isAnimating;
    self.retryButton.hidden = YES;
}

- (void)displayErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    [self setAnimating:NO];
    [super displayErrorAlertWithTitle:title andMessage:message];
    self.retryButton.hidden = NO;
}

- (void)dismiss
{
    NSTimeInterval timePresented = [[NSDate date] timeIntervalSinceDate:self.loadedDate];
    
    if (timePresented < kCPConfigViewControllerMinimumTimeVisible) {
        self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:(kCPConfigViewControllerMinimumTimeVisible - timePresented) target:self selector:@selector(performDismiss) userInfo:nil repeats:NO];
    } else {
        [self performDismiss];
    }
}

- (void)performDismiss
{
    self.dismissTimer = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)retryTapped:(id)sender
{
    // Trigger config manager to load config
    [[CPConfigManager sharedInstance] appEnteredForeground];
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
