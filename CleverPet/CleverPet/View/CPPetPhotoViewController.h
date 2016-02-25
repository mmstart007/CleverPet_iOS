//
//  CPPetPhotoViewController.h
//  CleverPet
//
//  Created by Dan Wright on 2016-02-16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPPetPhotoDelegate <NSObject>

- (void)selectedImage:(UIImage *)image;

@end

@interface CPPetPhotoViewController : UIViewController

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, weak) id<CPPetPhotoDelegate> delegate;

@end
