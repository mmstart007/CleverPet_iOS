//
//  SparkDiscoverDeviceViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/16/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import "SparkDiscoverDeviceViewController.h"
#import "SparkSetupConnection.h"
#import "SparkSetupCommManager.h"
#import "SparkSelectNetworkViewController.h"
#import <Foundation/Foundation.h>
#import "SparkCloud.h"
#import "SparkSetupSecurityManager.h"
#import "SparkSetupUILabel.h"
//#import "UIViewController+SparkSetupCommManager.h"
#import "SparkSetupUIElements.h"
#import "SparkSetupVideoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SparkSetupCustomization.h"
#import "SparkSetupConnection.h"
#import "SparkSetupCommManager.h"
#import "SparkSetupResultViewController.h"

#ifdef ANALYTICS
#import <Mixpanel.h>
#endif

// TODO: Pull this out somewhere for access by the rest of spark setup
#define BLOCK_SELF_REF_OUTSIDE() __weak __typeof(&*self) weakSelf = self;
#define BLOCK_SELF_REF_INSIDE() __typeof(&*self) self = weakSelf;

@interface SparkDiscoverDeviceViewController () <NSStreamDelegate, UIAlertViewDelegate, SparkSelectNetworkViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *wifiSignalImageView;

@property (weak, nonatomic) IBOutlet UILabel *networkNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *troubleShootingButton;
@property (weak, nonatomic) IBOutlet UIImageView *brandImage;
@property (strong, nonatomic) NSArray *scannedWifiList;
@property (weak, nonatomic) IBOutlet UIButton *cancelSetupButton;
@property (weak, nonatomic) IBOutlet SparkSetupUILabel *step3Label;
@property (weak, nonatomic) IBOutlet SparkSetupUIButton *readyButton;



@property (weak, nonatomic) IBOutlet SparkSetupUISpinner *spinner;
@property (weak, nonatomic) IBOutlet SparkSetupUIButton *showMeHowButton;

// new background local notification feature
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, strong) NSTimer *backgroundTaskTimer;

@property (strong, nonatomic) NSTimer *checkConnectionTimer;
@property (atomic, strong) NSString *detectedDeviceID;
@property (atomic) BOOL gotPublicKey;
@property (atomic) BOOL gotOwnershipInfo;
@property (atomic) BOOL didGoToWifiListScreen;
@property (nonatomic) BOOL isDetectedDeviceClaimed;
@property (nonatomic) BOOL needToCheckDeviceClaimed;
@property (nonatomic) BOOL userAlreadyOwnsDevice;
@property (nonatomic) BOOL deviceClaimedByUser;
@property (nonatomic, strong) UIAlertView *changeOwnershipAlertView;
@property (weak, nonatomic) IBOutlet UIView *wifiView;
@property (nonatomic, strong) SparkSetupConnection *tryConn;


@property (weak, nonatomic) IBOutlet UIImageView *connectToWifiImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wifiInfoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@property (nonatomic, strong) NSTimer *stepTimeoutTimer;
@property (nonatomic, assign) BOOL cancelIfRequestIsUnsuccessful;

@end

@implementation SparkDiscoverDeviceViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.didGoToWifiListScreen = NO;
    
    self.backgroundTask = UIBackgroundTaskInvalid;
    self.showMeHowButton.hidden = [SparkSetupCustomization sharedInstance].instructionalVideoFilename ? NO : YES;
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewDidAppear:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // customize logo
    self.brandImage.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImage.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;

    // force load of images from resource bundle
    self.connectToWifiImageView.image = [SparkSetupMainController loadImageFromResourceBundle:@"connect-to-wifi"];
    self.checkmarkImageView.image = [SparkSetupMainController loadImageFromResourceBundle:@"iosCheckmark"];
    self.wifiInfoImageView.image = [SparkSetupMainController loadImageFromResourceBundle:@"iosSettingWifi"];

