//
//  CPPetPhotoViewController.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPPetPhotoViewController.h"
#import "CPLoginController.h"
#import "CPParticleConnectionHelper.h"
#import "BABCropperView.h"
#import "CPLoadingView.h"
#import <Photos/Photos.h>

@interface CPPetPhotoViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIButton *swapImageButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet BABCropperView *cropView;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet CPLoadingView *fadeView;

@end

@implementation CPPetPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Crop at double our view size so the resulting image isn't so garbage
    self.cropView.cropSize = CGSizeMake(self.view.bounds.size.width*2, self.view.bounds.size.width*.75*2);
    self.cropView.backgroundColor = [UIColor appBackgroundColor];
    if (self.selectedImage) {
        // Force update of image and button if we had an image set before segueing in
        self.selectedImage = self.selectedImage;
    }
    self.navigationController.navigationItem.backBarButtonItem.title = CANCEL_TEXT;
    [self setupStyling];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupStyling
{
    self.view.backgroundColor = [UIColor appBackgroundColor];
    self.headerLabel.font = [UIFont cpLightFontWithSize:kSignInHeaderFontSize italic:NO];
    self.headerLabel.textColor = [UIColor appTitleTextColor];
    self.instructionLabel.font = [UIFont cpLightFontWithSize:kSubCopyFontSize italic:NO];
    self.instructionLabel.textColor = [UIColor appSubCopyTextColor];
    self.swapImageButton.backgroundColor = [UIColor appTealColor];
    self.swapImageButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    [self.swapImageButton setTitleColor:[UIColor appWhiteColor] forState:UIControlStateNormal];
    self.continueButton.backgroundColor = [UIColor appLightTealColor];
    self.continueButton.titleLabel.font = [UIFont cpLightFontWithSize:kButtonTitleFontSize italic:NO];
    [self.continueButton setTitleColor:[UIColor appTealColor] forState:UIControlStateNormal];
}

- (void)setSelectedImage:(UIImage *)selectedImage
{
    _selectedImage = selectedImage;
    self.cropView.image = selectedImage;
    [self.swapImageButton setTitle:NSLocalizedString(@"Swap Photo", @"Button title to upload a new pet photo") forState:UIControlStateNormal];
}

#pragma mark - IBActions
- (IBAction)swapPhotoTapped:(id)sender
{
    [self promptForPhotoSource];
}

- (IBAction)continueTapped:(id)sender
{
    BLOCK_SELF_REF_OUTSIDE();
    void (^imageSelectedBlock)(UIImage *, CGRect) = ^(UIImage *croppedImage, CGRect cropRect){
        BLOCK_SELF_REF_INSIDE();
        // If we have a delegate, we came from settings, and should let the delegate pop us. Otherwise, we're part of the sign up flow, and need to block until user is created and then transition to the dashboard
        if (self.delegate) {
            [self.delegate selectedImage:croppedImage];
        } else {
            [self showLoadingSpinner:YES];
            BLOCK_SELF_REF_OUTSIDE();
            [[CPLoginController sharedInstance] completeSignUpWithPetImage:croppedImage completion:^(NSError *error) {
                BLOCK_SELF_REF_INSIDE();
                if (error) {
                    [self showLoadingSpinner:NO];
                    if ([error isOfflineError]) {
                        [self displayErrorAlertWithTitle:ERROR_TEXT andMessage:OFFLINE_TEXT];
                    } else {
                        [self displayErrorAlertWithTitle:ERROR_TEXT andMessage:error.localizedDescription];
                    }
                }
            }];
        }
    };
    
    // TODO: Only rerender the image if we've changed images, or zoomed/panned. Will require modifying the pod
    if (self.cropView.image) {
        [self.cropView renderCroppedImage:imageSelectedBlock];
    } else {
        imageSelectedBlock(nil, CGRectZero);
    }
}

- (void)showLoadingSpinner:(BOOL)show
{
    [UIView animateWithDuration:.3 animations:^{
        self.fadeView.hidden = !show;
    }];
}

- (void)promptForPhotoSource
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    BLOCK_SELF_REF_OUTSIDE();
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", @"Alert action message to confirm taking photo") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLOCK_SELF_REF_INSIDE();
        [self checkCameraPermissions];
    }];
    
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from library", @"Alert action message to confirm picking photo from library") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentPhotoPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CANCEL_TEXT style:UIAlertActionStyleCancel handler:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:cameraAction];
    }
    
    [alert addAction:libraryAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)checkCameraPermissions
{
    BLOCK_SELF_REF_OUTSIDE();
    void (^authorizationBlock)(AVAuthorizationStatus) = ^(AVAuthorizationStatus status){
        switch (status) {
            case AVAuthorizationStatusAuthorized:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentPhotoPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
                });
                break;
            }
            case AVAuthorizationStatusNotDetermined:
            {
                // Do nothing on not determined, as the system will be presenting the allow/deny dialog
                break;
            }
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
            {
                NSString *title = NSLocalizedString(@"Camera Access Denied", @"Error alert title when camera permissions have been denied");
                NSString *message;
                UIAlertAction *settingsAction;
                UIAlertAction *cancelAction;
                
                if ((&UIApplicationOpenSettingsURLString) != nil) {
                    message = NSLocalizedString(@"Taking a photo requires granting camera access in Settings", @"Error message informing the user camera permissions need to be granted when we can launch the settings app");
                    settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Go to Settings", @"Button title to send user to settings to address camera permissions") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    cancelAction = [UIAlertAction actionWithTitle:CANCEL_TEXT style:UIAlertActionStyleCancel handler:nil];
                } else {
                    message = NSLocalizedString(@"Taking a photo require camera access to be granted. Please open the Settings app and grant access by going to Settings > Privacy > Camera", @"Error message informing the user camera permissions need to be granted when we cannot launch the settings app");
                    settingsAction = [UIAlertAction actionWithTitle:OK_TEXT style:UIAlertActionStyleDefault handler:nil];
                }
                
                UIAlertController *settingsAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                [settingsAlert addAction:settingsAction];
                if (cancelAction) [settingsAlert addAction:cancelAction];
                [self presentViewController:settingsAlert animated:YES completion:nil];
                
                break;
            }
        }
    };
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        BLOCK_SELF_REF_INSIDE();
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentPhotoPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            });
        } else {
            authorizationBlock([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]);
        }
    }];
}

- (void)presentPhotoPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        
        self.imagePicker.sourceType = sourceType;
        self.imagePicker.allowsEditing = NO;
        
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        
        // Present image picker. If we add iPad support, this needs to be slammed into a popover
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.selectedImage = info[UIImagePickerControllerOriginalImage];
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
