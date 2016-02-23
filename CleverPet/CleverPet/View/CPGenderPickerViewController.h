//
//  CPPickerViewController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-17.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPGenderPickerViewController;

@protocol CPGenderPickerViewDelegate <NSObject>

- (void)pickerViewController:(CPGenderPickerViewController*)controller selectedString:(NSString *)string;

@end

@interface CPGenderPickerViewController : UIViewController

@property (nonatomic, weak) id<CPGenderPickerViewDelegate> delegate;

@end
