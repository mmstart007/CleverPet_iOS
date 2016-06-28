//
//  CPLwaSigninViewController.h
//  CleverPet
//
//  Created by user on 6/28/16.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPLoginWithAmazonDelegate <NSObject>

@required
- (void)loginWithAmazonDidSuccess;
- (void)loginWithAmazonDidCancel;

@end

@interface CPLwaSigninViewController : CPBaseViewController

@property (weak) id<CPLoginWithAmazonDelegate> delegate;

@end