//    self.wifiSignalImageView.image = [UIImage imageNamed:@"iosSettingsWifi" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
    self.wifiSignalImageView.hidden = NO;
    self.needToCheckDeviceClaimed = NO;
    
    self.gotPublicKey = NO;
    self.gotOwnershipInfo = NO;
    
    self.networkNameLabel.text = [NSString stringWithFormat:@"%@-XXXX",[SparkSetupCustomization sharedInstance].networkNamePrefix];
    self.wifiView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.wifiView.layer.borderWidth = 1.0f;
    
//    self.cancelSetupButton. // customize color too
    self.cancelSetupButton.titleLabel.font = [UIFont fontWithName:[SparkSetupCustomization sharedInstance].headerTextFontName size:self.self.cancelSetupButton.titleLabel.font.pointSize];
    [self.cancelSetupButton setTitleColor:[SparkSetupCustomization sharedInstance].normalTextColor forState:UIControlStateNormal];

    
#ifdef ANALYTICS
    [[Mixpanel sharedInstance] timeEvent:@"Device Setup: Device discovery screen activity"];
#endif


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self killAllTimers];
}

-(void)resetWifiSignalIconWithDelay
{
    // TODO: this is a little bit of a hack
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.wifiSignalImageView.image = [UIImage imageNamed:@"iosSettingsWifi" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
        [self.spinner stopAnimating];
        self.wifiSignalImageView.hidden = NO;
    });
}

-(void)restartDeviceDetectionTimer
{
//    NSLog(@"restartDeviceDetectionTimer called");
    [self.checkConnectionTimer invalidate];
    self.checkConnectionTimer = nil;

    if (!self.didGoToWifiListScreen)
        self.checkConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(checkDeviceWifiConnection:) userInfo:nil repeats:NO];
}

-(void)goToWifiListScreen
{
    if (self.didGoToWifiListScreen == NO)
    {
        self.didGoToWifiListScreen = YES;
        [self performSegueWithIdentifier:@"select_network" sender:self];
    }
}


-(void)willPopBackToDeviceDiscovery
{
    NSLog(@"willPopBackToDeviceDiscovery");
    self.didGoToWifiListScreen = NO;
    [self restartDeviceDetectionTimer];
}

- (IBAction)readyButton:(id)sender
{
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // TODO: solve this via autolayout?


    self.spinner.image = [self.spinner.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.spinner.tintColor = [UIColor blackColor];
    [self scheduleBackgroundTask];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self restartDeviceDetectionTimer];
}

-(void)checkDeviceConnectionForNotification:(NSTimer *)timer
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
//        NSLog(@"checkDeviceConnectionForNotification (background)");

        if ([SparkSetupCommManager checkSparkDeviceWifiConnection:[SparkSetupCustomization sharedInstance].networkNamePrefix])
        {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Connected";
            NSString *notifText = [NSString stringWithFormat:@"Your phone has connected to %@. Tap to continue Setup.",[SparkSetupCustomization sharedInstance].deviceName];
            localNotification.alertBody = notifText;
            localNotification.alertAction = @"open"; // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            localNotification.soundName = UILocalNotificationDefaultSoundName; // play default sound
            localNotification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            [timer invalidate];
        }
    }
}

-(void)scheduleBackgroundTask
{
    [self.backgroundTaskTimer invalidate];
    self.backgroundTaskTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                target:self
                                                              selector:@selector(checkDeviceConnectionForNotification:)
                                                              userInfo:nil
                                                               repeats:YES];
    
    
    BLOCK_SELF_REF_OUTSIDE();
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        BLOCK_SELF_REF_INSIDE();
//        NSLog(@"Background handler called. Not running background tasks anymore.");
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
    
}



-(void)SparkSetupConnection:(SparkSetupConnection *)connection didUpdateState:(SparkSetupConnectionState)state error:(NSError *)error
{
    if (state == SparkSetupConnectionStateOpened)
    {
//        NSLog(@"Photon detected!");
        [connection close];
        [self startPhotonQuery];
    }
}

