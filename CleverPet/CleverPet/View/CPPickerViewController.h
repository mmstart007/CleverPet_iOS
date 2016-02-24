//
//  CPPickerViewController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-17.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPPickerViewController;

@protocol CPPickerViewDelegate <NSObject>

- (void)pickerViewController:(CPPickerViewController*)controller selectedString:(NSString *)string;

@end

@interface CPPickerViewController : UIViewController

@property (nonatomic, weak) id<CPPickerViewDelegate> delegate;

- (void)setupForPickingGender;
- (void)setupForPickingNeutered;

@end
