//
//  CPBreedPickerViewController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-17.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPBreedPickerDelegate <NSObject>

- (void)selectedBreed:(NSString *)breedName;

@end

@interface CPBreedPickerViewController : CPBaseViewController

@property (nonatomic, weak) id<CPBreedPickerDelegate> delegate;
@property (nonatomic, strong) NSString *selectedBreed;

@end