-(void)startPhotonQuery
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        [self.checkConnectionTimer invalidate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // UI activity indicator
            self.wifiSignalImageView.hidden = YES;
            [self.spinner startAnimating];
        });
        
        // Start connection command chain process with a small delay
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getDeviceID];
        });
        
    }

}


-(void)checkDeviceWifiConnection:(id)sender
{
    //    printf("Detect device timer\n");
    
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateActive)
    {
        //        NSLog(@"SparkDiscover -> checkDeviceWifiConnection timer");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([SparkSetupCommManager checkSparkDeviceWifiConnection:[SparkSetupCustomization sharedInstance].networkNamePrefix])
            {
                [self startPhotonQuery];
            }
        });
    }
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"select_network"])
    {
#ifdef ANALYTICS
        [[Mixpanel sharedInstance] track:@"Device Setup: Device discovery screen activity"];
#endif

        [self.checkConnectionTimer invalidate];
        // Get reference to the destination view controller
        SparkSelectNetworkViewController *vc = [segue destinationViewController];
        [vc setWifiList:self.scannedWifiList];
        vc.deviceID = self.detectedDeviceID;
        vc.delegate = self;
        vc.needToClaimDevice = self.needToCheckDeviceClaimed;
    }
    else if ([segue.identifier isEqualToString:@"video"])
    {
        SparkSetupVideoViewController *vc = segue.destinationViewController;
        vc.videoFilePath = [SparkSetupCustomization sharedInstance].instructionalVideoFilename;
    } else if ([segue.identifier isEqualToString:@"done"]) {
        SparkSetupResultViewController *resultVC = segue.destinationViewController;
        resultVC.setupResult = SparkSetupResultFailureConfigure;
    }
    
}


-(void)getDeviceID
{
    if (!self.detectedDeviceID)
    {
        NSLog(@"DeviceID sent");
        [self startStepTimeoutTimer];
        SparkSetupCommManager *manager = [[SparkSetupCommManager alloc] init];
        [self.checkConnectionTimer invalidate];
        BLOCK_SELF_REF_OUTSIDE();
        [manager deviceID:^(id deviceResponseDict, NSError *error)
         {
             BLOCK_SELF_REF_INSIDE();
             if (error)
             {
                 NSLog(@"Could not send device-id command: %@", error.localizedDescription);
                 if (self.cancelIfRequestIsUnsuccessful) {
                     [self cancelSetup];
                 } else {
                     [self restartDeviceDetectionTimer];
                     [self resetWifiSignalIconWithDelay];
                 }
             }
             else
             {

                 self.detectedDeviceID = (NSString *)deviceResponseDict[@"id"]; //TODO: fix that dict interpretation is done in comm manager (layer completion)
                 self.detectedDeviceID = [self.detectedDeviceID lowercaseString];
                 self.isDetectedDeviceClaimed = [deviceResponseDict[@"c"] boolValue];
                 NSLog(@"DeviceID response received: %@",self.detectedDeviceID );
                 [self stopStepTimeoutTimer];
                 [self photonPublicKey];
//                 NSLog(@"Got device ID: %@",deviceResponseDict);
             }
         }];
    }
    else
    {
//        NSLog(@"getDeviceID called again");
        [self photonPublicKey];
    }
}




-(void)photonScanAP
{
    if (!self.scannedWifiList)
    {
        SparkSetupCommManager *manager = [[SparkSetupCommManager alloc] init];
        [self startStepTimeoutTimer];
        NSLog(@"ScanAP sent");
        BLOCK_SELF_REF_OUTSIDE();
        [manager scanAP:^(id scanResponse, NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            if (error)
            {
                NSLog(@"Could not send scan-ap command: %@",error.localizedDescription);
                if (self.cancelIfRequestIsUnsuccessful) {
                    [self cancelSetup];
                } else {
                    [self restartDeviceDetectionTimer]; // TODO: better error handling
                    [self resetWifiSignalIconWithDelay];
                }
            }
            else
            {
                if (scanResponse)
                {
                    NSLog(@"ScanAP response received");
                    self.scannedWifiList = scanResponse;
//                    NSLog(@"Scan data:\n%@",self.scannedWifiList);
                    [self stopStepTimeoutTimer];
                    [self checkDeviceOwnershipChange];
                    
                }
                
            }
        }];
    }
    else
    {
        [self checkDeviceOwnershipChange];
    }
    
}


