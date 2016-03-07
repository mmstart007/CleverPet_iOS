//
//  CPConfigViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-03-01.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPConfigViewController.h"

NSTimeInterval const kCPConfigViewControllerMinimumTimeVisible = 5; // 5 seconds

@interface CPConfigViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) NSDate *loadedDate;
@property (nonatomic, strong) NSTimer *dismissTimer;

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
}

- (void)displayErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    [self setAnimating:NO];
    [super displayErrorAlertWithTitle:title andMessage:message];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