-(void)checkDeviceOwnershipChange
{
    if (!self.gotOwnershipInfo)
    {
        [self.checkConnectionTimer invalidate];
        self.needToCheckDeviceClaimed = NO;
        
//        self.isDetectedDeviceClaimed = YES; // DEBUG
        if (!self.isDetectedDeviceClaimed) // device was never claimed before - so we need to claim it anyways
        {
            self.needToCheckDeviceClaimed = YES;
            [self setDeviceClaimCode];
        }
        else
        {
            self.deviceClaimedByUser = NO;
            
            for (NSString *claimedDeviceID in self.claimedDevices)
            {
                if ([claimedDeviceID isEqualToString:self.detectedDeviceID])
                {
                    self.deviceClaimedByUser = YES;
                }
            }
            
            // if the user already owns the device it does not need to be set with a claim code but claiming check should be performed as last stage of setup process
            if (self.deviceClaimedByUser)
                self.needToCheckDeviceClaimed = YES;
            
            self.gotOwnershipInfo = YES;
            
            if ((self.isDetectedDeviceClaimed == YES) && (self.deviceClaimedByUser == NO))
            {
                if (!self.didGoToWifiListScreen)
                {

                    if ([SparkCloud sharedInstance].isLoggedIn)
                    {
                        // that means device is claimed by somebody else - we want to check that with user (and set claimcode if user wants to change ownership)
                        NSString *messageStr = [NSString stringWithFormat:@"This %@ is has been setup before, do you want to override ownership to %@?",[SparkSetupCustomization sharedInstance].deviceName,[SparkCloud sharedInstance].loggedInUsername];
                        self.changeOwnershipAlertView = [[UIAlertView alloc] initWithTitle:@"Product ownership" message:messageStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No",nil];
                        [self.checkConnectionTimer invalidate];
                        [self.changeOwnershipAlertView show];
                    }
                    else // user skipped authentication so no need to claim or set claim code
                    {
                        self.needToCheckDeviceClaimed = NO;
                        [self goToWifiListScreen];

                    }
                }
            }
            else
            {
                // no need to set claim code because the device is owned by current user
                [self goToWifiListScreen];
            }
            
        }
        
        // all cases:
//        (1) device not claimed c=0 — device should also not be in list from API => mobile app assumes user is claiming and sets device claimCode + check its claimed at last stage
//        (2) device claimed c=1 and already in list from API => mobile app does not ask user about taking ownership because device already belongs to this user, does NOT set claimCode to device (no need) but does check ownership in last setup step
//        (3) device claimed c=1 and NOT in the list from the API => mobile app asks whether user would like to take ownership. YES: set claimCode and check ownership in last step, NO: doesn't set claimCode, doesn't check ownership in last step
    }
    else
    {
        if (self.needToCheckDeviceClaimed)
        {
            if (!self.deviceClaimedByUser)
                [self setDeviceClaimCode];
        }
        else
            [self goToWifiListScreen];
        
    }
    
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.changeOwnershipAlertView)
    {
        NSLog(@"button index %ld",(long)buttonIndex);
        if (buttonIndex == 0) //YES
        {
            self.needToCheckDeviceClaimed = YES;
            [self setDeviceClaimCode];
        }
        else
        {
            self.needToCheckDeviceClaimed = NO;
            [self goToWifiListScreen];
        }
    }
}




-(void)photonPublicKey
{
    if (!self.gotPublicKey)
    {
        NSLog(@"PublicKey sent");
        SparkSetupCommManager *manager = [[SparkSetupCommManager alloc] init];
        [self.checkConnectionTimer invalidate];
        [self startStepTimeoutTimer];
        BLOCK_SELF_REF_OUTSIDE();
        [manager publicKey:^(id responseCode, NSError *error) {
            BLOCK_SELF_REF_INSIDE();
            if (error)
            {
                NSLog(@"Error sending public-key command to target: %@",error.localizedDescription);
                if (self.cancelIfRequestIsUnsuccessful) {
                    [self cancelSetup];
                } else {
                    [self restartDeviceDetectionTimer]; // TODO: better error handling
                    [self resetWifiSignalIconWithDelay];
                }
                
            }
            else
            {
                NSInteger code = [responseCode integerValue];
                if (code != 0)
                {
                    NSLog(@"Public key retrival error");
                    if (self.cancelIfRequestIsUnsuccessful) {
                        [self cancelSetup];
                    } else {
                        [self restartDeviceDetectionTimer]; // TODO: better error handling
                        [self resetWifiSignalIconWithDelay];
                    }
                    
                }
                else
                {
                    NSLog(@"PublicKey response received");
                    self.gotPublicKey = YES;
                    [self stopStepTimeoutTimer];
                    [self photonScanAP];
                }
            }
        }];
    }
    else
    {
        [self photonScanAP];
    }
}




-(void)setDeviceClaimCode
{
    SparkSetupCommManager *manager = [[SparkSetupCommManager alloc] init];
    [self.checkConnectionTimer invalidate];
    [self startStepTimeoutTimer];
    NSLog(@"Claim code - trying to set");
    BLOCK_SELF_REF_OUTSIDE();
    [manager setClaimCode:self.claimCode completion:^(id responseCode, NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        if (error)
        {
            NSLog(@"Could not send set command: %@", error.localizedDescription);
            if (self.cancelIfRequestIsUnsuccessful) {
                [self cancelSetup];
            } else {
                [self restartDeviceDetectionTimer];
            }
        }
        else
        {
            NSLog(@"Device claim code set successfully: %@",self.claimCode);
            // finished - segue
            [self stopStepTimeoutTimer];
            [self goToWifiListScreen];

        }
    }];
    
}




-(void)getDeviceVersion
{
    SparkSetupCommManager *manager = [[SparkSetupCommManager alloc] init];
    [self.checkConnectionTimer invalidate];
    BLOCK_SELF_REF_OUTSIDE();
    [manager version:^(id version, NSError *error) {
        BLOCK_SELF_REF_INSIDE();
        if (error)
        {
            NSLog(@"Could not send version command: %@",error.localizedDescription);
        }
        else
        {
            NSString *versionStr = version;
            NSLog(@"Device version:\n%@",versionStr);
        }
    }];
}



- (IBAction)cancelButtonTouched:(id)sender
{
    // finish gracefully
    [self killAllTimers];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSparkSetupDidFinishNotification object:nil userInfo:@{kSparkSetupDidFinishStateKey:@(SparkSetupMainControllerResultUserCancel)}];
    
    
}

- (void)startStepTimeoutTimer
{
    if (!self.stepTimeoutTimer) {
        self.stepTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(stepTimedOut) userInfo:nil repeats:NO];
    }
}

- (void)stopStepTimeoutTimer
{
    self.cancelIfRequestIsUnsuccessful = NO;
    [self.stepTimeoutTimer invalidate];
    self.stepTimeoutTimer = nil;
}

- (void)stepTimedOut
{
    self.stepTimeoutTimer = nil;
    self.cancelIfRequestIsUnsuccessful = YES;
}

- (void)cancelSetup
{
    [self killAllTimers];
    [self performSegueWithIdentifier:@"done" sender:nil];
}

- (void)killAllTimers
{
    [self stopStepTimeoutTimer];
    [self.checkConnectionTimer invalidate];
    self.checkConnectionTimer = nil;
    [self.backgroundTaskTimer invalidate];
    self.backgroundTaskTimer = nil;
    if (self.backgroundTask && self.backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

@end
